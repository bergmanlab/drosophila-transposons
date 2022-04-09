# **DROSOPHILA TRANSPOSON CANONICAL SEQUENCES**


This repository contains 'canonical' DNA sequences of the transposable
elements from species in the genus Drosophila.

History: These sequences were originally compiled by Takis Benos (EBI),
Leyla Bayraktaroglu (Harvard) and Michael Ashburner (EBI & Cambridge)
with help from Aubrey de Grey (Cambridge), Joe Chillemi (Harvard) and
Martin Reese (LBNL). We thank Suzi Lewis (Berkeley) for inspiration and
discussion, Guochun Liao (Berkeley) for his repeat sequence set and
newly discovered transposable element sequences from the Berkeley P1
clones, and Lynn Crosby (Harvard) for her annotations of some elements.

Subsequent curation of these sequences has been in the context of the
Drosophila Genome Project and was a collaboration between M. Ashburner
(Cambridge), Josh Kaminker (Berkeley) and Casey Bergman (Berkeley). From
Version 8.0 this set has been maintained by Michael Ashburner and Casey
Bergman in Cambridge. The last version updated by Michael Ashburner was
Version 9.411. FlyBase generated version 9.42 from these files in 2009,
which have not subsequently been updated at FlyBase.

From version v9.43 onwards, this set has been under continuous version control
by Casey Bergman (Manchester/UGA) and Shunhua Han (UGA) at: https://github.com/bergmanlab/transposons/.
Contributions are welcome by submitting pull requests or opening issues for
this repository. For pull requests, please make suggested edits to the files
in: https://github.com/bergmanlab/transposons/tree/master/current. These
contributions will be reviewed and, if merged, will be used to make an
incremented version of the dataset in: https://github.com/bergmanlab/transposons/tree/master/releases.

Version v9.5 is the last version of this dataset that will be released in EMBL
format. The EMBL format is a legacy format that mixes sequences and annotations,
and requires conversion to FASTA prior to use in genome informatics analysis.
The v9.5 EMBL file was used to generate corresponding FASTA sequence + GFF3
annotation files, and these files form the basis of the 10.1 release. Subsequent
modifications will be made to the FASTA + GFF3 files. The legacy v9.5 EMBL file
will no longer be updated but will be preserved here for posterity.

Release 10.1 and future releases will use the FlyBase FBte as the primary
identifier for each TE family. The valid FlyBase TE family name can be found
in the GFF file and synonyms can be found at FlyBase. As in the EMBL file, LTR
elements in the FASTA files are represented by a single record (i.e. LTRs
are joined to internal regions). LTR annotations in the GFF file can be used to
split complete LTR elements into LTR and internal regions for optimal use with
RepeatMasker.

Starting with Release 10.1, curation efforts will focus primarily
on D. melanogaster TEs. Therefore, in addition to the transposon_sequence_set.fa
and transposon_sequence_set.gff files, we will also provide a D. melanogaster-only
FASTA file (D_mel_transposon_sequence_set.fa). The D. melanogaster-only
FASTA file headers use the valid Flybase TE family names and and are formatted
with TE type and subtype information in a manner that allows RepeatMasker to
generate a .tbl file using the -lib option. The [legacy D. melanogaster-only FASTA file](https://github.com/bergmanlab/transposons/blob/master/misc/D_mel_transposon_sequence_set.fa)
provided in the `misc` directory of this repository is now deprecated, but
preserved for posterity.

We thank Margi Butler, Elena Casacuberta, Madeline Crosby, Bob Levis,
Mary-Lou Pardue, Kevin O'Hare, Horacio Naveira, Dmitri Petrov, Steve
Schaeffer, Todd Schlenke, Alfredo Villesante & the authors of REPBASE for
sequences and/or annotations. We thank Nicholas Davies and Portia Hollyoak for
contributions to this repository.
