library(tidyverse)
library(stringr)

blast_dir <- "/Users/shunhua/work/S2/te_library_0521/embl_repbase_best.tsv"
te_table_dir <- "/Users/shunhua/git/transposons/misc/te_id_table_new.csv"

blast_hit <- read_tsv(blast_dir, col_names = c("fb_id", "repbase"))
te_table_dir <- read_csv(te_table_dir, col_names = c("embl_id", "fb_id", "source_id", "species", "te_name", "te_type"))


embl_repbase_match <-full_join(te_table_dir, blast_hit, by = "fb_id")
embl_repbase_match %>% filter(is.na(repbase))

out_dir="/Users/shunhua/git/transposons/misc/embl_repbase_match.csv"

write_csv(embl_repbase_match, out_dir)
