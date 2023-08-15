library(narray)

bias <- read.csv("biases_ua.csv",header=F,stringsAsFactors=F)
cum_losses <- read.csv("cum_losses_ua.csv",header=F,stringsAsFactors=F)

bias <- as.data.frame(t(bias))
cum_losses <- as.data.frame(t(cum_losses))

##############################################
## BIAS BOXPLOTS                            ##
##############################################
pdf("ua_rep_bias.pdf",width=9,height=3)
par(mfrow=c(1,1), mar=c(2.1,4.1,0.1,0.1))
plot(1:20,1:20,
     xlim=c(1,20),
     ylim=c(-4,3),
     type="n",
     xlab=NA,
     ylab="ln(Bias scalar)",
     las=1,
     xaxt="n",
     main=NA)
axis(1, at=1:20, labels=t(rep(c("1x","2x","3x","4x","5x"),4)))
rect(0,-5,5.5,4,col="#EEEEEE",border=NA)
rect(5.5,-5,10.5,4,col="#FFFFFF",border=NA)
rect(10.5,-5,15.5,4,col="#EEEEEE",border=NA)
rect(15.5,-5,20.5,4,col="#FFFFFF",border=NA)
abline(v=c(5.5,10.5,15.5))
jj <- 1
for(cc in unique(c(bias[2,]))){
  for(tt in unique(c(bias[3,]))){
    sub <- bias[, bias[2,]==cc & bias[3,]==tt]
    text(jj+2, -3, cc)
    text(jj+2, -3.5, gsub("-",", ",tt))
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
pdf("ua_rep_loss.pdf",width=9,height=3)
par(mfrow=c(1,1), mar=c(2.1,4.1,0.1,0.1))
plot(1:20,1:20,
     xlim=c(1,20),
     ylim=c(4,13),
     type="n",
     xlab=NA,
     ylab="ln(Cumulative losses)",
     las=1,
     xaxt="n",
     main=NA)
axis(1, at=1:20, labels=t(rep(c("1x","2x","3x","4x","5x"),4)))
rect(0,-5,5.5,14,col="#EEEEEE",border=NA)
rect(5.5,-5,10.5,14,col="#FFFFFF",border=NA)
rect(10.5,-5,15.5,14,col="#EEEEEE",border=NA)
rect(15.5,-5,20.5,14,col="#FFFFFF",border=NA)
abline(v=c(5.5,10.5,15.5))
jj <- 1
for(cc in unique(c(cum_losses[2,]))){
    sub <- cum_losses[, cum_losses[2,]==cc]
    text(jj+2, 4, gsub("-",", ",cc))
    for(ii in 1:ncol(sub)){
      boxplot(as.numeric(sub[4:nrow(sub),ii]), add=T, at=c(jj), pch=".", yaxt="n")
      jj <- jj + 1
    }
}
dev.off()
