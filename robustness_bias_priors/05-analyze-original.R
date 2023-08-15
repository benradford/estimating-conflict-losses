library(rstan)
library(bayesplot)
library(stringr)
library(stargazer)
library(xtable)

load("data-original.RData")
fit <- readRDS("model-original.rds")

num_days <- max(c(data$days, data_daily$days))
daily_num_obs <- nrow(data_daily)
cum_num_obs <- nrow(data)
standata <- list(
  "num_days"=num_days,
  "num_loss_type"=length(unique(c(data$loss_type,data_daily$loss_type))),
  "num_loss_country"=2,
  "num_claim_source"=length(unique(data$claim_source)),
  "cum_num_obs"=cum_num_obs,
  "daily_num_obs"=daily_num_obs,
  "num_category"=length(levels(data$category)),
  
  "cum_day"=data$days,
  "cum_count"=data$loss_count_min,
  "cum_loss_type"=as.numeric(data$loss_type),
  "cum_claim_source"=as.numeric(data$claim_source),
  "cum_loss_country"=as.numeric(as.factor(data$loss_country)),
  "cum_category"=as.numeric(data$category),
  "cum_min"=as.numeric(data$minimum),
  "cum_max"=as.numeric(data$maximum),
  
  "daily_count"=data_daily$loss_count_min,
  "daily_day"=data_daily$days,
  "daily_loss_type"=as.numeric(data_daily$loss_type),
  "daily_claim_source"=as.numeric(data_daily$claim_source),
  "daily_loss_country"=as.numeric(as.factor(data_daily$loss_country)),
  "daily_category"=as.numeric(data_daily$category),
  "daily_min"=as.numeric(data_daily$minimum),
  "daily_max"=as.numeric(data_daily$maximum)
)

################################################################################
################################################################################



obs_cum_post_pred <- extract(fit, "obs_cum_post_pred")[["obs_cum_post_pred"]]
obs_cum_post_pred_mean <- apply(obs_cum_post_pred, c(2), mean)
obs_cum_post_pred_median <- apply(obs_cum_post_pred, c(2), median)
obs_cum_post_pred_lc <- apply(obs_cum_post_pred, c(2), FUN=function(x) quantile(x, 0.025, na.rm=T))
obs_cum_post_pred_uc <- apply(obs_cum_post_pred, c(2), FUN=function(x) quantile(x, 0.975, na.rm=T))

obs_daily_post_pred <- extract(fit, "obs_daily_post_pred")[["obs_daily_post_pred"]]
obs_daily_post_pred_mean <- apply(obs_daily_post_pred, c(2), mean)
obs_daily_post_pred_median <- apply(obs_daily_post_pred, c(2), median)
obs_daily_post_pred_lc <- apply(obs_daily_post_pred, c(2), FUN=function(x) quantile(x, 0.025, na.rm=T))
obs_daily_post_pred_uc <- apply(obs_daily_post_pred, c(2), FUN=function(x) quantile(x, 0.975, na.rm=T))

unbiased_cum_post_pred <- extract(fit, "unbiased_cum_post_pred")[["unbiased_cum_post_pred"]]
unbiased_cum_post_pred_mean <- apply(unbiased_cum_post_pred, c(2,3), FUN=function(x) mean(x, na.rm=T))
unbiased_cum_post_pred_median <- apply(unbiased_cum_post_pred, c(2,3), FUN=function(x) median(x, na.rm=T))
unbiased_cum_post_pred_lc <- apply(unbiased_cum_post_pred, c(2,3), FUN=function(x) quantile(x, 0.025, na.rm=T))
unbiased_cum_post_pred_uc <- apply(unbiased_cum_post_pred, c(2,3), FUN=function(x) quantile(x, 0.975, na.rm=T))

unbiased_daily_post_pred <- extract(fit, "unbiased_daily_post_pred")[["unbiased_daily_post_pred"]]
unbiased_daily_post_pred_mean <- apply(unbiased_daily_post_pred, c(2,3), FUN=function(x) mean(x, na.rm=T))
unbiased_daily_post_pred_median <- apply(unbiased_daily_post_pred, c(2,3), FUN=function(x) median(x, na.rm=T))
unbiased_daily_post_pred_lc <- apply(unbiased_daily_post_pred, c(2,3), FUN=function(x) quantile(x, 0.025, na.rm=T))
unbiased_daily_post_pred_uc <- apply(unbiased_daily_post_pred, c(2,3), FUN=function(x) quantile(x, 0.975, na.rm=T))

unbiased_cum_mean <- extract(fit, "unbiased_cum_mean")[["unbiased_cum_mean"]]
unbiased_cum_mean_mean <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)mean(exp(x), na.rm=T))
unbiased_cum_se <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)sd(exp(x)))
unbiased_cum_mean_median <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)median(exp(x), na.rm=T))
unbiased_cum_mean_lc <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.025, na.rm=T))
unbiased_cum_mean_uc <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.975, na.rm=T))
unbiased_cum_mean_lc2 <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.05, na.rm=T))
unbiased_cum_mean_uc2 <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.95, na.rm=T))
unbiased_cum_mean_lc3 <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.25, na.rm=T))
unbiased_cum_mean_uc3 <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.75, na.rm=T))
dimnames(unbiased_cum_mean) <- list(1:dim(unbiased_cum_mean)[1],
                                    levels(data$loss_type),
                                    1:dim(unbiased_cum_mean)[3])

