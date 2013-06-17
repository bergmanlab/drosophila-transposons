#get list of FBte IDs and names in flybase
echo "select f.uniquename, f.name, o.genus, o.species from feature f, organism o where f.is_obsolete = 'f' AND f.organism_id = o.organism_id AND f.uniquename like 'FBte%';" | psql -h flybase.org -U flybase flybase -P footer=off -P fieldsep=$'\t' -P format=unaligned > flybase_fbte.txt
