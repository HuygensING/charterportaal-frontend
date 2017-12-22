#!/usr/bin/env ruby

require 'rexml/document'
require 'rexml/streamlistener'
require 'rubygems'
require './timer.rb'
require 'json'

include REXML

class Parser

  def Parser.parseFile(inputfilename,output_docs,output_rels,rdf_file,debug=false)
    file_docs = nil
    file_rels = nil
    listener = MyListener.new(file_docs,file_rels,rdf_file,debug)
    source = File.new "xmls/#{inputfilename}"
    file_date = source.mtime.strftime("%Y-%m-%d")
    STDOUT.puts "#{inputfilename} (#{file_date})"
    Document.parse_stream(source, listener)
    source.close
  end

end


class MyListener
  include StreamListener

  Maanden = ["","jan","feb","mrt","apr","mei","jun","jul","aug","sep","okt","nov","dec"]

  def initialize(outputfile_docs,output_rels,rdf_file,debug=false)
    STDERR.puts "#{$archive}"
    exit(1) if $archive.nil?
    @output = outputfile_docs
    @rels_file = output_rels
    @rdf_file = rdf_file
    @current_text = ""
    $aantal = 0
    @level = 0
    @unit_title = Array.new(10,"")
    @unit_ids = Array.new(10,"")
    $tags = Array.new
    start_record
    @aant_p_in_odd = Array.new(10,0)
    @editie = ""
    $collective_id = "CHAC00000001"
    @fondsnaam = ""
    @debug = debug
    @dates = Array.new(10,["","",""])
  end

  def outputfile
    return @output
  end

  def ead__end
  end

  def start_record
    @inventarisnr = ""
    @volgnr = ""
    @inventaris_tekst = ""
    @title = ""
    @date_normal = ""
    @date_parsed = ""
    @date_as_is = ""
    @in_date = false
    @save_raw_date = false
         @tekstRegest = []
    @description_of_editions = ""
    @unit_id = ""
    @unit_id_printed = false
    @in_fondsnaam = false
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
      # local variables to build rdf line:
      title = ""
      inventaris_tekst = []
      overige = ""
      id = sprintf("CHAD%08d",$record_id)
  
      if @unit_title[@level].size<71
        title = "#{@unit_title[@level]}"
      else
        title = "#{@unit_title[@level][0..@unit_title[@level].rindex(' ',70)]}..."
      end
  
      (1..@level).each do |level|
#        inventaris_tekst << "\"#{@unit_ids[level]}\""
#        inventaris_tekst << "\"#{@unit_title[level]}\""
        inventaris_tekst << "#{@unit_ids[level]}"
        inventaris_tekst << "#{@unit_title[level]}"
      end
  
      if !@overige.empty?
        @overige.each_with_index do |overig,ind|
          overige += "</br>" if ind>0
          overige += overig.gsub(/"/,"\\\"").strip
        end
      end
  
      $record_id += 1

      output_line = []
      id_part = "<#{$resource}/#{id}>"

