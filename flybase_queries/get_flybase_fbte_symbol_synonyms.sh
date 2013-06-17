#get symbol synonyms for FBte IDs in flybase_fbte.txt
for i in `cut -f1 flybase_fbte.txt`; do 
echo "SELECT distinct f.uniquename, f.name, s.name FROM cvterm cvt, feature f, feature_synonym fs, synonym s WHERE f.feature_id = fs.feature_id AND fs.synonym_id = s.synonym_id AND s.type_id = cvt.cvterm_id AND cvt.name = 'symbol' AND fs.is_current = 'f' AND f.uniquename = '${i}';" | psql -h flybase.org -U flybase flybase -t -P fieldsep=$'\t' -P format=unaligned >> flybase_fbte_symbol_synonyms.txt;
done
