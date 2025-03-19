#!/bin/bash

# A single file that has approx 50k variants genome wide following LD pruning
bfile="out/indep"

# Generate the PRS values for each trait
regenie \
    --bed $bfile \
    --phenoFile out/phen.txt \
    --step 1 \
    --bsize 100 \
    --out out/sim2 \
    --lowmem \
    --pred out/sim2_pred.list \
    --threads 10

# Generate the residuals
Rscript residuals.r \
    out/phen.txt \
    out/cischr \
    out/sim2_pred.list \
    out/phen_residuals.txt \
    10
