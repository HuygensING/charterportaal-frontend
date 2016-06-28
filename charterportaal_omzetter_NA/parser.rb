require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
#require 'json/pure'
require './timer.rb'

include REXML

class Parser

    def Parser.parseFile(inputfilename,output_docs,output_rels,csv_file,debug=false)
	file_docs = nil
	file_rels = nil
	if !$testrun
	    file_docs = File.new("#{$output_dir}/#{output_docs}","a")
	    file_rels = File.new("#{$output_dir}/#{output_rels}","a")
	end
	listener = MyListener.new(file_docs,file_rels,csv_file,debug)
	source = File.new File.expand_path(inputfilename)
	STDERR.puts inputfilename
	puts inputfilename
	Document.parse_stream(source, listener)
	source.close
    end

#    def Parser.parseString(id,xml,output_file,debug=false)
#	listener = MyListener.new(output_file,debug)
#	Document.parse_stream(xml, listener)
#    end

end


class MyListener
    include StreamListener

    Maanden = ["","jan","feb","mrt","apr","mei","jun","jul","aug","sep","okt","nov","dec"]

    def initialize(outputfile_docs,output_rels,csv_file,debug=false)
	STDERR.puts "#{$archive}"
	exit(1) if $archive.nil?
	@output = outputfile_docs
	@rels_file = output_rels
	@csv_file = csv_file
	@current_text = ""
	$aantal = 0
	@level = 0
	@unit_title = Array.new(10,"")
	@dates = Array.new(10,"")
	$tags = Array.new
	start_record
	@aant_p_in_odd = Array.new(10,0)
	@editie = ""
	$collective_id = "CHAC00000001"
	@fondsnaam = ""
	@debug = debug
    end

    def outputfile
	return @output
    end

    def ead__end
#	STDERR.puts "aant p in odd"
#	@aant_p_in_odd.each_with_index do |p,i|
#	  STDERR.puts "#{i}: #{p}"
#	end
    end

    def start_record
	@inventarisnr = ""
	@volgnr = ""
	@inventaris_tekst = ""
	@title = ""
	@date = ""
	@save_date = ""
       	@tekstRegest = []
	@description_of_editions = ""
	@unit_id = ""
	@in_fondsnaam = false
	@in_file = false
	@in_unitid = false
	@in_link = false
	@in_physdesc = false
	@in_charter = false
	@ref_start = false
	@ref_end = false
	@in_regest_tekst
	@editie = ""
	@overige = Array.new
	@links = Array.new
	@regest_tekst = Array.new
    end

    def export_record
	begin
	# title afkappen op 70 karakters
	# Wat nu tekstregest is wordt inventaristekst
	# Dus tekstregest blijft leeg
	# link met Institute voor samenstellen van url's
	# local variables to build csv line:
	title = ""
	full_title = ""
	inventaris_tekst = ""
	overige = ""
	regest_tekst = ""
	links = ""
	thumbnails = ""
	thumbnaillabels = ""
	#
	id = sprintf("CHAD%08d",$record_id)
	put_out '{"@type":"charterdocument"'
	put_out ',"_id":"' + id + '"'
	put_out ',"archief":"' + $archive + '"'
	put_out ',"fonds":"' + $collection + '"'
	put_out ',"fondsNaam":"' + @fondsnaam + '"'
	put_out ',"inventarisNummer":"' + @unit_id + '"'
	put_out ',"date" : "' + @dates[@level] + '"'
	if @unit_title[@level].size<71
	    title = "#{@unit_title[@level]}"
	else
	    title = "#{@unit_title[@level][0..@unit_title[@level].rindex(' ',70)]}..."
	end
	put_out ',"title" : "' + title + '"'
	if !@unit_title[@level-1].empty?
	    inventaris_tekst = '["' + @unit_title[@level-1] + '","' + @unit_title[@level] + '"]'
	else
	    inventaris_tekst = '["' + @unit_title[@level] + '"]'
	end
	put_out ',"inventaristekst" : ' + inventaris_tekst
	put_out ',"descriptionOfEditions" : "' + @editie + '"' if !@editie.empty?
	if !@overige.empty?
	    put_out ',"overige" : "'
	    @overige.each_with_index do |overig,ind|
		overige += "</br>" if ind>0
		overige += overig.gsub(/"/,"\\\"").strip
	    end
	    put_out overige + '"'
	end
	if !@regest_tekst.empty?
	    put_out ',"tekstRegest" : '
	    regest_tekst = "["
	    @regest_tekst.each_with_index do |regest,ind|
		regest_tekst += "," if ind>0
		regest_tekst += "\"" + opschonen(regest) + "\""
	    end
	    regest_tekst += "]"
	    put_out regest_tekst
	end
	if !@links.empty?
	    put_out ',"links" : '
	    links = "["
	    @links.each_with_index do |link,ind|
		links += "," if ind>0
		links += '"' + link + '"'
	    end
	    links += "]"
	    put_out links
	end
	if $thumbnails.has_key?(@unit_id)
	    put_out ',"thumbs" : '
	    thumbnails = "["
	    $thumbnails[@unit_id].each_with_index do |thumb,ind|
		thumbnails += "," if ind>0
		thumbnails += '"' + thumb + '"'
	    end
	    thumbnails += "]"
	    put_out thumbnails
	    put_out ',"thumbLabels" : ['
	    thumbnaillabels = "["
	    $thumbnaillabels[@unit_id].each_with_index do |thumb,ind|
		thumbnaillabels += "," if ind>0
		thumbnaillabels += '"' + thumb + '"'
	    end
	    thumbnaillabels += "]"
	    put_out thumbnaillabels
	end
	put_out "}\n"
	if !$testrun
	    @output.flush
	    @rels_file.puts  '{"typeName":"isStoredAt","sourceType":"document","sourceValue":"' + id + '","targetType":"collective","targetValue":"' + $collective_id + '"}'
	end
	$record_id += 1
	@csv_file.puts "#{id}	#{$archive}	#{$collection}	#{@fondsnaam}	#{@unit_id}	#{@dates[@level]}	#{title}	#{inventaris_tekst}	#{@editie}	#{overige}	#{regest_tekst}	#{links}	#{thumbnails}	#{thumbnaillabels}"
	rescue => detail
	    STDERR.puts detail
	    exit(1)
	end
    end

    def c00__start name, attrs
