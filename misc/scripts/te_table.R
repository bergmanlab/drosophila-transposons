#!/usr/bin/env Rscript
args = commandArgs(trailingOnly = TRUE)
library(tidyverse)
library(stringr)

te_embl_dir <- args[1]
te_misc_dir <- args[2]
te_meta_dir <- args[3]

te_misc <- read_csv(te_misc_dir, col_names = c("te_name", "type", "subtype"))
te_embl <- read_csv(te_embl_dir, col_names = c("embl_id", "fb_id", "source_id", "species", "te_name"))

te_embl_dmel <- te_embl %>%
  filter(species=="Dmel")

te_match_dmel <-left_join(te_embl_dmel, te_misc, by = "te_name")
write_csv(te_match_dmel, te_meta_dir)