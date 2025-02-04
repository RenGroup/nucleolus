cd $name
head -n 3 ./${name}.dbn > temp && mv temp ./${name}_2.dbn
sed -i 's/ (-[0-9].*$//' ${name}_2.dbn
dot2ct ./${name}_2.dbn ./${name}.ct

grep "ubox" ${name}_0001_dp.ps | awk '{print $1, $2, $3}' | sed '1,2d' > ./${name}_matrix.dp
awk '/\/pairs \[/,/\] def/' ${name}_0001_ss.ps | tr -d '[]' | sed '1d;$d' > ${name}_pairing.txt
awk 'NR==FNR {pairs[$1,$2]=1; next} (($1,$2) in pairs)' ${name}_pairing.txt ${name}_matrix.dp| awk '{$3 = -log($3)/log(10); print}'|sed '1i 332'|sed '2i i j prob' > ./${name}.dp
rm ${name}_matrix.dp ${name}_pairing.txt

python arcPlot.py --fasta ./RN7SK.fa --ct ./${name}.ct --probability ./${name}.dp,0.1,0.3,0.8,1.0 --profile ./shapemapper_out/Pipeline_RN7SK.shape ${name}_arcPlot.pdf --bottom
