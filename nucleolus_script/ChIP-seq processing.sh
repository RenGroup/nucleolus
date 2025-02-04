cd $read_dir

################# trim
mkdir -p clean/${name}
trim_galore -j 20 --length 10 --quality 20 --output_dir clean/${name} --fastqc --paired 01.RawData/${name}/*1.fq.gz 01.RawData/${name}/*2.fq.gz


################# bowtie2

mkdir -p align_rDNA/${name}
bowtie2 -p 20 -x /work/home/liuyun/reference/bowtie2/hg19_rDNA_fulllen/hg19_rDNA -1 ./clean/${name}/*1_val_1.fq.gz -2 ./clean/${name}/*2_val_2.fq.gz 2> ./align_rDNA/${name}/bowtie2.rDNA.log| samtools sort -O bam -@ 20 -o - > ./align_rDNA/${name}/${name}.rDNA.bam
samtools flagstat -@ 20 ./align_rDNA/${name}/${name}.rDNA.bam >./align_rDNA/${name}/${name}.rDNA.flagstat.log

################## Q20 rmDup
mkdir -p align_rDNA/bw
cd align_rDNA/${name}


## Q20
samtools view -h -q 20 ${name}.rDNA.bam > ${name}.rDNA.q20.bam
samtools flagstat -@ 20 ${name}.rDNA.q20.bam > ${name}.rDNA.q20.flagstat.log

## rmdup
gatk MarkDuplicates -I ${name}.rDNA.q20.bam --ADD_PG_TAG_TO_READS false --REMOVE_SEQUENCING_DUPLICATES true --CREATE_INDEX true -O ${name}.rDNA.q20.rmdup.bam -M ${name}.rDNA.q20.rmdup.matrix.txt 
samtools flagstat -@ 20 ${name}.rDNA.q20.rmdup.bam>${name}.rDNA.q20.rmdup.flagstat.log

bamCoverage --bam ${name}.rDNA.q20.rmdup.bam -o ../bw/${name}.rDNA.RPKM.bin10.bw --binSize 10 --normalizeUsing RPKM

cd ../..