#      <http://resources.huygens.knaw.nl/charterportal/CHAD00000001> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://resources.huygens.knaw.nl/charterportal/charter>

      @rdf_file.puts "#{id_part} <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <#{$resource}/charter> ."
      @rdf_file.puts "#{id_part} <#{$resource}/archive> \"#{$archive}\" ."
      @rdf_file.puts "#{id_part} <#{$resource}/collection> \"#{$collection}\" ."
      @rdf_file.puts "#{id_part} <#{$resource}/fondsnaam> \"#{@fondsnaam}\" ."
      @rdf_file.puts "#{id_part} <#{$resource}/unit_ids_#{@level}> \"#{@unit_ids[@level]}\" ."
      @rdf_file.puts "#{id_part} <#{$resource}/level> \"#{@level}\" ."
      @rdf_file.puts "#{id_part} <#{$resource}/dates_0> \"#{@dates[@level][0]}\"^^<https://www.loc.gov/standards/datetime/pre-submission.html> ."
      @rdf_file.puts "#{id_part} <#{$resource}/dates_1> \"#{@dates[@level][1]}\"^^<https://www.loc.gov/standards/datetime/pre-submission.html> ."
      @rdf_file.puts "#{id_part} <#{$resource}/dates_2> \"#{@dates[@level][2]}\"^^<https://www.loc.gov/standards/datetime/pre-submission.html> ."
      @rdf_file.puts "#{id_part} <#{$resource}/title> #{title.to_json} ."
      @rdf_file.puts "#{id_part} <#{$resource}/inventaris_tekst> #{inventaris_tekst.join("\n\n").to_json} ."
      @rdf_file.puts "#{id_part} <#{$resource}/editie> #{@editie.to_json} ." if !@editie.empty?
      @rdf_file.puts "#{id_part} <#{$resource}/overige> #{overige.to_json} ." if !@overige.empty?
      @rdf_file.puts "#{id_part} <#{$resource}/regest_tekst> #{opschonen(@regest_tekst.join(' '),false).to_json} ." if !@regest_tekst.empty?

      # until now never more than 1 link found
      @links.each do |link|
        @rdf_file.puts "#{id_part} <#{$resource}/links> \"#{link}\" ."
      end

      @rdf_file.puts "#{id_part} <http://xmlns.com/foaf/spec/#term_depiction> \"#{$thumbnailserver}/#{$archive}_#{$collection}_#{@unit_ids[@level]}_R.jpg\" ."
      @rdf_file.puts "#{id_part} <http://xmlns.com/foaf/spec/#term_depiction> \"#{$thumbnailserver}/#{$archive}_#{$collection}_#{@unit_ids[@level]}_V.jpg\" ."
      
