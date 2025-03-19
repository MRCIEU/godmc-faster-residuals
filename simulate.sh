#!/bin/bash

# Simulate phenotype data

bfile="/local-scratch/data/alspac/1kg_bestguess_filtered/data"
# bfile="data/data"
bfile="/mnt/storage/private/alspacdata/datasets/dataset_gi_1000g_g0m_g1/released/2015-10-30/data/derived/filtered/bestguess/maf0.01_info0.8/combined/data"
nsim=10

# gcta64 --bfile $bfile --simu-qt --simu-hsq 0.4 --simu-rep $nsim --out phen

# echo "FID" > head.txt
# echo "IID" >> head.txt
# for i in $(seq 1 $nsim); do
# echo "X$i" >> head.txt
# done
# tr '\n' '\t' < head.txt > head2.txt
# cat head2.txt phen.phen > phen.txt

mkdir -p out/sim
> out/cischr

for i in $(seq 1 $nsim); do
    # shuf -n 1000 $bfile.bim | awk '{ print $2, $5, rand() }' > out/sim/score$i.txt
    # plink2 --bfile $bfile --score out/sim/score$i.txt --out out/sim/score$i
    for j in {1..100}; do
        echo "5" >> out/cischr
    done
done

ls -l out/sim

Rscript -e '
library(data.table)
library(dplyr)
i <- 1
nsim_per_score <- 100
x <- lapply(1:10, \(i) {
    a <- fread(paste0("out/sim/score", i, ".sscore"))
    b <- lapply(1:nsim_per_score, \(j) {
        a$resid <- rnorm(nrow(a), 0, sqrt(var(a$SCORE1_AVG)))
        a$phen <- a$SCORE1_AVG + a$resid
        a <- tibble(phen = a$phen)
        names(a) <- paste0("X", i, "_", j)
        return(a)
    }) %>% bind_cols()
    return(b)
}) %>% bind_cols()

x
a <- fread(paste0("out/sim/score", 1, ".sscore")) %>% select("#FID", "IID")
names(a) <- c("FID", "IID")
a <- bind_cols(a, x)
write.table(a, file="out/phen.txt", row=F, col=T, qu=F)
'

plink2 --bfile $bfile --indep-pairwise 2000 50 0.03 --out out/indep
plink2 --bfile $bfile --extract out/indep.prune.in --make-bed --out out/indep