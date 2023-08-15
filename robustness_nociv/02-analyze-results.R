library(rstan)
library(bayesplot)
library(stringr)
library(stargazer)
library(xtable)

load("data-nociv.RData")
fit <- readRDS("model-nociv.rds")

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
unbiased_cum_mean_median <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)median(exp(x), na.rm=T))
unbiased_cum_mean_lc <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.025, na.rm=T))
unbiased_cum_mean_uc <- apply(unbiased_cum_mean, c(2,3), FUN=function(x)quantile(exp(x),0.975, na.rm=T))

unbiased_daily_mean <- extract(fit, "unbiased_daily_mean")[["unbiased_daily_mean"]]
unbiased_daily_mean_mean <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)mean(exp(x), na.rm=T))
unbiased_daily_mean_median <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)median(exp(x), na.rm=T))
unbiased_daily_mean_lc <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)quantile(exp(x),0.025, na.rm=T))
unbiased_daily_mean_uc <- apply(unbiased_daily_mean, c(2,3), FUN=function(x)quantile(exp(x),0.975, na.rm=T))

conflict_intensity <- extract(fit, "avg_conflict_intensity")[["avg_conflict_intensity"]]
conflict_intensity_mean <- exp(apply(conflict_intensity, c(2), mean))

bias <- extract(fit, "bias_source_type_mu")[["bias_source_type_mu"]]
bias_mean <- apply(bias, c(2,3), FUN=function(x)mean(exp(x)))
bias_lc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.025))
bias_uc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.975))
rownames(bias_mean) <- rownames(bias_lc) <- rownames(bias_uc) <- levels(data$claim_source)
colnames(bias_mean) <- colnames(bias_lc) <- colnames(bias_uc) <- apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-'))
print(bias_mean)

Sigma <- extract(fit, "Sigma")[["Sigma"]]
Sigma <- apply(Sigma, c(2,3), mean)

Omega <- extract(fit, "Omega")[["Omega"]]
Omega_mean <- apply(Omega, c(2,3), mean)
Omega_lc <- apply(Omega, c(2,3), FUN=function(x)quantile(x,0.025))
Omega_uc <- apply(Omega, c(2,3), FUN=function(x)quantile(x,0.975))

################################################################################
## PLOT
################################################################################
# pdf(PDF_NAME, width=15, height=15)

pal <- c("#023EFF", "#FF7C00", "#1AC938", "#E8000B", "#8B2BE2",
        "#9F4800", "#F14CC1", "#A3A3A3", "#FFC400", "#00D7FF")

cool_plot <- function(type,
                      title=NA,
                      ylab=NA,
                      ymax=NA,
                      xlab=NA,
                      xaxt="s",
                      yaxt="s",
                      cex=1,
                      uncertainty=F,
                      color=F)
{
  tt <- which.max(levels(data$loss_type)==type)
  print(tt)
  type <- levels(data$loss_type)[tt]
  sub  <- data[(data$loss_type == type) & (data$time_frame=="Cumulative"),]
  sub_daily <- data_daily[(data_daily$loss_type == type) & (data_daily$time_frame=="Day"),]
  ymax <- ifelse(!is.na(ymax), ymax, max(asinh(c(sub_daily$loss_count_min,sub$loss_count_min))))
  plot(sub$days, asinh(sub$loss_count_min), col=pal[sub$loss_type], #pch=as.character(data$loss_type),
       xlab=xlab,
       ylab=ylab, las=1, type="n", yaxt="n",
       xlim=c(0,num_days),
       ylim=c(0,ymax),
       xaxt=xaxt,
       main=title)
  if(yaxt!="n")
    axis(2, at=asinh(c(0,10,100,1000,10000,100000)), c(0,10,100,1000,10000,100000), las=1)
  abline(h=asinh(c(0,10,100,1000,10000,100000)), col="#00000033", lty=1)
  abline(h=asinh(c(1:9,
                   (1:9)*10,
                   (1:9)*100,
                   (1:9)*1000,
                   (1:9)*10000,
                   (1:9)*100000)), col="#00000022", lty=1, lwd=0.75)
  
  if(uncertainty){
    segments(sub$days,
             asinh(obs_cum_post_pred_lc[(data$loss_type == type) & (data$time_frame=="Cumulative")]),
             sub$days,
             asinh(obs_cum_post_pred_uc[(data$loss_type == type) & (data$time_frame=="Cumulative")]),
             col=pal[as.numeric(sub$claim_source)],
             lwd=2)
  }
  if(color){
    points(sub$days,
           asinh(sub$loss_count_min),
           bg="white", col=pal[as.numeric(sub$claim_source)], pch=as.numeric(sub$claim_source)-1,
           cex=cex)
  } else{
    points(sub$days,
           asinh(sub$loss_count_min),
           bg="white", col="black", pch=as.numeric(sub$claim_source)-1,
           cex=cex)
  }
  
  polygon(c(1:num_days,num_days:1),
          asinh(c(unbiased_cum_mean_lc[tt,], rev(unbiased_cum_mean_uc[tt,]))),
          col="#00000033",
          border=NA)
  lines(1:num_days,
        asinh(unbiased_cum_mean_mean[tt,]),
        lwd=4,
        col="#FFFFFF")
  lines(1:num_days,
        asinh(unbiased_cum_mean_mean[tt,]),
        lwd=2,
        lty=2,
        col="#000000")
  
  polygon(c(1:num_days,num_days:1),
          asinh(c(unbiased_daily_mean_lc[tt,], rev(unbiased_daily_mean_uc[tt,]))),
          col="#00000033",
          border=NA)
  
  lines(1:num_days,
        asinh(unbiased_daily_mean_mean[tt,]),
        col="white",
        lwd=4,
        lty=1)
  
  lines(1:num_days,
        asinh(unbiased_daily_mean_mean[tt,]),
        col="black",
        lwd=2,
        lty=1)
  
  points(sub_daily$days,
         asinh(sub_daily$loss_count_min),
         col="white", bg="black", pch=23,
         cex=cex)
}