#      @rdf_file.puts

    rescue => detail
      STDERR.puts detail
      STDERR.puts detail.backtrace.join("\n")
      exit(1)
    end
  end

  def c00__start name, attrs
    @level = name.match(/c0(\d)/)[1].to_i
    if !@in_file && attrs['level'].eql?("file")
      @in_file_level = @level
      @unit_title[@level] = ""
      $aantal += 1
      @in_file = true
    end
  end

  def c00__end name
    close_level = name.match(/c0(\d)/)[1].to_i
    if @in_file && @level.eql?(close_level)
      export_record if @in_charter
      @in_file = false if @in_file_level.eql?(close_level)
      start_record
    end
    @unit_title
  end

  def unittitle__start attrs
    @in_title = true
    label = attrs['label']
    type = attrs['type']
    @in_fondsnaam = true if !type.nil? && type.eql?("short")
  end

  def unittitle__end
    @in_title = false
    @unit_title[@level] = opschonen(@title,false)
    if @in_fondsnaam
      @fondsnaam = @title.strip
      @in_fondsnaam = false
    end
    @title = ""
  end

  def unitdate__start attrs
    if !attrs['normal'].nil?
      @date_normal = attrs['normal']
    else
      @date_normal = ""
    end
    @date_as_is = ""
    @date_parsed = ""
    @in_date = true
  end

  def unitdate__end
    @dates[@level] = [@date_normal,@date_as_is,@date_parsed]
    # count dates
    $count_unit_dates += 1
    if @date_normal.empty?
      $count_empty_date_normal += 1 
      $count_date_text_filled += 1 if !@date_as_is.empty?
      $count_parse_succes += 1 if !@date_parsed.empty?
      if @date_as_is.size > 4
        $count_date_text_long += 1
        $count_parse_long_succes += 1 if !@date_parsed.empty?
      end
    end
    $count_date_text += 1 if !@date_as_is.empty?
    $count_parsed_dates += 1 if !@date_parsed.empty?
    @in_date = false
  end

  def unitid__start attrs
    if attrs['type'].eql?("handle")
         @in_link = true if @in_file
    else
      @in_unitid = true
    end
  end

  def unitid__end
    if @in_file
      if @in_unitid
        @unit_id_printed = false
      elsif @in_link
        @in_link = false
      end
    end
    @unit_ids[@level] = @unit_id
    @in_unitid = false
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
      end
    end
    return result
  end

  def text( text )
    if @in_odd && !text.strip.empty?
      @current_text << "#{text.strip}"
      @editie = text.strip if text.match(/[gG]edrukt/)
    end
    if @in_physdesc
      @in_charter = !text.match("charter").nil?
      @in_charter = !text.downcase.match("charter").nil?  if !@in_charter
    end
    @title += " " + text.strip if @in_title
    @date_parsed = parse_date(text.strip) if @in_date
    @date_as_is = text.strip if @in_date
    @unit_id = text.strip if @in_unitid
    @links << text.strip if @in_link
    if @in_regest_tekst && !text.strip.empty?
      if @regest_tekst.empty?
        @regest_tekst << "#{text.strip}"
      elsif @ref_start
        last = @regest_tekst.pop
        last += " " if !last[-1..-1].eql?("(")
        last += "#{text.strip}"
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
#        puts "end: #{detail}\nin #{name}" #if detail.to_s.match(/nil/)
    end
    return result
  end

  def parse_date text
    return text if text.match(/^\d\d\d\d$/)
    save_date = text
    text.gsub!("(","")
    text.gsub!(")","")
    text = text[0..-2] if text[-1..-1].eql?(".")
    md = text.match(/^(ca.)? ?(\d{4})$/)
    if !md.nil?
      result = "#{md[2]}"
      result += "~" if !md[1].nil?
      return result
    end

    md = text.match(/^\((\d{4})\)$/)
    return sprintf("%04d~",md[1]) if !md.nil?

    md = text.match(/^(\d{4}) ca$/)
    return sprintf("%04d~",md[1]) if !md.nil?

    md = text.match(/^\[(\d{4})\]$/)
    return sprintf("%04d~",md[1]) if !md.nil?

    md = text.match(/^(\d{4}) ?- ?(\d{4})$/)
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
          put_stderr  detail
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
      put_stderr "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
      return sprintf("%04d-%02d-%02d",md[1],mnd,md[3]) unless mnd.nil?
    end

    md = text.match(/^(\d{1,2}) (\S+) (\d{4})$/)
    if !md.nil?
      mnd = detect_maand md[2]
      put_stderr "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
      return sprintf("%04d-%02d-%02d",md[3],mnd,md[1]) unless mnd.nil?
    end

    md = text.match(/^\((\d{4}) (\S+) (\d{1,2})\)$/)
    if !md.nil?
      mnd = detect_maand md[2]
      put_stderr "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
      return sprintf("%04d-%02d-%02d~",md[1],mnd,md[3]) unless mnd.nil?
    end

    md = text.match(/^(\d{4}) (\S+)$/)
    if !md.nil?
      mnd = detect_maand md[2]
      put_stderr "date? : #{text.strip}" if(mnd.nil? || mnd.eql?(0)) && @debug
      return sprintf("%04d-%02d",md[1],mnd) unless mnd.nil?
    end

    put_stderr "date? : #{text.strip}" if @debug
    return "" # [text,false]
  end

  def detect_maand maand
    res = Maanden.index(maand[0..2].downcase)
    if res == nil
      res = 3  if maand[0..2].downcase.eql?("maa")
      res = 10  if maand[0..2].downcase.eql?("oct")
    end
    put_stderr "maand: |#{maand}| geeft res 0"  if @debug && res==0
    return res
  end
  
  def put_stderr text
    return if @unit_id.empty?
    if !@unit_id_printed
      STDERR.puts "unit_id: #{@unit_id}"
      @unit_id_printed = true
    end
    STDERR.puts text
  end

  def result
    @verzameling
  end

  def opschonen text,escape_quotes=true
    text.gsub!(/"/,"\\\"") if escape_quotes
    text.gsub!("\n"," ")
    text.gsub!("\t"," ")
    text.gsub!(/  +/," ")
    text.strip
  end

end


def thumbnails thumb_dir
  STDERR.puts thumb_dir
  thumb_dir = thumb_dir.strip unless thumb_dir.nil?
  STDERR.puts thumb_dir
  $thumbnails = Hash.new
  $thumbnaillabels = Hash.new
  return if thumb_dir.nil? || thumb_dir.empty?
  return if !File.exists?(thumb_dir)
  STDERR.puts "exists"
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

