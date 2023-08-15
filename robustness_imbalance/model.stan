// NOTES
// https://mbjoseph.github.io/posts/2018-12-25-errors-in-variables-models-in-stan/

/////////////////////////////////////////
// FUNCTIONS TO PRODUCE B-SPLINES      //
/////////////////////////////////////////
functions {
  vector build_b_spline(real[] t, real[] ext_knots, int ind, int order);
  vector build_b_spline(real[] t, real[] ext_knots, int ind, int order) {
    // INPUTS:
    //    t:          the points at which the b_spline is calculated
    //    ext_knots:  the set of extended knots
    //    ind:        the index of the b_spline
    //    order:      the order of the b-spline
    vector[size(t)] b_spline;
    vector[size(t)] w1 = rep_vector(0, size(t));
    vector[size(t)] w2 = rep_vector(0, size(t));
    if (order==1)
      for (i in 1:size(t)) // B-splines of order 1 are piece-wise constant
        b_spline[i] = (ext_knots[ind] <= t[i]) && (t[i] < ext_knots[ind+1]);
    else {
      if (ext_knots[ind] != ext_knots[ind+order-1])
        w1 = (to_vector(t) - rep_vector(ext_knots[ind], size(t))) /
             (ext_knots[ind+order-1] - ext_knots[ind]);
      if (ext_knots[ind+1] != ext_knots[ind+order])
        w2 = 1 - (to_vector(t) - rep_vector(ext_knots[ind+1], size(t))) /
                 (ext_knots[ind+order] - ext_knots[ind+1]);
      // Calculating the B-spline recursively as linear interpolation of two lower-order splines
      b_spline = w1 .* build_b_spline(t, ext_knots, ind, order-1) +
                 w2 .* build_b_spline(t, ext_knots, ind+1, order-1);
    }
    return b_spline;
  }
}

data {
  // Book-keeping data
  int<lower=1> num_days;          // number of days to model
  int<lower=1> num_loss_type;     // number of loss types
  int<lower=1> num_loss_country;  // number of countries suffering losses
  int<lower=1> num_claim_source;  // number of claim sources
  int<lower=1> cum_num_obs;       // cumulative number of observations
  int<lower=1> daily_num_obs;     // daily number of obs
  int<lower=1> num_category;

  // Cumulative covariates and outcomes
  int<lower=1> cum_day[cum_num_obs];              // day index
  int<lower=0> cum_count[cum_num_obs];            // cumulative losses
  int<lower=1> cum_loss_type[cum_num_obs];        // loss type
  int<lower=1> cum_claim_source[cum_num_obs];     // claim source
  int<lower=1> cum_loss_country[cum_num_obs];
  int<lower=1> cum_category[cum_num_obs];
  int<lower=0,upper=1> cum_min[cum_num_obs];              // minimum estimate
  int<lower=0,upper=1> cum_max[cum_num_obs];              // maximum estimate

  // Daily covariates and oucomes
  int<lower=0> daily_count[daily_num_obs];        // daily losses
  int<lower=1> daily_day[daily_num_obs];          // daily day index
  int<lower=1> daily_loss_type[daily_num_obs];    // daily loss type
  int<lower=1> daily_claim_source[daily_num_obs]; // daily claim source
  int<lower=1> daily_loss_country[daily_num_obs];
  int<lower=1> daily_category[daily_num_obs];
  int<lower=0,upper=1> daily_min[daily_num_obs];  // minimum estimate
  int<lower=0,upper=1> daily_max[daily_num_obs];  // maximum estimate
  
  real X[num_days];
  int num_knots;
  vector[num_knots] knots;
  int spline_degree;
}

