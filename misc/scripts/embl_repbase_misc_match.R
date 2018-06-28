#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = TRUE)
library(tidyverse)
library(stringr)

# blast_dir <- "/Users/shunhua/work/S2/te_library_0521/embl_repbase_best.tsv"
# te_table_dir <- "/Users/shunhua/git/transposons/misc/te_id_table_new.csv"
# out_dir="/Users/shunhua/git/transposons/misc/embl_repbase_match.csv"

blast_repbase_dir <- args[1]
blast_misc_dir <- args[2]
te_table_dir <- args[3]
out_dir <- args[4]

blast_repbase_hit <- read_tsv(blast_repbase_dir, col_names = c("fb_id", "repbase_name", "repbase_percentage"))
blast_misc_hit <- read_tsv(blast_misc_dir, col_names = c("fb_id", "misc_name", "misc_percentage"))
te_table_dir <- read_csv(te_table_dir)

embl_repbase_match <-full_join(te_table_dir, blast_repbase_hit, by = "fb_id")
embl_repbase_misc_match <-full_join(embl_repbase_match, blast_misc_hit, by = "fb_id")

# embl_repbase_misc_match %>% filter(is.na(repbase_name))

write_csv(embl_repbase_misc_match, out_dir)
