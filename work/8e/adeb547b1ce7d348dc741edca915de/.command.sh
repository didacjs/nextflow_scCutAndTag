#!/bin/bash -ue
macs2 callpeak -t "possorted_bam.bam" -g mm -f BAMPE -n "S1" --outdir "S1_peaks.narrowPeak" -q 0.05 -B --SPMR --keep-dup=1
macs2 callpeak -t "possorted_bam.bam" -g mm -f BAMPE -n "S1" --outdir "S1_peaks.broadPeak" -q 0.05 -B --SPMR --keep-dup=1 --broad-cutoff=0.1 --broad