transformed data{
  ///////////////////////////////////////////////////
  // This is all for constructing the basis spline //
  ///////////////////////////////////////////////////
  int num_basis = num_knots + spline_degree - 1;
  matrix[num_basis, num_days] B;
  vector[spline_degree + num_knots] ext_knots_temp;
  vector[2*spline_degree + num_knots] ext_knots; // set of extended knots
  ext_knots_temp = append_row(rep_vector(knots[1], spline_degree), knots);
  ext_knots = append_row(ext_knots_temp, rep_vector(knots[num_knots], spline_degree));
  for (ind in 1:num_basis)
    B[ind,:] = to_row_vector(build_b_spline(X, to_array_1d(ext_knots), ind, spline_degree + 1));
  B[num_knots + spline_degree - 1, num_days] = 1;
  
  ////////////////////////////////////////////////
  // This is for a zero-centered bias vector    //
  // see: https://mc-stan.org/docs/             //
  //      stan-users-guide/                     //
  //      parameterizing-centered-vectors.html  //
  ////////////////////////////////////////////////
  // matrix[num_source_target, num_source_target] A = diag_matrix(rep_vector(1, num_source_target));
  // matrix[num_source_target, num_source_target - 1] A_qr;
  // for (i in 1:num_source_target - 1) A[num_source_target, i] = -1;
  // A[num_source_target, num_source_target] = 0;
  // A_qr = qr_Q(A)[ , 1:(num_source_target - 1)];
  
  // // SEPARATE R/U QR DECOMPOSITIONS
  // matrix[num_source_target_R, num_source_target_R] R = diag_matrix(rep_vector(1, num_source_target_R));
  // matrix[num_source_target_R, num_source_target_R - 1] R_qr;
  // for (i in 1:num_source_target_R - 1) R[num_source_target_R, i] = -1;
  // R[num_source_target_R, num_source_target_R] = 0;
  // R_qr = qr_Q(R)[ , 1:(num_source_target_R - 1)];
  // // SEPARATE R/U QR DECOMPOSITIONS
  // matrix[num_source_target_U, num_source_target_U] U = diag_matrix(rep_vector(1, num_source_target_U));
  // matrix[num_source_target_U, num_source_target_U - 1] U_qr;
  // for (i in 1:num_source_target_U - 1) U[num_source_target_U, i] = -1;
  // U[num_source_target_U, num_source_target_U] = 0;
  // U_qr = qr_Q(U)[ , 1:(num_source_target_U - 1)];
}

parameters {
  
  // scale parameters for negative binomial
  real                                   cum_phi;
  real<lower=0>                          cum_phi_sigma;
  vector[num_loss_type]                  cum_phi_offset;
  
  // source-tarcget biases
  real<lower=0>                                           bias_sigma;
  matrix<lower=0>[num_claim_source,num_loss_country]      bias_source_sigma;
  matrix[num_claim_source,num_loss_country]               bias_source_offset;
  matrix[num_claim_source,num_category*num_loss_country]  bias_source_type_offset;
  
  // min-max random effects
  real                                   beta_min_mu;
  real                                   beta_max_mu;
  real<lower=0>                          beta_min_sigma;
  real<lower=0>                          beta_max_sigma;
  vector[num_claim_source]               beta_min_offset;
  vector[num_claim_source]               beta_max_offset;
  
  // intercepts
  real                                   beta_type_mu;
  real<lower=0>                          beta_type_sigma;
  vector[num_loss_type]                  beta_type_offset;
  
  // slopes
  real                                   slope_mu;
  real<lower=0>                          slope_sigma;
  vector[num_loss_type]                  slope_offset;

  // spline random effects
  matrix[num_loss_type, num_basis]       spline_raw;
  cholesky_factor_corr[num_loss_type]    spline_Lcorr;
  vector<lower=0>[num_loss_type]         spline_sigma;

}

