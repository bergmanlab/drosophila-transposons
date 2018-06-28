#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = TRUE)
library(tidyverse)
library(stringr)

blast_repbase_dir <- args[1]
te_table_dir <- args[2]
out_dir <- args[3]

blast_hit <- read_tsv(blast_repbase_dir, col_names = c("fb_id", "db_name", "p_ident", "n_ident", "align_len", "query_len", "subject_len"))
te_meta <- read_csv(te_table_dir) %>% filter(species=="Dmel")

table_join <-full_join(te_meta, blast_hit, by = "fb_id")
write_csv(table_join, out_dir)
