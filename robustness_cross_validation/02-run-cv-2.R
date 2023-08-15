#!/usr/bin/env Rscript
set.seed(215)
library(rstan)

# k <- as.numeric(args[1])
knots <- 150
DRAWS <- 2000
WARMUP <- 500
CHAINS <- 6
MAX_TREEDEPTH <- 13
PARTITION <- 2
THIN <- 1
ADAPT_DELTA <- 0.90
MODEL <- "model.stan"

FILENAME <- "model_cv_1.rds"

load("../model_original/data-original.RData")

num_days <- max(c(data$days, data_daily$days))
daily_num_obs <- nrow(data_daily)
cum_num_obs <- nrow(data)

daily_partitions <- sample(1:5, daily_num_obs, replace=T)
cum_partitions <- sample(1:5, cum_num_obs, replace=T)

standata <- list(
                 "num_days"=num_days,
                 "num_loss_type"=length(unique(c(data$loss_type,data_daily$loss_type))),
                 "num_loss_country"=2,
                 "num_claim_source"=length(unique(data$claim_source)),
                 "cum_num_obs"=sum(cum_partitions!=PARTITION),
                 "daily_num_obs"=sum(daily_partitions!=PARTITION),
                 "num_category"=length(levels(data$category)),

                 "cum_day"=data$days[cum_partitions!=PARTITION],
                 "cum_count"=data$loss_count_min[cum_partitions!=PARTITION],
                 "cum_loss_type"=as.numeric(data$loss_type)[cum_partitions!=PARTITION],
                 "cum_claim_source"=as.numeric(data$claim_source)[cum_partitions!=PARTITION],
                 "cum_loss_country"=as.numeric(as.factor(data$loss_country))[cum_partitions!=PARTITION],
                 "cum_category"=as.numeric(data$category)[cum_partitions!=PARTITION],
                 "cum_min"=as.numeric(data$minimum)[cum_partitions!=PARTITION],
                 "cum_max"=as.numeric(data$maximum)[cum_partitions!=PARTITION],
                 
                 "daily_count"=data_daily$loss_count_min[daily_partitions!=PARTITION],
                 "daily_day"=data_daily$days[daily_partitions!=PARTITION],
                 "daily_loss_type"=as.numeric(data_daily$loss_type)[daily_partitions!=PARTITION],
                 "daily_claim_source"=as.numeric(data_daily$claim_source)[daily_partitions!=PARTITION],
                 "daily_loss_country"=as.numeric(as.factor(data_daily$loss_country))[daily_partitions!=PARTITION],
                 "daily_category"=as.numeric(data_daily$category)[daily_partitions!=PARTITION],
                 "daily_min"=as.numeric(data_daily$minimum)[daily_partitions!=PARTITION],
                 "daily_max"=as.numeric(data_daily$maximum)[daily_partitions!=PARTITION],
                 
                 "X"=1:num_days,
                 "num_knots"=knots,
                 "knots"=quantile(1:num_days,probs=seq(from=0,to=1,length.out=knots)),
                 "spline_degree"=3,
                 
                 "cum_num_obs_oos"=sum(cum_partitions==PARTITION),
                 "daily_num_obs_oos"=sum(daily_partitions==PARTITION),
                 
                 "cum_day_oos"=data$days[cum_partitions==PARTITION],
                 "cum_count_oos"=data$loss_count_min[cum_partitions==PARTITION],
                 "cum_loss_type_oos"=as.numeric(data$loss_type)[cum_partitions==PARTITION],
                 "cum_claim_source_oos"=as.numeric(data$claim_source)[cum_partitions==PARTITION],
                 "cum_loss_country_oos"=as.numeric(as.factor(data$loss_country))[cum_partitions==PARTITION],
                 "cum_category_oos"=as.numeric(data$category)[cum_partitions==PARTITION],
                 "cum_min_oos"=as.numeric(data$minimum)[cum_partitions==PARTITION],
                 "cum_max_oos"=as.numeric(data$maximum)[cum_partitions==PARTITION],
                 
                 "daily_count_oos"=data_daily$loss_count_min[daily_partitions==PARTITION],
                 "daily_day_oos"=data_daily$days[daily_partitions==PARTITION],
                 "daily_loss_type_oos"=as.numeric(data_daily$loss_type)[daily_partitions==PARTITION],
                 "daily_claim_source_oos"=as.numeric(data_daily$claim_source)[daily_partitions==PARTITION],
                 "daily_loss_country_oos"=as.numeric(as.factor(data_daily$loss_country))[daily_partitions==PARTITION],
                 "daily_category_oos"=as.numeric(data_daily$category)[daily_partitions==PARTITION],
                 "daily_min_oos"=as.numeric(data_daily$minimum)[daily_partitions==PARTITION],
                 "daily_max_oos"=as.numeric(data_daily$maximum)[daily_partitions==PARTITION]
)