pdf("cool_plot.pdf", width=12, height=6)
par(mfrow=c(2,2))

par(mar=c(0.1,5.1,4.1,0.1))
cool_plot(type="Military Deaths-Russia",
          title=NA,
          ymax=13,
          xaxt="n")
mtext("Russia", side=3, line=0.5)
mtext("Military Deaths", side=2, line=4)

par(mar=c(0.1,0.1,4.1,5.1))
cool_plot(type="Military Deaths-Ukraine",
          ylab=NA,
          title=NA,
          ymax=13,
          yaxt="n",
          xaxt="n")
mtext("Ukraine", side=3, line=0.5)

par(mar=c(5.1,5.1,0.1,0.1))
cool_plot(type="Tanks-Russia",
          ymax=10,
          xlab="Days since Feb. 24. 2022")
mtext("Tank Losses", side=2, line=4)

par(mar=c(5.1,0.1,0.1,5.1))
cool_plot(type="Tanks-Ukraine",
          ylab=NA,
          ymax=10,
          yaxt="n",
          xlab="Days since Feb. 24. 2022")
legend("bottomright",
       c("GB Source",
         "OSI",
         "Other",
         "RU Source",
         "UA Source",
         "United Nations",
         "US Source",
         "Daily (all sources)"),
       pch=c(0:6,18),
       col="black",
       bg="#FFFFFFCC",
       cex=1)
dev.off()

############################################
## TABLE                                  ##
############################################
my_table <- data.frame("type"=names(table(data$loss_type)),
                       "n"=as.vector(table(data$loss_type))+
                           as.vector(table(data_daily$loss_type)))

my_table$cum_mean <- round(unbiased_cum_mean_mean[,365])
my_table$cum_median <- round(unbiased_cum_mean_median[,365])
my_table$ci <- paste0("[",
                      round(unbiased_cum_mean_lc[,365]),
                      "--",
                      round(unbiased_cum_mean_uc[,365]),
                      "]")
my_table$loss_type <- sapply(my_table$type, FUN=function(x)str_split(x,"-")[[1]][1], simplify=T)
my_table$country <- sapply(my_table$type, FUN=function(x)str_split(x,"-")[[1]][2], simplify=T)
my_table$country <- c("Ukraine"="UA","Russia"="RU")[my_table$country]
my_table$country <- sapply(my_table$country,
                           FUN=function(x){
                             if(x == "UA")
                                 return("rowcolor{ukrainian-gray} UA")
                             else
                                 return("rowcolor{russian-gray} RU")
                           })

print(
  xtable(my_table[,c("country",
                   "loss_type",
                   "n",
                   "cum_mean",
                   # "cum_median",
                   "ci")], 
         type="text",
         digits=0),
  include.rownames=F)
