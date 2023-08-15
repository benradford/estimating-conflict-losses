library("narray")

bias <- read.csv("biases.csv",header=F,stringsAsFactors=F)
cum_losses <- read.csv("cum_losses.csv",header=F,stringsAsFactors=F)

bias <- as.data.frame(t(bias))
cum_losses <- as.data.frame(t(cum_losses))

##############################################
## BIAS BOXPLOTS                            ##
##############################################
pdf("bias_priors_on_bias.pdf",width=10,height=5)
par(mfrow=c(1,1), mar=c(10,4.1,0.1,0.1))
plot(1:16,1:16,
     xlim=c(1,16),
     ylim=c(-5,5),
     type="n",
     xlab=NA,
     ylab="ln(Bias Scalar)",
     las=1,
     xaxt="n",
     main=NA)
axis(1, at=1:16, labels=t(rep(c("Original","Single Level","Original + Hyperprior","Single + Hyperprior"),4)), las=2)
rect(0,-15,4.5,14,col="#EEEEEE",border=NA)
rect(4.5,-15,8.5,14,col="#FFFFFF",border=NA)
rect(8.5,-15,12.5,14,col="#EEEEEE",border=NA)
rect(12.5,-15,16.5,14,col="#FFFFFF",border=NA)
abline(v=c(4.5,8.5,12.5))
jj <- 1
for(cc in unique(c(bias[2,]))){
  for(tt in unique(c(bias[3,]))){
    sub <- bias[, bias[2,]==cc & bias[3,]==tt]
    text(jj+1.5, -4, cc)
    text(jj+1.5, -5, gsub("-",", ",tt))
    for(ii in 1:ncol(sub)){
      boxplot(as.numeric(sub[4:nrow(sub),ii]), add=T, at=c(jj), pch=".", yaxt="n")
      jj <- jj + 1
    }
  }
}
dev.off()

##############################################
## CUM LOSSES BOXPLOTS                      ##
##############################################
pdf("bias_priors_on_losses.pdf",width=10,height=5)
par(mfrow=c(1,1), mar=c(10,4.1,0.1,0.1))
plot(1:16,1:16,
     xlim=c(1,16),
     ylim=c(1,14),
     type="n",
     xlab=NA,
     ylab="ln(Cumulative Losses)",
     las=1,
     xaxt="n",
     main=NA)
axis(1, at=1:16, labels=t(rep(c("Original","Single Level","Original + Hyperprior","Single + Hyperprior"),4)), las=2)
rect(0,-5,4.5,15,col="#EEEEEE",border=NA)
rect(4.5,-5,8.5,15,col="#FFFFFF",border=NA)
rect(8.5,-5,12.5,15,col="#EEEEEE",border=NA)
rect(12.5,-5,16.5,15,col="#FFFFFF",border=NA)
abline(v=c(4.5,8.5,12.5))
jj <- 1
for(cc in unique(c(cum_losses[2,]))){
    sub <- cum_losses[, cum_losses[2,]==cc]
    text(jj+1.5, 2, gsub("-",", ",cc))
    for(ii in 1:ncol(sub)){
      boxplot(as.numeric(sub[4:nrow(sub),ii]), add=T, at=c(jj), pch=".", yaxt="n")
      jj <- jj + 1
    }
}
dev.off()
