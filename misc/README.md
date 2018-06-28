D_mel_transposon_sequence_set.fa
-----------------------------------

This file was used in [Sackton et al (2009)](http://gbe.oxfordjournals.org/content/1/449.full)
and was created by modifying the Berkeley Drosophila Genome Project's TE data set (v9.4.1) to 

1) include the class/subclass of each family, and
2) remove any TE sequences not from D. melanogaster. 

There are 128 records in this file: 125 TE families, plus the rDNA, SAR_DM and XDMR repeats. 
This file is formatted to allow RepeatMasker to generate a .tbl file using the -lib option. 
LTR elements are represented by a single record (i.e. LTRs are joined to internal regions).

NOTE: This file is deprecated as of 28 June 2018. Please use the most up to date 
`D_mel_transposon_sequence_set.fa` file in https://github.com/bergmanlab/transposons/tree/master/releases.

wolbachia
-----------------------------------

Fasta file of IS elements in wMel genome.

personal_communications
-----------------------------------

Personal communications used to support modifications to TE library.

scripts
-----------------------------------

Scripts used to convert the transposon_sequence_set_v9.45 EMBL file to fasta and GFF3 format.

metadata
-----------------------------------

Metadata files used in the process of converting transposon_sequence_set_v9.45 EMBL file to 
fasta and GFF3 format.

flybase_queries
-----------------------------------

FlyBase TE family synonym SQL queries and result files.
