#!/bin/bash

set -o errexit

mkdir -p xmls
mkdir -p result

if [ -z "$(ls -A xmls)" ]; then
  ./load_archive_file.rb -f ./all_archives.txt -d xmls
fi
./parser.rb  -f ./all_archives.txt -x xmls -d result -csv result/charters.csv