#	STDERR.puts "#{name}__start" if @debug
	@level = name.match(/c0(\d)/)[1].to_i
#	STDERR.puts "level: #{@level}" if @debug
	if !@in_file && attrs['level'].eql?("file")
	    @unit_title[@level] = ""
	    $aantal += 1
	    @in_file = true
	    @save_date = @date if !@date.empty?
	end
    end

    def c00__end name
#	STDERR.puts "#{name}__end (#{@level})" if @debug
	if @in_file && @level.eql?(name.match(/c0(\d)/)[1].to_i)
#	    STDERR.puts "@in_charter: #{@in_charter}" if @debug
	    export_record if @in_charter
	    @in_file = false
	    start_record
	end
    end

    def unittitle__start attrs
	@in_title = true
	label = attrs['label']
	if !label.nil?
	    @in_fondsnaam = true if label.strip.eql?("Naam archiefblok:")
	end
    end

    def unittitle__end
	@in_title = false
	if @in_fondsnaam
	    @fondsnaam = @title.strip
	    @in_fondsnaam = false
	else
	    @unit_title[@level] = opschonen(@title)  # .gsub(/"/,"\\\"").strip
#	    STDERR.puts "unit_title[#{@level}]: #{@unit_title[@level]}" if @debug
	end
	@title = ""
    end

    def unitdate__start attrs
	@in_date = true
    end

    def unitdate__end
	@in_date = false
	@dates[@level] = @date
    end

    def unitid__start attrs
	if @in_file
	   if attrs['type'].eql?("ABS")
	       @in_unitid = true
	   elsif attrs['type'].eql?("handle")
	       @in_link = true
	   end
	end
    end

    def unitid__end
	if @in_file
	    if @in_unitid
		@in_unitid = false
		STDERR. puts @unit_id if @debug
	    elsif @in_link
		@in_link = false
	    end
	end
    end

    def odd__start attrs
	@current_text = Array.new
	@in_odd = true if @in_file
	@aant_p = 0
    end

    def odd__end
	return if !@in_odd
	@in_odd = false
	@overige = @current_text
	if @aant_p_in_odd[@aant_p].nil?
	    @aant_p_in_odd[@aant_p] = 1
	else
	    @aant_p_in_odd[@aant_p] += 1
	end
    end

    def p__start attrs
	@in_p = true
	@aant_p += 1 if @in_odd
    end

    def p__end
	@in_p = false
    end

    def physdesc__start attrs
	@in_physdesc = true
    end

    def physdesc__end
	@in_physdesc = false
    end

    def scopecontent__start attrs
	if !attrs['altrender'].nil?
	    altrender = attrs['altrender']
	    if altrender.eql?("Appendix_Regestenlijst")
		@in_regest_tekst = true
	    end
	end
    end

    def scopecontent__end
	@in_regest_tekst = false
    end

    def ref__start attrs
	STDERR.puts "ref: #{attrs['linktype']}" if @debug
	@ref_start = true
    end

    def ref__end
	STDERR.puts "ref: #{@current_text.last}" if @debug
	@ref_end = true
    end

    def tag_start(name,attrs)
	begin
	    if name.match(/c0\d/)
		result = self.send( "c00__start", name, attrs )
	    else
		result = self.send( "#{name}__start", attrs )
	    end
	rescue => detail
	    if !$tags.include?(name)
		$tags << name
		puts "#{detail}\nin #{name}" if @debug
	    end
	end
	return result
    end

    def text( text )
	if @in_odd && !text.strip.empty?
	    @current_text << "#{text.strip}"
	    @editie = text.strip if text.match(/[gG]edrukt/)
	end
	@in_charter = !text.match("charter").nil?  if @in_physdesc
	@in_charter = !text.downcase.match("charter").nil?  if !@in_charter && @in_title
	@title += " " + text.strip if @in_title
	@date = parse_date(text.strip) if @in_date
	@unit_id = text.strip if @in_unitid
	@links << text.strip if @in_link
	if @in_regest_tekst && !text.strip.empty?
