#!/bin/bash

set -o errexit

mkdir -p xmls
mkdir -p result

if [ -z "$(ls -A xmls)" ]; then
  ./load_archive_file.rb -f ./all_archives.txt -d xmls
fi
./make_rdf.rb  -f ./all_archives.txt -x xmls -d result -rdf result/charters_dump.rdf

cat result/charters_dump.rdf | sort | uniq > result/charters_next.rdf
rm result/charters_dump.rdf
resultfile=result/charters-`date "+%Y-%m-%d-%H-%M-%S"`.rdf
if [ -e result/charters_cur.rdf ]; then
  diff --unified=0 result/charters_cur.rdf result/charters_next.rdf > $resultfile
  mv result/charters_next.rdf result/charters_cur.rdf
else
  cp result/charters_next.rdf $resultfile
  mv result/charters_next.rdf result/charters_cur.rdf
fi