def print_help
    puts "use: parser.rb -a archive -c collection -d output_dir -i file_in -t thumbnailmap"
    puts "the name of the output file(s) are derived from the archive and collection names"
    puts "or"
    puts "use: parser.rb -f description file"
    puts "In this description file a list of archives and collections can be defined which will be processed"
    puts
    puts "options:"
    puts "-rdf rdf filename (default: rdf_file.txt)"
    puts "-res resources (default: http://resources.huygens.knaw.nl/charterportal)"
    puts "-tns thumbnailserver (default: http://thumbnails.huygens.knaw.nl)"
end

if __FILE__ == $0
  Timer.start
  STDOUT.puts
  STDOUT.puts "filename (date)"

  file_in = ""
  file_out = ""
  debug = false
  $output_dir = ""

  $thumbnails = Hash.new
  $thumbnaillabels = Hash.new
  $testrun = true
  multiple_archives = ""
  thumb_dir = ""
  rdf_file_name = ""
  $resource = "http://resources.huygens.knaw.nl/charterportal"
  $thumbnailserver = "http://test.resources.huygens.knaw.nl/charterportaal/images/"
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
      when '-rdf'
        rdf_file_name = ARGV[i+1]
      when '-res'
        $resource = ARGV[i+1]
      when '-tns'
        $thumbnailserver = ARGV[i+1]
      when '--testrun'
        $testrun = true
      when '--debug'
        debug = true
      when '-h'
        print_help
        exit(0)
      when '--help'
        print_help
        exit(0)
    end
  end
  rescue => detail
    STDERR.puts "#{detail}"
  end

  rdf_file = nil
  if rdf_file_name.empty?
    rdf_file = File.new("rdf_file.txt","w")
  else
    rdf_file = File.new(rdf_file_name,"w")
  end

  if multiple_archives.empty? && ( file_in.empty? || $archive.nil? || $collection.nil? )
    puts "use: parser.rb -a archive -c collection -d output_dir -i file_in"
    puts "the name of the output file(s) are derived from the archive and collection names"
    puts "or"
    puts "use: parser.rb -f description file"
    puts "In this description file a list of archives and collections can be defined which will be processed"
    exit(1)
  end

  $count_unit_dates = 0
  $count_empty_date_normal = 0
  $count_date_text_filled = 0
  $count_parse_succes = 0
  $count_date_text_long = 0
  $count_parse_long_succes = 0
  $count_date_text = 0
  $count_parsed_dates = 0

  $record_id = 1
  $output_dir = "C:/git/timbuctoo-testdata/src/main/resources/import/charter" if $output_dir.empty?

  collectives = Array.new
  collective_id = 1
  output_institutes = "charterinstitute.json"

  if !multiple_archives.empty?
    line_nr = 1
    archives = Array.new
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
              collective_id += 1
            end
            thumbnails thumbs_dir
            archives << [$archive,$collection]
            output_documents = "charterdocument.json"
            output_relations = "charterrelation.json"
            Parser.parseFile(file_in,output_documents,output_relations,rdf_file,debug)
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

#      '","name":"Nationaal Archief","links":["http://www.gahetna.nl"]}'
    output_relations = "charterrelation.json"
    output_documents = "charterdocument.json"

    Parser.parseFile(file_in,output_documents,output_relations,rdf_file,debug)
  end

  STDOUT.puts
  STDOUT.puts "number of unitdates: #{$count_unit_dates}"
  STDOUT.puts "number of empty fields 'normal': #{$count_empty_date_normal}"
  STDOUT.puts "  in these:"
  STDOUT.puts "  number of filled 'date texts': #{$count_date_text_filled}"
  STDOUT.puts "  number of succesfully parsed dates: #{$count_parse_succes}"
  STDOUT.puts "  number 'date texts' longer than 4 char: #{$count_date_text_long}"
  STDOUT.puts "  number these succesfully parsed: #{$count_parse_long_succes}"
  STDOUT.puts
  STDOUT.puts "total number of filled 'date texts'#{$count_date_text}"
  STDOUT.puts "total number succesfully parsed dates: #{$count_parsed_dates}"


  Timer.stop

end