#	    @regest_tekst << text.strip
	    if @regest_tekst.empty?
		@regest_tekst << "#{text.strip}"
	    elsif @ref_start
		last = @regest_tekst.pop
		last += " " if !last[-1..-1].eql?("(")
		last += "#{text.strip}"
#		STDERR.puts "ref_start: #{last}"
		@regest_tekst << last
		@ref_start = false
	    elsif @ref_end
		last = @regest_tekst.pop
		first_char = text.strip[0..0]
		last += " " if !first_char.eql?(")") && !first_char.eql?(",")
		last += "#{text.strip}"
		STDERR.puts "ref_end: #{last}" if @debug
		@regest_tekst << last
		@ref_end = false
	    else
		@regest_tekst << "#{text.strip}"
	    end
	end
    end


    def tag_end(name)
	begin
	    if name.match(/c0\d/)
		result = self.send( "c00__end", name )
	    else
		result = self.send( "#{name}__end" )
	    end
	rescue => detail
#		puts "end: #{detail}\nin #{name}" #if detail.to_s.match(/nil/)
	end
	return result
    end

    def parse_date text
	text.gsub!(/\((\d\d)\)(\d\d)/,'\1\2')
	text = text[0..-2] if text[-1..-1].eql?(".")
	md = text.match(/^(ca.)? ?(\d{4})$/)
	if !md.nil?
	    result = "#{md[2]}"
	    result += "~" if !md[1].nil?
	    return result
	end

	md = text.match(/^\((\d{4})\)$/)
	return sprintf("%04d~",md[1]) if !md.nil?

	md = text.match(/^\[(\d{4})\]$/)
	return sprintf("%04d~",md[1]) if !md.nil?

	md = text.match(/^(\d{4})-(\d{4})$/)
	return sprintf("%04d/%04d",md[1],md[2]) if !md.nil?

	md = text.match(/^(\d{2})\((\d{2})\) (\S+) (\d+)$/)
	if !md.nil?
	    mnd = detect_maand md[3]
	    return sprintf("%02d%02d-%02d-%02d~",md[1],md[2][1..2],mnd,md[4]) unless mnd.nil?
	end

	# numerical date
	if md = text.match(/(\d+)-(\d+)-(\d+)/)
	    # STDERR.puts "numerical date: #{text}"
	    if md[1].to_i > md[3].to_i  # jjjj-mm-dd
		return res = sprintf("%04d-%02d-%02d",md[1],md[2],md[3])
	    else # dd-mm-jjjj
		res = sprintf("%04d-%02d-%02d",md[3],md[2],md[1])
		# STDERR.puts "res: #{res}"
		return res
	    end
	end
	parts = text.split("-")
	if parts.size>1
	    jaar_from = ""
	    date_from = ""
	    ongeveer = ""
	    md = parts[0].strip.match(/^(\d{4}) (\S+)( \d{1,2})?/)
	    if !md.nil?
		jaar_from = md[1]
		mnd_1 = detect_maand md[2]
		if !md[3].nil?
		    date_from = sprintf("%04d-%02d-%02d",jaar_from,mnd_1,md[3].strip) unless mnd_1.nil?
		else
		    date_from = sprintf("%04d-%02d",jaar_from,mnd_1) unless mnd_1.nil?
		end
	    else
		md = parts[0].strip.match(/^(\d{2})\((\d{2})\) (\S+) (\d+)$/)
		if !md.nil?
		    mnd = detect_maand md[3]
		    jaar_from = sprintf("%02d%02d",md[1],md[2][1..2])
		    date_from = sprintf("%04d-%02d-%02d~",jaar_from,mnd,md[4]) unless mnd.nil?
		    ongeveer = "~"
		end
	    end
	    md = parts[1].strip.match(/(\d{4} )?(\S+) (\d{1,2})$/)
	    if !md.nil?
		begin
		jaar_to = md[1].nil? ? jaar_from : md[1].strip
		mnd_2 = detect_maand md[2]
		date_to = sprintf("%04d-%02d-%02d",jaar_to,mnd_2,md[3]) unless mnd_2.nil?
		return "#{date_from}/#{date_to}#{ongeveer}"
		rescue => detail
		    STDERR.puts detail
		    STDERR.puts "parts: #{parts}"
		    STDERR.puts "jaar_to: #{jaar_to}"
		    STDERR.puts "maand: #{md[2]}"
		    exit(1)
		end
	    end
	end

	md = text.match(/^(\d{4}) (\S+) (\d{1,2})$/)
	if !md.nil?
	    mnd = detect_maand md[2]
	    STDERR.puts "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
	    return sprintf("%04d-%02d-%02d",md[1],mnd,md[3]) unless mnd.nil?
	end

	md = text.match(/^(\d{1,2}) (\S+) (\d{4})$/)
	if !md.nil?
	    mnd = detect_maand md[2]
	    STDERR.puts "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
	    return sprintf("%04d-%02d-%02d",md[3],mnd,md[1]) unless mnd.nil?
	end

	md = text.match(/^\((\d{4}) (\S+) (\d{1,2})\)$/)
	if !md.nil?
	    mnd = detect_maand md[2]
	    STDERR.puts "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
	    return sprintf("%04d-%02d-%02d~",md[1],mnd,md[3]) unless mnd.nil?
	end

	md = text.match(/^(\d{4}) (\S+)$/)
	if !md.nil?
	    mnd = detect_maand md[2]
	    STDERR.puts "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
	    return sprintf("%04d-%02d",md[1],mnd) unless mnd.nil?
	end

	STDERR.puts "date? : #{text.strip}" if @debug
	return text.strip
    end

    def detect_maand maand
	STDERR.puts "maand: |#{maand[0..2]}|"  if @debug
	res = Maanden.index(maand[0..2].downcase)
	if res == nil
	    res = 3  if maand[0..2].downcase.eql?("maa")
	    res = 10  if maand[0..2].downcase.eql?("oct")
	end
	STDERR.puts "res: |#{res}|"  if @debug
	return res
    end
    
    def put_out( arg )
	@output.write(arg) unless $testrun
	arg
    end

    def result
	@verzameling
    end

    def opschonen text
	text.gsub!(/"/,"\\\"")
	text.gsub!("\n"," ")
	text.gsub!("\t"," ")
	text.gsub!(/  +/," ")
	text.strip
    end

