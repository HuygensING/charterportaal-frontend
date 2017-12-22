FROM ruby:2.2

WORKDIR /root

COPY parser.rb /root
COPY timer.rb /root
COPY make_rdf.rb /root
COPY load_archive_file.rb /root
COPY all_archives.txt /root
COPY entrypoint.sh /root

CMD ["./entrypoint.sh"]
