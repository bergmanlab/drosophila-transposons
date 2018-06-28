#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = TRUE)
library(tidyverse)
library(stringr)

# blast_dir <- "/Users/shunhua/work/S2/te_library_0521/embl_repbase_best.tsv"
# te_table_dir <- "/Users/shunhua/git/transposons/misc/te_id_table_new.csv"
# out_dir="/Users/shunhua/git/transposons/misc/embl_repbase_match.csv"

blast_dir <- args[1]
te_table_dir <- args[2]
out_dir <- args[3]

blast_hit <- read_tsv(blast_dir, col_names = c("fb_id", "repbase_name", "percentage"))
te_table_dir <- read_csv(te_table_dir)

embl_repbase_match <-full_join(te_table_dir, blast_hit, by = "fb_id")
embl_repbase_match %>% filter(is.na(repbase_name))

write_csv(embl_repbase_match, out_dir)