end


def thumbnails thumb_dir
    thumb_dir.strip! unless thumb_dir.nil?
    $thumbnails = Hash.new
    $thumbnaillabels = Hash.new
    return if thumb_dir.nil? || thumb_dir.empty?
    return if !File.exists?(thumb_dir)
    Dir.chdir(thumb_dir)
    if File.exists?("conc.txt")
	File.open("conc.txt") do |file|
	    while line = file.gets
		if !line.strip.empty? && line.strip[-3..-1].eql?("jpg")
		    th_name_orig,th_name_label = line.split(',')
		    if md = th_name_label.match("#{$archive}_#{$collection}_")
			md_2 = md.post_match.match(/(\d+)_?([^.]*)\.jpg/)
			if !md_2.nil?
			    if $thumbnails[md_2[1]]
				$thumbnails[md_2[1]] << th_name_orig
				$thumbnaillabels[md_2[1]] << th_name_label.strip
			    else
				$thumbnails[md_2[1]] = [ th_name_orig ]
				$thumbnaillabels[md_2[1]] = [ th_name_label.strip ]
			    end
			end
		    end
		end
	    end
	end
    else
	Dir.glob("*").each do |th|
	    if md = th.match("#{$archive}_#{$collection}_")
		md_2 = md.post_match.match(/(\d+)_?([^.]*)\.jpg/)
		if !md_2.nil?
		    if $thumbnails[md_2[1]]
			$thumbnails[md_2[1]] << th
		    else
			$thumbnails[md_2[1]] = [ th ]
		    end
		end
	    end
	end
    end
    Dir.chdir("..")
