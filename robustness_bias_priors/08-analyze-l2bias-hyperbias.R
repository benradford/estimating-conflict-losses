library(rstan)
library(bayesplot)
library(stringr)
library(stargazer)
library(xtable)

load("data-original.RData")
fit <- readRDS("model-l2bias-hyperbias.rds")

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

Sigma <- extract(fit, "Sigma")[["Sigma"]]
Sigma <- apply(Sigma, c(2,3), mean)

Omega <- extract(fit, "Omega")[["Omega"]]
Omega_mean <- apply(Omega, c(2,3), mean)
Omega_lc <- apply(Omega, c(2,3), FUN=function(x)quantile(x,0.025))
Omega_uc <- apply(Omega, c(2,3), FUN=function(x)quantile(x,0.975))


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

############################################
## OUTPUT BIAS MEANS.                     ##
############################################
makerow <- function(row,col,mat_mu,x){
  vals <- paste0(mat_mu[,row,col],collapse=",")
  meta <- paste(x,row,col,sep=",",collapse=",")
  name <- paste(meta,vals,sep=",",collapse=",")
  return(name)
}
row1 <- makerow("UA Source","Military Deaths-Ukraine",(bias),"Single Level + Hyperprior")
row2 <- makerow("UA Source","Military Deaths-Russia",(bias),"Single Level + Hyperprior")
row3 <- makerow("RU Source","Military Deaths-Ukraine",(bias),"Single Level + Hyperprior")
row4 <- makerow("RU Source","Military Deaths-Russia",(bias),"Single Level + Hyperprior")
write(row1,file="biases.csv",append=TRUE)
write(row2,file="biases.csv",append=TRUE)
write(row3,file="biases.csv",append=TRUE)
write(row4,file="biases.csv",append=TRUE)

############################################
## OUTPUT CUM LOSS MEANS                  ##
############################################
row1 <- makerow("Military Deaths-Ukraine",365,(unbiased_cum_mean),"Single Level + Hyperprior")
row2 <- makerow("Military Deaths-Russia",365,(unbiased_cum_mean),"Single Level + Hyperprior")
row3 <- makerow("Tanks-Ukraine",365,(unbiased_cum_mean),"Single Level + Hyperprior")
row4 <- makerow("Tanks-Russia",365,(unbiased_cum_mean),"Single Level + Hyperprior")
write(row1,file="cum_losses.csv",append=TRUE)
write(row2,file="cum_losses.csv",append=TRUE)
write(row3,file="cum_losses.csv",append=TRUE)
write(row4,file="cum_losses.csv",append=TRUE)