transformed parameters{

  // REPARAMETERIZATION TRICK
  vector[num_claim_source]                               beta_min;
  vector[num_claim_source]                               beta_max;
  vector[num_loss_type]                                  beta_loss_type;
  vector[num_loss_type]                                  slope;
  matrix[num_claim_source,num_category*num_loss_country] bias_source_type_mu;

  // LATENT VARIABLES
  matrix[num_loss_type, num_days]                        cum_losses;
  matrix[num_loss_type, num_days]                        latent_losses;

  // PARAMETER ESTIMATES FOR OBSERVED DATA
  vector[daily_num_obs]                                  obs_daily_mu;
  vector[cum_num_obs]                                    obs_cum_mu;

  // NEGATIVE BINOMIAL OVERDISPERSION SCALE
  vector[num_loss_type]                                  inv_cum_phi;
  vector[cum_num_obs]                                    obs_inv_cum_phi;
  
  // SPLINE
  matrix[num_loss_type, num_basis]                       spline;

  ///////////////////////////////////
  // COMPUTE INV EXP NB SCALES     //
  ///////////////////////////////////
  inv_cum_phi = inv(exp(cum_phi_sigma * cum_phi_offset + cum_phi));

  ///////////////////////////////////
  // REPARAMETERIZATION TRICK ///////
  ///////////////////////////////////
  // Random effects for low and high estimate ranges
  beta_min = beta_min_offset * (beta_min_sigma) + beta_min_mu;
  beta_max = beta_max_offset * (beta_max_sigma) + beta_max_mu;

  // Random intercepts by loss type
  beta_loss_type = beta_type_sigma * beta_type_offset + beta_type_mu;
  
  // Random slopes by loss type
  slope = slope_sigma * slope_offset + slope_mu;
  
  // Hierarchical random biases
  for(cs in 1:num_claim_source){
    for(tt in 1:num_category){
      for(lc in 1:num_loss_country){
        bias_source_type_mu[cs,tt+(lc-1)*num_category] = (bias_source_offset[cs,lc]*bias_sigma) + (bias_source_type_offset[cs,tt+(lc-1)*num_category] * bias_source_sigma[cs,lc]);
      }
    }
  }
  
  ////////////////////////////////////
  // COMPUTE LATENT SPLINES   ////////
  ////////////////////////////////////
  spline = (diag_pre_multiply(spline_sigma, spline_Lcorr) * spline_raw);
  
  for(tt in 1:num_loss_type){
    latent_losses[tt,] = to_row_vector(
      rep_vector(beta_loss_type[tt], num_days)) +  // TYPE INTERCEPT
      to_row_vector(spline[tt,]) * B +             // SPLINE COEF x BASIS
      slope[tt]*to_row_vector(X)/365;              // DAYS x SLOPE
  }
  
  ////////////////////////////////////////////
  // COMPUTE CUMULATIVE LATENT LOSSES ////////
  ////////////////////////////////////////////
  cum_losses[,1] = to_vector(latent_losses[,1]);
  for(tt in 1:num_loss_type){
     for(dd in 2:num_days){
       cum_losses[tt,dd] = log(exp(cum_losses[tt,dd-1]) + exp(latent_losses[tt,dd]));
      // cum_losses[tt,dd] = log_sum_exp(cum_losses[tt,dd-1],latent_losses[tt,dd]);
    }
  }
  
  ////////////////////////////////////
  // COMPUTE MEANS OF OBSERVED DATA //
  ////////////////////////////////////
  // Daily observed losses expected values
  for(ii in 1:daily_num_obs)
  {
    obs_daily_mu[ii] = latent_losses[daily_loss_type[ii],
                                     daily_day[ii]] +
                       bias_source_type_mu[daily_claim_source[ii], daily_category[ii] + (daily_loss_country[ii]-1)*num_category] +
                       beta_min[daily_claim_source[ii]]*daily_min[ii] +
                       beta_max[daily_claim_source[ii]]*daily_max[ii];

  }
  // Cumulative observed losses expected values
  for(ii in 1:cum_num_obs)
  {
    obs_cum_mu[ii] =  cum_losses[cum_loss_type[ii],
                                 cum_day[ii]] + 
                      bias_source_type_mu[cum_claim_source[ii], cum_category[ii] + (cum_loss_country[ii]-1)*num_category] +
                      beta_min[cum_claim_source[ii]]*cum_min[ii] +
                      beta_max[cum_claim_source[ii]]*cum_max[ii];
    obs_inv_cum_phi[ii] = inv_cum_phi[cum_loss_type[ii]];
  }

}


