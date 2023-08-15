library(rstan)
library(bayesplot)
library(stargazer)
library(xtable)

options(mc.cores=parallel::detectCores())
load("data-original.RData")

################################################################################
################################################################################

fit_RE <- readRDS("../model_original/model-original.rds")
fit_FE <- readRDS("model-fixed-effects.rds")

bias <- extract(fit_RE, "bias_source_type_mu")[["bias_source_type_mu"]]
bias_mean <- apply(bias, c(2,3), FUN=function(x)mean(exp(x)))
bias_se <- apply(bias, c(2,3), FUN=function(x)sd(exp(x)))
bias_lc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.025))
bias_uc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.975))
rownames(bias_mean) <- rownames(bias_lc) <- rownames(bias_uc) <- rownames(bias_se) <- levels(data$claim_source)
colnames(bias_mean) <- colnames(bias_lc) <- colnames(bias_uc) <- colnames(bias_se) <- apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-'))
dimnames(bias) <- list(1:dim(bias)[1], levels(data$claim_source), apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-')))
print(bias_mean)

bias_FE <- extract(fit_FE, "bias_source_type_mu")[["bias_source_type_mu"]]
bias_mean_FE <- apply(bias_FE, c(2,3), FUN=function(x)mean(exp(x)))
bias_se_FE <- apply(bias_FE, c(2,3), FUN=function(x)sd(exp(x)))
bias_lc_FE <- apply(bias_FE, c(2,3), FUN=function(x)quantile(exp(x),0.025))
bias_uc_FE <- apply(bias_FE, c(2,3), FUN=function(x)quantile(exp(x),0.975))
rownames(bias_mean_FE) <- rownames(bias_lc_FE) <- rownames(bias_uc_FE) <- rownames(bias_se_FE) <- levels(data$claim_source)
colnames(bias_mean_FE) <- colnames(bias_lc_FE) <- colnames(bias_uc_FE) <- colnames(bias_se_FE) <- apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-'))
dimnames(bias_FE) <- list(1:dim(bias_FE)[1], levels(data$claim_source), apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-')))
print(bias_mean_FE)

############################################
## OUTPUT GAMMA MEANS                     ##
############################################
sub <- data[!data$category %in% c("Aircraft (unspecified)",
                                  "Ships",
                                  "Tanks & Armored Combat Vehicles",
                                  "Special Military Motor Vehicles",
                                  "Vehicles & Fuel Tanks"),]

# pdf("all_biases.pdf", width=8, height=11)
par(mar=c(5.1,0.1,0.1,0.1), mfrow=c(1,1))
plot(0,0,
     xlim=c(-10,25),
     ylim=c(length(unique(paste(sub$category,sub$loss_country,sub$claim_source,sep="-")))+1, 0),
     type="n",
     frame=F,
     yaxt="n",
     ylab=NA,
     xlab="Bias (scalar)",
     yaxs="i")
ii <- 1
for(row in rownames(bias_mean)){
  for(col in colnames(bias_mean)){
    n <- nrow(sub[paste(sub$category,sub$loss_country,sep="-")==col & sub$claim_source==row,])
    if(n > 0)
    {
      highlight <- "gray"
      if(bias_lc[row,col] > 1)
        highlight <- "red"
      if(bias_uc[row,col] < 1)
        highlight <- "blue"
      points(bias_mean[row,col],ii,pch=16,cex=0.5, col=highlight)
      points(bias_mean_FE[row,col],ii+0.25,pch=16,cex=0.5,col="orange")
      segments(bias_uc[row,col],ii,bias_lc[row,col],ii, col=highlight)
      segments(bias_uc_FE[row,col],ii+0.25,bias_lc_FE[row,col],ii+0.25, col="orange")
      text(paste(row,col,sep="-"),x=-1,y=ii,cex=0.5,pos=2)
      ii <- ii+1
    }
  }
}
abline(v=1,lty=2)
# dev.off()

#################################################
## BIASES OF INTEREST DENSITY PLOTS
#################################################

sub <- data[(data$category %in% c("Military Deaths"))
            & (data$claim_source) %in% c("GB Source",
                                         "OSI",
                                         "Other",
                                         "United Nations",
                                         "US Source",
                                         "UA Source",
                                         "RU Source"),]

pdf("fe_biases.pdf", width=8, height=10)
par(mar=c(5.1,0.1,0.1,0.1), mfrow=c(1,1))
plot(0,0,
     xlim=c(-8,5),
     ylim=c(0.5,length(unique(paste(sub$category,sub$loss_country,sub$claim_source,sep="-")))+2),
     type="n",
     frame=F,
     yaxt="n",
     ylab=NA,
     xlab="ln(bias)",
     yaxs="i")
abline(v=0,lty=2)
ii <- length(unique(paste(sub$category,sub$loss_country,sub$claim_source,sep="-")))
for(row in rownames(bias_mean)){
  for(col in colnames(bias_mean)){
    n <- nrow(sub[paste(sub$category,sub$loss_country,sep="-")==col & sub$claim_source==row,])
    if(n > 0)
    {
      highlight <- "#999999"
      if(bias_lc[row,col] > 1)
        highlight <- "#FF0000"
      if(bias_uc[row,col] < 1)
        highlight <- "#0000FF"
      
      if((row %in% c("RU Source","UA Source")) & (col %in% c("Military Deaths-Russia","Military Deaths-Ukraine")))
      {
        rect(-8,ii,5,ii+0.9,col="#eeeeee",border=NA)
        segments(0,ii,0,ii+1,lty=2)
        text(3,ii+0.75,sprintf("%.2fx",mean(exp(bias[,row,col]))), cex=0.75, col="red")
        text(3,ii+0.25,sprintf("%.2fx",mean(exp(bias_FE[,row,col]))), cex=0.75, col="blue")
      }
      
      x <- density((bias[,row,col]))$x
      y <- density((bias[,row,col]))$y
      polygon(c(x,rev(x)),
              c(y+ii,rep(ii,length(x))),
              col="#FF9999")
      
      
      x <- density((bias_FE[,row,col]))$x
      y <- density((bias_FE[,row,col]))$y
      polygon(c(x,rev(x)),
              c(y+ii,rep(ii,length(x))),
              col="#6666FF66")
      
      text(paste(row,paste0(gsub("-"," (",col),")"),sep=", "),x=-8,y=ii+0.25,cex=1,pos=4)
      ii <- ii-1
    }
  }
}
text(2,2.75,"Original Model",col="red",pos=4)
text(2,2.25,"Fixed Effects",col="#6666FF",pos=4)
dev.off()



