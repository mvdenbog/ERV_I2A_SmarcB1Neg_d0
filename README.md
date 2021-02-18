# ERV_I2A_SmarcB1Neg_d0

## running:

~/nextflow -c /data/users/mvanden1/NextFlow/ERV_I2A_SmarcB1Neg_d0/my.config run /data/users/mvanden1/NextFlow/ERV_I2A_SmarcB1Neg_d0/main4.nf --indir /data/tmp/mvanden1/ERV_I2A_SmarcB1Neg_d0/ --outdir /data/tmp/mvanden1/ERV_I2A_SmarcB1Neg_d0/Results --scriptdir /data/users/mvanden1/NextFlow/ERV_I2A_SmarcB1Neg_d0/scripts/ --gtf1 /data/users/mvanden1/Analysis_1092/DataMathias/References/Ensembl/HomoSapiens/Homo_sapiens.GRCh38.100.gtf --gtf2 /data/users/mvanden1/Analysis_1092/DataMathias/RepeatMasker/hg38.fa.out.gff --fasta /data/users/mvanden1/Analysis_1092/DataMathias/References/Ensembl/HomoSapiens/Homo_sapiens.GRCh38.dna.primary_assembly.fa  --reads /data/users/mvanden1/NextFlow/ERV_I2A_SmarcB1Neg_d0/reads_erv_I2A.csv   -with-singularity /data/tmp/mvanden1/Singularity/image.sif  -profile singularity,cluster -resume

# reads file:
cat /data/users/mvanden1/NextFlow/ERV_I2A_SmarcB1Neg_d0/reads_erv_I2A.csv

Sample_Name,Read1,Read2
A120T1,/data/users/mvanden1/Analysis_643/I2A_CopyData/A120T1_R1.fastq,/data/users/mvanden1/Analysis_643/I2A_CopyData/A120T1_R2.fastq
A120T2,/data/users/mvanden1/Analysis_643/I2A_CopyData/A120T2_R1.fastq,/data/users/mvanden1/Analysis_643/I2A_CopyData/A120T2_R2.fastq
A120T3,/data/users/mvanden1/Analysis_643/I2A_CopyData/A120T3_R1.fastq,/data/users/mvanden1/Analysis_643/I2A_CopyData/A120T3_R2.fastq

