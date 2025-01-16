#!/bin/bash -ue
bamCoverage -b "possorted_bam.bam" -o "S1_allReads.bw" -p "4" --minMappingQuality 5  --binSize 100 --centerReads --smoothLength 500 --normalizeUsing RPKM --ignoreDuplicates