stanpars <- c(    # Parameters block
              "cum_phi",
              "cum_phi_sigma",
              "cum_phi_offset",
              "bias_sigma",
              "bias_source_sigma",
              "bias_source_offset",
              "bias_source_type_offset",
              "beta_min_mu",
              "beta_max_mu",
              "beta_min_sigma",
              "beta_max_sigma",
              "beta_min_offset",
              "beta_max_offset",
              "beta_type_mu",
              "beta_type_sigma",
              "beta_type_offset",
              "slope_mu",
              "slope_sigma",
              "slope_offset",
              "spline_raw",
              "spline_Lcorr",
              "spline_sigma",
              
                  # Transformed parameters block
              "beta_min",
              "beta_max",
              "beta_loss_type",
              "slope",
              "bias_source_type_mu",
              "cum_losses",
              "latent_losses",
              "obs_daily_mu",
              "obs_cum_mu",
              "inv_cum_phi",
              "obs_inv_cum_phi",
              "spline",
                  # Generated quantities block
              "obs_cum_post_pred",
              "obs_daily_post_pred",
              "unbiased_cum_post_pred",
              "unbiased_daily_post_pred",
              "unbiased_daily_mean",
              "unbiased_cum_mean",
              "avg_conflict_intensity",
              "log_lik",
              "Omega",
              "Sigma",
                # OOS predictions
              "obs_daily_pos_pred_oos",
              "obs_cum_pos_pred_oos"
              )



fit <- sampling(stan_model(MODEL),
                data = standata,
                iter = DRAWS,
                cores = CHAINS,
                chains = CHAINS,
                warmup = WARMUP,
                thin = THIN,
                control = list("max_treedepth"=MAX_TREEDEPTH, 
                               "adapt_delta"=ADAPT_DELTA),
                algorithm="NUTS",
                init="random",
                init_r=0.25,
                pars = stanpars,
                save_warmup = FALSE,
                seed=215)
fit@stanmodel@dso <- new("cxxdso")
saveRDS(fit, file = FILENAME)

ppc_dens_overlay <- function(x,y){
  plot(density(x), lwd=2)
  samp <- sample(1:nrow(y), min(1000,nrow(y)), replace=F)
  for(yy in samp){
    lines(density(y[yy,]), col="#00000006")
  }
  lines(density(x), lwd=2, col="#6666FF")
}

y_rep_daily <- extract(fit, "obs_daily_pos_pred_oos")[["obs_daily_pos_pred_oos"]]
y_rep_cum <- extract(fit, "obs_cum_pos_pred_oos")[["obs_cum_pos_pred_oos"]]
png(paste0("ppc_density_",as.character(PARTITION),".png"),width=1200,height=1200)
ppc_dens_overlay(log(c(data_daily$loss_count_min[daily_partitions==PARTITION],
                   data$loss_count_min[cum_partitions==PARTITION])+1), 
                 log(cbind(y_rep_daily,y_rep_cum)+1))
dev.off()

png(paste0("scatterplot_",as.character(PARTITION),".png"),width=1200,height=1200)
par(mfrow=c(1,1),mar=c(5.1,4.1,4.1,1.1))
plot(log(c(data_daily$loss_count_min[daily_partitions==PARTITION],
           data$loss_count_min[cum_partitions==PARTITION])+1), 
     apply(cbind(y_rep_daily,y_rep_cum),MARGIN=2,FUN=function(x)mean(log(x+1))),
     xlab="ln(reported losses + 1)",
     ylab="ln(estimated losses + 1)",
     main="Predicted vesus Observed Loss Report Values",
     col=c(rep("blue",sum(daily_partitions==PARTITION)),
           rep("orange",sum(cum_partitions==PARTITION))))
segments(log(c(data_daily$loss_count_min[daily_partitions==PARTITION],
           data$loss_count_min[cum_partitions==PARTITION])+1), 
     apply(cbind(y_rep_daily,y_rep_cum),MARGIN=2,FUN=function(x)quantile(log(x+1),0.05)),
     log(c(data_daily$loss_count_min[daily_partitions==PARTITION],
           data$loss_count_min[cum_partitions==PARTITION])+1),
     apply(cbind(y_rep_daily,y_rep_cum),MARGIN=2,FUN=function(x)quantile(log(x+1),0.95)))
abline(0,1,col="red")
dev.off()