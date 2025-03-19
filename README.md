# Adjust CpG sites for kinship

## Background

The residuals in a linear mixed model are obtained from

$$
y = u + e
$$

where $u \sim (N(0, \sigma^2_a K))$ and $K = \frac{1}{M}XX^T$. This can be approximated in regenie where ridge regression is used to estimate the genetic value $u$, in the following:

$$
y = X\beta + e
$$

We use step 1 of the regenie process to obtain the scores $X\beta$. 

A benefit of this approach is that a lot of the calculation of $X\beta$ is identical across phenotypes, meaning that it is fast to perform it on a large number of phenotypes.

Note that regenie estimates a different score for each chromosome, where that chromosome is left out to avoid the score removing genetic variants. The scripts here expect that a file is provided that lists the cis-chromosome for each CpG site so that the cis chromosome is chosen to be left out. There is a slight risk that this may lead to some slightly attenuated power for a trans signal, but not necessarily any more than would occur when doing a standard LMM from kinship data.

## Expected input

- LD pruned genotype data in plink format (a single dataset combining all chromosomes, and LD pruned to ~50k SNPs)
- A phenotype file with the following structure

```
FID IID cg11 cg22 ...
1   1   0.23 0.54
2   2   0.15 0.76
...
```

- A cis chromosome file with a single line per CpG site that lists its chromosome location (1-23)
- Number of threads

## Batching

The phenotype file that goes into this script can be a subset of all phenotypes, hence if there are 850k CpG sites, it's possible to split the phenotype file into `N` chunks and run this analysis script on each chunk in parallel on a cluster. 

## Runtime

- 17.5k ALSPAC samples
- 1000 phenotypes
- 10 cores
- 3Gb RAM
- 72 minutes

Repeated with 2k samples = 24 minutes.

## To run

- `simulate.sh` - This takes a plink dataset (single file for all chromosomes) and simulates 1000 phenotypes, then LD prunes the plink dataset
- `analysis.sh` - This generates the scores using regenie from the phenotype data and LD pruned genotypes, and then generates the residuals by calling `residuals.r`.

