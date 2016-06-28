#!/usr/bin/env ruby

require 'open-uri'
require 'pp'
require './timer.rb'


def copy_file collection,file_name,output_dir
    uitvoer = File.new("#{output_dir}/#{file_name}","w")
    puts "http://www.gahetna.nl/collectie/archief/ead/xml/eadid/#{collection} --> #{file_name}"
    open("http://www.gahetna.nl/collectie/archief/ead/xml/eadid/#{collection}") do |f|
	while(line = f.gets) do
	    uitvoer.puts line
	end
    end
end


if __FILE__ == $0
    Timer.start

    debug = false
    output_dir = ""
    multiple_archives = ""
    begin
    (0..(ARGV.size-1)).each do |i|
	case ARGV[i]
	    when '-d'
		output_dir = ARGV[i+1]
	    when '-f'
		multiple_archives = ARGV[i+1]
	    when '--debug'
		debug = true
	    when '-h'
		STDERR.puts "use: ruby load_archieve_file.rb -f list_file [-d output_dir]"
		exit(1)
	end
    end
    rescue => detail
	STDERR.puts "#{detail}"
    end

    if multiple_archives.empty?
	STDERR.puts "use: ruby load_archieve_file.rb -f list_file [-d output_dir]"
	exit(1)
    end

    File.open(multiple_archives) do |file|
	while line = file.gets
	    if !line.strip.empty? && !line[0..0].eql?("#")
		if line.split("\t").size > 2
		    file_name,archive,collection,thumbs_dir = line.split("\t")
		    copy_file collection,file_name,output_dir
		end
	    end
	end
    end

    Timer.stop
end
