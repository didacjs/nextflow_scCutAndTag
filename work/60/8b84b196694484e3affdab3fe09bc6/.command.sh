#!/bin/bash -ue
samtools index 'possorted_bam.bam'
bamCoverage -b 'possorted_bam.bam' -o "/home/didac/Work/Misc/CutAndTag/Code/S1_bigwig/" -p "4" --minMappingQuality 5  --binSize 100 --centerReads --smoothLength 500 --normalizeUsing RPKM --ignoreDuplicates