model {
  
  //////////////////////////////////////////////////////////////////
  // DRAW RANDOM COEFFICIENTS FOR SOURCE-TARGET BIAS BY LOSS TYPE //
  //////////////////////////////////////////////////////////////////
  bias_sigma ~ std_normal();
  to_vector(bias_source_offset) ~ std_normal();
  to_vector(bias_source_sigma) ~ std_normal();
  to_vector(bias_source_type_offset) ~ std_normal();

  //////////////////////////////////////////////
  // DRAW RANDOM SLOPE COEFFICIENTS BY TYPE   //
  //////////////////////////////////////////////
  slope_mu ~ std_normal();
  slope_sigma ~ std_normal();
  slope_offset ~ std_normal();

  ///////////////////////////////////////
  // DRAW MIN AND MAX ESTIMATE SCALARS //
  ///////////////////////////////////////
  beta_min_mu ~ std_normal();
  beta_max_mu ~ std_normal();
  beta_min_sigma ~ std_normal();
  beta_max_sigma ~ std_normal();
  beta_min_offset ~ std_normal();
  beta_max_offset ~ std_normal();
  
  //////////////////////////
  // LOSS TYPE INTERCEPTS //
  //////////////////////////
  beta_type_mu ~ std_normal();
  beta_type_sigma ~ std_normal();
  beta_type_offset ~ std_normal();

  ///////////////////////////////////////////////////////////
  // DRAW SMOOTHED RANDOM SPLINE COEFFICIENTS BY LOSS TYPE //
  ///////////////////////////////////////////////////////////
  spline_sigma ~ std_normal();
  spline_Lcorr ~ lkj_corr_cholesky(2);
  to_vector(spline_raw) ~ std_normal();

  ////////////////////////////////////////////
  // DRAW SCALE PARAMETERS FOR NEG BINOMIAL //
  ////////////////////////////////////////////
  cum_phi ~ std_normal();
  cum_phi_sigma ~ std_normal();
  cum_phi_offset ~ std_normal();
  
  /////////////////////////////
  // UPDATE MODEL LIKELIHOOD //
  /////////////////////////////
  target += poisson_log_lpmf(daily_count | obs_daily_mu);
  target += neg_binomial_2_log_lpmf(cum_count | obs_cum_mu, obs_inv_cum_phi);
  
}

generated quantities {
  real obs_cum_post_pred[cum_num_obs];
  real obs_daily_post_pred[daily_num_obs];
  real unbiased_cum_post_pred[num_loss_type, num_days];
  real unbiased_daily_post_pred[num_loss_type, num_days];
  matrix[num_loss_type, num_days] unbiased_daily_mean;
  matrix[num_loss_type, num_days] unbiased_cum_mean;
  real avg_conflict_intensity[num_days];
  real log_lik[daily_num_obs + cum_num_obs]; // for LOO-CV
  matrix[num_loss_type,num_loss_type] Omega;
  matrix[num_loss_type,num_loss_type] Sigma;

  obs_daily_post_pred = poisson_log_rng(obs_daily_mu);
  obs_cum_post_pred = neg_binomial_2_log_rng(obs_cum_mu, obs_inv_cum_phi);

  for(ii in 1:daily_num_obs)
    log_lik[cum_num_obs+ii] = poisson_log_lpmf(
      daily_count[ii] | obs_daily_mu[ii]);

  for(ii in 1:cum_num_obs)
    log_lik[ii] = neg_binomial_2_log_lpmf(
      cum_count[ii] | obs_cum_mu[ii], obs_inv_cum_phi[ii]);

  unbiased_daily_mean = latent_losses;
  unbiased_cum_mean = cum_losses;

  for(tt in 1:num_loss_type)
  {

    unbiased_daily_post_pred[tt,] = poisson_log_rng(
          latent_losses[tt,]);
    unbiased_cum_post_pred[tt,] = neg_binomial_2_log_rng(
        cum_losses[tt,], inv_cum_phi[tt]);
  }


  for(dd in 1:num_days)
    avg_conflict_intensity[dd] = mean(latent_losses[,dd]);

  Omega = multiply_lower_tri_self_transpose(spline_Lcorr);
  Sigma = quad_form_diag(Omega, spline_sigma);
}
