cd $read_dir

######## 1. qc
mkdir -p 01.RawData/qc
fastqc -t 6 -o 01.RawData/qc 01.RawData/**/***.fq.gz &


######## 2. trim
mkdir -p ./clean
trim_galore -j 20 --length 10 --quality 20 --output_dir ./clean/${name}/ --fastqc --clip_R2 5 --clip_R1 29 --paired ./01.RawData/${name}/*1.fq.gz ./01.RawData/${name}/*2.fq.gz
gunzip clean/*/*.fq.gz


######## 3. fastuniq rmdup
cd ./clean/${name}

# remove pcr duplication
find . -type f -name "*_val_*.fq" -print0 | xargs -0 -I {} echo {} >> input.txt
/work/home/liuyun/Biosoft/FastUniq/source/fastuniq -i input.txt -o R1.uniq.fq -p R2.uniq.fq

# remove low-quality
trim_galore -j 20 --length 10 --quality 20 --output_dir ./ --fastqc --clip_R1 8 --paired ./R1.uniq.fq ./R2.uniq.fq 

cd ../..

######## 4. reactivity

mkdir -p shapemapper/${name_NAI}
cd shapemapper/${name_NAI}

/work/home/liuyun/Biosoft/shapemapper2/shapemapper --modified \
--R1 ../../clean/${name_NAI}/R1.uniq_val_1.fq \
--R2 ../../clean/${name_NAI}/R2.uniq_val_2.fq \
--untreated --R1 ../../clean/${name_DMSO}/R1.uniq_val_1.fq \
--R2 ../../clean/${name_DMSO}/R2.uniq_val_2.fq \
--target /work/home/liuyun/RIC/genome/star/star_2.7.7a_rDNA_fulllen_RN7SK/RN7SK_2.fa --nproc 16 --min-depth 100 --amplicon --output-counted-mutations --per-read-histograms --output-parsed-mutations 
cd ..

############# RNA fold
cd $name

head -n -20 ./shapemapper_out/Pipeline_RN7SK.shape | tail -n +20 > Pipeline_RN7SK_2.shape

RNAfold -p -d2 --id-prefix ${name1}_${i} --shape=./Pipeline_RN7SK_2.shape --shapeMethod=D < 7sk.seq >./${name}.dbn