end

if __FILE__ == $0
    Timer.start

    file_in = ""
    file_out = ""
    debug = false
    $output_dir = ""
    $thumbnails = Hash.new
    $thumbnaillabels = Hash.new
    $testrun = false
    multiple_archives = ""
    thumb_dir = ""
    csv_file_name = ""
    begin
    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    when '-i'
		file_in = ARGV[i+1]
	    when '-a'
		$archive = ARGV[i+1]
	    when '-c'
		$collection = ARGV[i+1]
	    when '-d'
		$output_dir = ARGV[i+1]
	    when '-f'
		multiple_archives = ARGV[i+1]
	    when '-t'
		thumb_dir = ARGV[i+1]
	    when '-csv'
		csv_file_name = ARGV[i+1]
	    when '--testrun'
		$testrun = true
	    when '--debug'
		debug = true
	end
    end
    rescue => detail
	STDERR.puts "#{detail}"
    end

    csv_file = nil
    if csv_file_name.empty?
	csv_file = File.new("csv_file.csv","w")
    else
	csv_file = File.new(csv_file_name,"w")
    end
    csv_file.puts "Id	Archive	Collection	Fondsnaam	Unit_id	Dates	Title	Inventaris_tekst	Editie	Overige	Regesttekst	Links	Thumbnails	Thumbnaillabels"

    if multiple_archives.empty? && ( file_in.empty? || $archive.nil? || $collection.nil? )
	puts "use: parser.rb -a archive -c collection -d output_dir -i file_in"
	puts "the name of the output file(s) are derived from the archive and collection names"
	puts "or"
	puts "use: parser.rb -f description file"
	puts "In this description file a list of archives and collections can be defined which will be processed"
	exit(1)
    end

    $record_id = 1
    $output_dir = "C:/git/timbuctoo-testdata/src/main/resources/import/charter" if $output_dir.empty?

    collectives = Array.new
    collective_id = 1
    output_institutes = "charterinstitute.json"
    if !$testrun
	collectives_file = File.new("#{$output_dir}/#{output_institutes}","w")
	output_import_txt = File.new("#{$output_dir}/import.txt","w")
	output_import_txt.puts "#{output_institutes};chartercollective"
	output_import_txt.puts "charterdocument.json;charterdocument"
#	output_import_txt.puts "charterrelation.json;charterrelation"
	output_import_txt.close
    end

    if !multiple_archives.empty?
	line_nr = 1
	archives = Array.new
	if !$testrun
	    if File.exists?("#{$output_dir}/charterdocument.json")
		File.delete("#{$output_dir}/charterdocument.json")
	    end
    	    if File.exists?("#{$output_dir}/charterrelation.json")
		File.delete("#{$output_dir}/charterrelation.json")
	    end
	end
	File.open(multiple_archives) do |file|
	    while line = file.gets
		if !line.strip.empty? && !line[0..0].eql?("#")
		    if line.split("\t").size > 2
			file_in,$archive,$collection,thumbs_dir = line.split("\t")
			if collectives.include?($archive)
			    $collective_id = sprintf("CHAC%08d",collectives.index($archive))
			else
			    collectives.insert(collective_id,$archive)
			    $collective_id = sprintf("CHAC%08d",collectives.index($archive))
			    if !$testrun
				collectives_file.puts '{"@type":"chartercollective","_id":"' +
				    $collective_id + '","name":"' + $archive + '"}'
			    end
			    collective_id += 1
			end
			thumbnails thumbs_dir
			archives << [$archive,$collection]
			output_documents = "charterdocument.json"
			output_relations = "charterrelation.json"
#			debug = $collection.eql?("3.19.18")
			Parser.parseFile(file_in,output_documents,output_relations,csv_file,debug)
		    else
			STDERR.puts "regel #{line_nr} in #{multiple_archives} niet volledig"
		    end
		end
		line_nr += 1
	    end
	end
    else
	thumbnails(thumb_dir) if !thumb_dir.empty?
	$collective_id = sprintf("CHAC%08d",collective_id)
	collectives_file.puts '{"@type":"chartercollective","_id":"' + $collective_id +
	    '","name":"' + $archive + '"]}'
#	    '","name":"Nationaal Archief","links":["http://www.gahetna.nl"]}'
	output_relations = "charterrelation.json"
	output_documents = "charterdocument.json"

	Parser.parseFile(file_in,output_documents,output_relations,csv_file,debug)
    end

    Timer.stop

end

