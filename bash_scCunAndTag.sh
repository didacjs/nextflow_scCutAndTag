#!bin/bash
ANALYSIS_NAME=24-12-13
OUTPUT_DIR="/home/didac/Work/Misc/CutAndTag/Results/25-12-13"
CELLRANGER_OUT="/home/didac/Work/Misc/CutAndTag/Data/xdd/outs"
THREADS=4
SCRIPT_DIR=/home/didac/Work/Misc/CutAndTag/scCut-Tag_2020/scCut-Tag_2020/scripts

bam=$CELLRANGER_OUT/possorted_bam.bam
bigwig_dir=$OUTPUT_DIR/bigwig/all_reads.bw
# mkdir -p $bigwig_dir
bamCoverage -b $bam -o $bigwig_dir -p $THREADS --minMappingQuality 5  --binSize 100 --centerReads --smoothLength 500 --normalizeUsing RPKM --ignoreDuplicates

# MACS
macsNarrow_dir=$OUTPUT_DIR/MACS/macs_narrow
macsBroad_dir=$OUTPUT_DIR/MACS/macs_broad
macsNarrow=$macsNarrow_dir/${ANALYSIS_NAME}_peaks.narrowPeak
macsBroad=$macsBroad_dir/${ANALYSIS_NAME}_peaks.broadPeak
mkdir -p $macsNarrow_dir $macsBroad_dir
macs2 callpeak -t $bam -g mm -f BAMPE -n $ANALYSIS_NAME --outdir $macsNarrow_dir -q 0.05 -B --SPMR --keep-dup=1 2>&1
macs2 callpeak -t $bam -g mm -f BAMPE -n $ANALYSIS_NAME --outdir $macsBroad_dir -q 0.05 -B --SPMR --keep-dup=1 --broad-cutoff=0.1 --broad 2>&1

# Barcode statistics
barcode_statistics_dir=$OUTPUT_DIR/barcode_statistics
barcode_statistics_narrow=$barcode_statistics_dir/peaks_barcodes_narrow.txt
barcode_statistics_broad=$barcode_statistics_dir/peaks_barcodes_broad.txt
barcode_statistics_all=$barcode_statistics_dir/all_barcodes.txt
# mkdir -p $barcode_statistics_dir
# bedtools intersect -abam $bam -b $macsBroad -u | samtools view -f2 | \
# awk -f $SCRIPT_DIR/get_cell_barcode.awk | sed 's/CB:Z://g' | sort | uniq -c > $barcode_statistics_broad && [[ -s $barcode_statistics_narrow ]]  
# bedtools intersect -abam $bam -b $macsNarrow -u | samtools view -f2 | 
# awk -f $SCRIPT_DIR/get_cell_barcode.awk | sed 's/CB:Z://g' | sort | uniq -c > $barcode_statistics_narrow && [[ -s $barcode_statistics_narrow ]]
# samtools view -f2 $bam | awk -f $SCRIPT_DIR/get_cell_barcode.awk | sed 's/CB:Z://g' | sort | uniq -c > $barcode_statistics_all && [[ -s $barcode_statistics_all ]]

# Add barcode fragments
input_fragments=$CELLRANGER_OUT/fragments.tsv.gz
output_fragments=$OUTPUT_DIR/fragments.tsv.gz
output_fragments_index=$OUTPUT_DIR/fragments.tsv.gz.tbi
python3 $SCRIPT_DIR/add_sample_to_fragments.py $input_fragments $ANALYSIS_NAME | bgzip > $output_fragments
tabix -p bed $output_fragments