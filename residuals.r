library(dplyr)
library(data.table)
library(parallel)

args <- commandArgs(T)

# phen_file <- "out/phen.txt"
# pred_list_file <- "out/sim1_pred.list"
# threads <- 10


phen_file <- args[1]
cis_chr_file <- args[2]
pred_list_file <- args[3]
out_file <- args[4]
threads <- as.numeric(args[5])


phen <- fread(phen_file) %>% as.data.frame()
pred_list <- fread(pred_list_file, header=FALSE)
cis_chr <- scan(cis_chr_file, what=numeric())
nphen <- ncol(phen) - 2

o <- mclapply(1:nphen, \(i) {
    x <- fread(pred_list$V2[i], header=TRUE)[,-1] %>% as.matrix()
    cischr <- cis_chr[i]
    x <- x[cischr, ]
    stopifnot(all(names(x) == paste(phen$FID, phen$IID, sep="_")))
    residuals(lm(phen[,i+2] ~ x))
}, mc.cores=threads) %>% bind_cols()
names(o) <- pred_list$V1

o <- bind_cols(phen[,1:2], o)

fwrite(o, file=out_file, row=F, col=T, qu=F)
