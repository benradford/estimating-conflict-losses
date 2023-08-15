knots <- 150
DRAWS <- 2000
WARMUP <- 500
CHAINS <- 6
MAX_TREEDEPTH <- 13
THIN <- 1
ADAPT_DELTA <- 0.90
MODEL <- "model.stan"
FILENAME <- "model-ru-5x.rds"

library(rstan)

options(mc.cores=parallel::detectCores())

load("data-ru-5x.RData")

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
                 "daily_max"=as.numeric(data_daily$maximum),
                 
                 "X"=1:num_days,
                 "num_knots"=knots,
                 "knots"=quantile(1:num_days,probs=seq(from=0,to=1,length.out=knots)),
                 "spline_degree"=3
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
              "Sigma"
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