unbiased_daily_mean <- extract(fit, "unbiased_daily_mean")[["unbiased_daily_mean"]]
unbiased_daily_mean_mean <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)mean(exp(x), na.rm=T))
unbiased_daily_mean_median <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)median(exp(x), na.rm=T))
unbiased_daily_mean_lc <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)quantile(exp(x),0.025, na.rm=T))
unbiased_daily_mean_uc <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)quantile(exp(x),0.975, na.rm=T))

conflict_intensity <- extract(fit, "avg_conflict_intensity")[["avg_conflict_intensity"]]
conflict_intensity_mean <- exp(apply(conflict_intensity, c(2), mean))

bias <- extract(fit, "bias_source_type_mu")[["bias_source_type_mu"]]
bias_mean <- apply(bias, c(2,3), FUN=function(x)mean(exp(x)))
bias_se <- apply(bias, c(2,3), FUN=function(x)sd(exp(x)))
bias_lc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.025))
bias_uc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.975))
rownames(bias_mean) <- rownames(bias_lc) <- rownames(bias_uc) <- rownames(bias_se) <- levels(data$claim_source)
colnames(bias_mean) <- colnames(bias_lc) <- colnames(bias_uc) <- colnames(bias_se) <- apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-'))
dimnames(bias) <- list(1:dim(bias)[1], levels(data$claim_source), apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-')))
print(bias_mean)

bias_source_target <- extract(fit, "bias_source_offset")[["bias_source_offset"]]
bias_sigma <- extract(fit, "bias_sigma")[["bias_sigma"]]
bias_source_target_actual <- array(NA,dim = c(9000,7,2))
for(ii in 1:7)
  for(jj in 1:2)
    bias_source_target_actual[,ii,jj] <- bias_source_target[,ii,jj] * bias_sigma
bias_source_target_actual_mean <- apply(bias_source_target_actual,
                                        c(2,3), mean)
bias_source_target_actual_exp_mean <- apply(bias_source_target_actual,
                                            c(2,3), FUN=function(x) exp(mean(x)))

Sigma <- extract(fit, "Sigma")[["Sigma"]]
Sigma <- apply(Sigma, c(2,3), mean)

Omega <- extract(fit, "Omega")[["Omega"]]
Omega_mean <- apply(Omega, c(2,3), mean)
Omega_lc <- apply(Omega, c(2,3), FUN=function(x)quantile(x,0.025))
Omega_uc <- apply(Omega, c(2,3), FUN=function(x)quantile(x,0.975))

############################################
## OUTPUT GAMMA MEANS                     ##
############################################
print("Average gamma:")
mean(bias_source_target_actual_mean)
mean(exp(bias_source_target_actual))

mean(bias_mean)

sub <- data[!data$category %in% c("Aircraft (unspecified)",
                                  "Ships",
                                  "Tanks & Armored Combat Vehicles",
                                  "Special Military Motor Vehicles",
                                  "Vehicles & Fuel Tanks"),]

pdf("all_biases.pdf", width=8, height=11)
par(mar=c(5.1,0.1,0.1,0.1))
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
      segments(bias_uc[row,col],ii,bias_lc[row,col],ii, col=highlight)
      text(paste(row,col,sep="-"),x=-1,y=ii,cex=0.5,pos=2)
      ii <- ii+1
    }
  }
}
abline(v=1,lty=2)
dev.off()
############################################
## OUTPUT BIAS MEANS.                     ##
############################################
makerow <- function(row,col,mat_mu,x){
  vals <- paste0(mat_mu[,row,col],collapse=",")
  meta <- paste(x,row,col,sep=",",collapse=",")
  name <- paste(meta,vals,sep=",",collapse=",")
  return(name)
}
row1 <- makerow("UA Source","Military Deaths-Ukraine",(bias),"Original")
row2 <- makerow("UA Source","Military Deaths-Russia",(bias),"Original")
row3 <- makerow("RU Source","Military Deaths-Ukraine",(bias),"Original")
row4 <- makerow("RU Source","Military Deaths-Russia",(bias),"Original")
write(row1,file="biases.csv",append=TRUE)
write(row2,file="biases.csv",append=TRUE)
write(row3,file="biases.csv",append=TRUE)
write(row4,file="biases.csv",append=TRUE)

############################################
## OUTPUT CUM LOSS MEANS                  ##
############################################
row1 <- makerow("Military Deaths-Ukraine",365,(unbiased_cum_mean),"Original")
row2 <- makerow("Military Deaths-Russia",365,(unbiased_cum_mean),"Original")
row3 <- makerow("Tanks-Ukraine",365,(unbiased_cum_mean),"Original")
row4 <- makerow("Tanks-Russia",365,(unbiased_cum_mean),"Original")
write(row1,file="cum_losses.csv",append=TRUE)
write(row2,file="cum_losses.csv",append=TRUE)
write(row3,file="cum_losses.csv",append=TRUE)
write(row4,file="cum_losses.csv",append=TRUE)