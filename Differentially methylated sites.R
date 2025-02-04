library(exomePeak2)
set.seed(1)

input_NoNC <- dir()[c(3,4)]# inputcontrol
ip_NoNC <- dir()[c(7,8)]# ipcontrol
input_NoM3 <- dir()[c(1,2)]# inputtreat
ip_NoM3 <- dir()[c(5,6)]# ip treat


library(BSgenome.Hsapiens.UCSC.hg19)
dir.create('result_exomepeak2')
exomePeak2(bam_ip = ip_NoNC,
           bam_input = input_NoNC,
           bam_ip_treated = ip_NoM3,
           bam_input_treated = input_NoM3,
           save_dir = 'result_exomepeak2',
           gff ="/reference/human/GRch37/hg19.refGene.gtf", 
           genome = "hg19", 
           strandness = "1st_strand",
           parallel = 1,
           mode="full_transcript",
           fragment_length = 150)