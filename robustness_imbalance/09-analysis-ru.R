library(rstan)

load("../model_original/data-original.RData")

all_models <- c("../model_original/model-original.rds",
                "model_2x_ru.rds",
                "model_3x_ru.rds",
                "model_4x_ru.rds",
                "model_5x_ru.rds")

for(ii in 1:length(all_models))
{
  
  
  # fit <- readRDS("../model_original/model-original.rds")
  fit <- readRDS(all_models[ii])
  
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
  
  bias <- extract(fit, "bias_source_type_mu")[["bias_source_type_mu"]]
  bias_mean <- apply(bias, c(2,3), FUN=function(x)mean(exp(x)))
  bias_se <- apply(bias, c(2,3), FUN=function(x)sd(exp(x)))
  bias_lc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.025))
  bias_uc <- apply(bias, c(2,3), FUN=function(x)quantile(exp(x),0.975))
  rownames(bias_mean) <- rownames(bias_lc) <- rownames(bias_uc) <- rownames(bias_se) <- levels(data$claim_source)
  colnames(bias_mean) <- colnames(bias_lc) <- colnames(bias_uc) <- colnames(bias_se) <- apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-'))
  dimnames(bias) <- list(1:dim(bias)[1], levels(data$claim_source), apply(expand.grid(levels(data$category),levels(as.factor(data$loss_country))),1,FUN=function(x)paste0(x,collapse='-')))
  
  ############################################
  ## OUTPUT BIASES                          ##
  ############################################
  makerow <- function(row,col,mat_mu,x){
    vals <- paste0(mat_mu[,row,col],collapse=",")
    meta <- paste(x,row,col,sep=",",collapse=",")
    name <- paste(meta,vals,sep=",",collapse=",")
    return(name)
  }
  row1 <- makerow("UA Source","Military Deaths-Ukraine",(bias),ii)
  row2 <- makerow("UA Source","Military Deaths-Russia",(bias),ii)
  row3 <- makerow("RU Source","Military Deaths-Ukraine",(bias),ii)
  row4 <- makerow("RU Source","Military Deaths-Russia",(bias),ii)
  write(row1,file="biases_ru.csv",append=TRUE)
  write(row2,file="biases_ru.csv",append=TRUE)
  write(row3,file="biases_ru.csv",append=TRUE)
  write(row4,file="biases_ru.csv",append=TRUE)
  
  ############################################
  ## OUTPUT CUM LOSS MEANS                  ##
  ############################################
  row1 <- makerow("Military Deaths-Ukraine",365,(unbiased_cum_mean),ii)
  row2 <- makerow("Military Deaths-Russia",365,(unbiased_cum_mean),ii)
  row3 <- makerow("Tanks-Ukraine",365,(unbiased_cum_mean),ii)
  row4 <- makerow("Tanks-Russia",365,(unbiased_cum_mean),ii)
  write(row1,file="cum_losses_ru.csv",append=TRUE)
  write(row2,file="cum_losses_ru.csv",append=TRUE)
  write(row3,file="cum_losses_ru.csv",append=TRUE)
  write(row4,file="cum_losses_ru.csv",append=TRUE)

}
