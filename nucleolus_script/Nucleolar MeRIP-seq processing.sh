cd $read_dir

############################ 1. fastq/fq

mkdir -p 01.RawData/qc 01.RawData/log
fastqc --noextract -t $threads -f fastq 01.RawData/${name}/${name}*fq.gz -o 01.RawData/qc/ > 01.RawData/log/${name}_fastqc.log 2>&1 &

############################## 2. trim_galore
mkdir -p ./clean/${name}
trim_galore -j 20 --length 20 --quality 20 --output_dir ./clean/$name/ --fastqc --paired 01.RawData/${name}/*1.fq.gz 01.RawData/${name}/*2.fq.gz

############################ 3. remove ployN
cd clean/${name}
cutadapt -j 20 -a "A{100}" -a "G{100}" -a "C{100}" -a "T{100}" -A "A{100}" -A "G{100}" -A "C{100}" -A "T{100}" -n 3 --minimum-length=20 -e 0.1 -o ${name}_1.rmploy.fq  -p ${name}_2.rmploy.fq ${name}*val_1.fq.gz ${name}*val_2.fq.gz

############################# 4. remove pcr duplications

touch ${name}_1.rmploy_U.fq
touch ${name}_2.rmploy_U.fq

cd ../../

mkdir -p ./script
perl remove_PCR_duplicates.pl \
clean/${name}/${name}_1.rmploy.fq \
clean/${name}/${name}_2.rmploy.fq \
clean/${name}/${name}_1.rmploy_U.fq \
clean/${name}/${name}_2.rmploy_U.fq ./clean/${name}/ > script/${name}_step0.run1.sh

sh script/${name}_step0.run1.sh

mv clean/${name}/read1.clean.rmDup.fq  clean/${name}/${name}_1.clean.rmDup.fq
mv clean/${name}/read2.clean.rmDup.fq  clean/${name}/${name}_2.clean.rmDup.fq

gzip ./clean/${name}/${name}*.clean.rmDup.fq

############################# 5. Remove tophat-rRNA
mkdir -p ./align_rRNA_tophat2/${name}

tophat -p 20 -o align_rRNA_tophat2/${name} /reference/bowtie2/hg19_rRNA/hg19_rRNA clean/${name}/${name}_1.clean.rmDup.fq.gz clean/${name}/${name}_2.clean.rmDup.fq.gz 


cd ./align_rRNA_tophat2/${name}

samtools sort -n -@ 20 -o unmapped.sort.bam unmapped.bam
samtools fastq -1 unmapped_1.fq -2 unmapped_2.fq -s /dev/null -0 /dev/null unmapped.sort.bam
cd ../../

################################# 6. Tophat ref genome
mkdir -p ./align_ref_tophat2/${name}

tophat -p 20 -o align_ref_tophat2/${name} /reference/bowtie2/hg19/hg19 ./align_rRNA_tophat2/${name}/unmapped_1.fq ./align_rRNA_tophat2/${name}/unmapped_2.fq

cd ./align_ref_tophat2/${name}
samtools sort -@ 20 accepted_hits.bam -o accepted_hits.sort.bam
samtools index accepted_hits.sort.bam

###################################### 7. forward & reverse strand
cd ./align_ref_tophat2/${name}

###### forward strand
samtools view -b -f 128 -F 16 accepted_hits.sort.bam > fwd1.bam 
samtools index fwd1.bam

samtools view -b -f 80 accepted_hits.sort.bam > fwd2.bam
samtools index fwd2.bam

samtools merge -f fwd.bam fwd1.bam fwd2.bam
samtools index fwd.bam
rm fwd1.bam fwd2.bam

###### reverse strand
samtools view -b -f 144 accepted_hits.sort.bam > rev1.bam
samtools index rev1.bam

samtools view -b -f 64 -F 16 accepted_hits.sort.bam > rev2.bam
samtools index rev2.bam

samtools merge -f rev.bam rev1.bam rev2.bam
samtools index rev.bam
rm rev1.bam rev2.bam

