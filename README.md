Estimating Conflict Losses and Reporting Biases
===============================================

**Replication archive** for Radford et al. (2023), ["Estimating Conflict Losses and Reporting Biases," in _PNAS_](https://www.pnas.org/doi/10.1073/pnas.2307372120).

[Benjamin J. Radford](https://www.benradford.com)  
[Yaoyao Dai](https://www.daiyaoyao.com)  
[Niklas Stoehr](https://niklas-stoehr.com/)  
[Aaron Schein](https://www.aaronschein.com/)  
Mya Fernandez   
Hanif Sajid

# Table of Contents

* [Requirements](#requirements)
* [Repository Contents](#repository-contents)
* [Replicating the Original Model](#replicating-the-original-model)
* [Robustness Tests](#robustness-tests)
* [Cite this Paper](#cite-this-paper)

# Requirements

You will need [R](https://www.r-project.org/), [Stan](https://mc-stan.org/), and the following R packages:

* [rstan](https://mc-stan.org/users/interfaces/rstan)
* [stringr](https://stringr.tidyverse.org/)
* [bayesplot](http://mc-stan.org/bayesplot/)
* [xtable](https://cran.r-project.org/web/packages/xtable/index.html)
* [narray](https://cran.r-project.org/web/packages/narray/index.html)

In addition, you will need a lot of time, patience, disk space, and reasonable computing power.

# Repository Contents
<details>
  <summary>Click here for a file tree of this repository.</summary>
  
```
.
├── model_original
│   ├── 01-run.R
│   ├── 02-analyze-results.R
│   ├── data-original.RData
│   └── model.stan
├── robustness_bias_priors
│   ├── 01-run-original.R
│   ├── 02-run-l2bias.R
│   ├── 03-run-hyperbias.R
│   ├── 04-run-l2bias-hyperbias.R
│   ├── 05-analyze-original.R
│   ├── 06-analyze-l2bias.R
│   ├── 07-analyze-hyperbias.R
│   ├── 08-analyze-l2bias-hyperbias.R
│   ├── 09-make-plots.R
│   ├── all_biases.pdf
│   ├── bias_priors_on_bias.pdf
│   ├── bias_priors_on_losses.pdf
│   ├── data-original.RData
│   ├── model-hyperbias.stan
│   ├── model-l2bias-hyperbias.stan
│   ├── model-l2bias.stan
│   └── model-original.stan
├── robustness_cross_validation
│   ├── 01-run-cv-1.R
│   ├── 02-run-cv-2.R
│   ├── 03-run-cv-3.R
│   ├── 04-run-cv-4.R
│   ├── 05-run-cv-5.R
│   ├── model.stan
│   ├── ppc_density_1.png
│   ├── ppc_density_2.png
│   ├── ppc_density_3.png
│   ├── ppc_density_4.png
│   ├── ppc_density_5.png
│   ├── scatterplot_1.png
│   ├── scatterplot_2.png
│   ├── scatterplot_3.png
│   ├── scatterplot_4.png
│   └── scatterplot_5.png
├── robustness_fixed_effects
│   ├── 01-run-fixed-effects.R
│   ├── 02-analyze-fixed-effects.R
│   ├── data-original.RData
│   ├── fe_biases.pdf
│   └── model-fixed-effects.stan
├── robustness_imbalance
│   ├── 01-run-ru-2x.R
│   ├── 02-run-ru-3x.R
│   ├── 03-run-ru-4x.R
│   ├── 04-run-ru-5x.R
│   ├── 05-run-ua-2x.R
│   ├── 06-run-ua-3x.R
│   ├── 07-run-ua-4x.R
│   ├── 08-run-ua-5x.R
│   ├── 09-analysis-ru.R
│   ├── 10-analysis-ua.R
│   ├── 11-make-plots-ru.R
│   ├── 12-make-plots-ua.R
│   ├── data-ru-2x.RData
│   ├── data-ru-3x.RData
│   ├── data-ru-4x.RData
│   ├── data-ru-5x.RData
│   ├── data-ua-2x.RData
│   ├── data-ua-3x.RData
│   ├── data-ua-4x.RData
│   ├── data-ua-5x.RData
│   ├── model.stan
│   ├── ru_rep_bias.pdf
│   ├── ru_rep_loss.pdf
│   ├── ua_rep_bias.pdf
│   └── ua_rep_loss.pdf
├── robustness_nociv
│   ├── 01-run.R
│   ├── 02-analyze-results.R
│   ├── data-nociv.RData
│   └── model.stan
├── LICENSE
└── README.md
```

</details>



# Replicating the Original Model

We refer to the model presented in the published report as the "original model." The original model code is found in the folder named `./model_original`. This folder contains the following files:

* `model.stan` is the Stan code for estimating the model.
* `data-original.RData` is an RData object that contains two dataframes (`data` and `data_daily`).
* `01-run.R` is the R script that imports `data-original.RData` and runs the model.
* `02-analyze-results.R` produces the numbers, tables, and plots found in the published brief report.

To reproduce the results found in the brief report, set your R working directory to `./model_original` and run `01-run.R` and `02-analyze-results.R` in order.


# Robustness Tests

## Review Response Letters

We were fortunate to receive two rounds of very thoughtful and thorough reviews from two very helpful reviewers. These resulted in a much improved manuscript and we are very grateful to the anonymous reviewers. More importantly, these reviews prompted us to undertake a number of robustness tests of our model. We include our response letters to these reviews and all code necessary to replicate all robustness tests.

## Robustness Test Materials

In addition to the replication materials for the results presented in the published brief report, we also provide several sets of robustness tests. These are found in the following folders:

* `./robustness_cross_validation` is a five-fold cross validation to evaluate the model's ability to make predictions out-of-sample. 
* `./robustness_imbalance` is for estimating models that replicate the RU and UA source data 2, 3, 4, and 5 times to assess the model's robustness to source imbalance (see [Review Response 1](./review_response_letters/review_response_01.pdf) p. 13).
* `./robustness_bias_priors` is for evaluating model performance across various alternative prior specifications for the source bias terms (see [Review Response 1](./review_response_letters/review_response_01.pdf) p. 18). This one also produces a plot of all estimated bias terms (see [Review Response 1](./review_response_letters/review_response_01.pdf) p. 7).
* `./robustness_fixed_effects` is for estimating a "fixed effects" version of this model wherein a uniform improper prior is placed on the bias terms (see [Review Response 2](./review_response_letters/review_response_02.pdf).
* `./robustness_nociv` is for evaluating the model's robustness to the removal of civilian fatalities, casualties, and injuries (see [Review Response 1](./review_response_letters/review_response_01.pdf) p. 22).

For replicating each robustness test, please run the R scripts in numerical order. Note that some robustness tests require that `./model_original` has been populated with an estimated Stan model object.

All robustness tests except the cross validation are described in our _Response to Reviewers 1_ and _Response to Reviewers 2_.  


# Cite this Paper

Radford, Benjamin J., Yaoyao Dai, Niklas Stoehr, Aaron Schein, Mya Fernandez, and Hanif Sajid. 2023. "Estimating Conflict Losses and Reporting Biases." _Proceedings of the National Academy of Sciences_ 120 (34). doi:10.1073/pnas.2307372120. URL: [https://www.pnas.org/doi/abs/10.1073/pnas.2307372120](https://www.pnas.org/doi/abs/10.1073/pnas.2307372120).

```
@article{
  doi:10.1073/pnas.2307372120,
  author = {Benjamin J. Radford  and Yaoyao Dai  and Niklas Stoehr  and Aaron Schein  and Mya Fernandez  and Hanif Sajid },
  title = {Estimating conflict losses and reporting biases},
  journal = {Proceedings of the National Academy of Sciences},
  volume = {120},
  number = {34},
  pages = {e2307372120},
  year = {2023},
  doi = {10.1073/pnas.2307372120},
  URL = {https://www.pnas.org/doi/abs/10.1073/pnas.2307372120},
  eprint = {https://www.pnas.org/doi/pdf/10.1073/pnas.2307372120},
  abstract = {Determining the number of casualties and fatalities suffered in militarized conflicts is important for conflict measurement, forecasting, and accountability. However, given the nature of conflict, reliable statistics on casualties are rare. Countries or political actors involved in conflicts have incentives to hide or manipulate these numbers, while third parties might not have access to reliable information. For example, in the ongoing militarized conflict between Russia and Ukraine, estimates of the magnitude of losses vary wildly, sometimes across orders of magnitude. In this paper, we offer an approach for measuring casualties and fatalities given multiple reporting sources and, at the same time, accounting for the biases of those sources. We construct a dataset of 4,609 reports of military and civilian losses by both sides. We then develop a statistical model to better estimate losses for both sides given these reports. Our model accounts for different kinds of reporting biases, structural correlations between loss types, and integrates loss reports at different temporal scales. Our daily and cumulative estimates provide evidence that Russia has lost more personnel than has Ukraine and also likely suffers from a higher fatality to casualty ratio. We find that both sides likely overestimate the personnel losses suffered by their opponent and that Russian sources underestimate their own losses of personnel.}
}
```
