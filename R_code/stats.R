############ Statistics in R Part 1 ############ 


# Probability Distribution R Functions ---------------------------------

# p - probability distribution function
# q - quantile, the inverse DF for a continuous random variable or the quantile function
# d - density, the probability mass function (PMF) for a discrete random variable or the probability # density function (PDF) for a continuous random variable
# r - a random variable having the specified distribution
# * For a continuous distribution use p and q functions
# * For a discrete distribution use d function that calculates the density 
##    Distribution                   p         q         d         r        
##    <chr>                          <chr>     <chr>     <chr>     <chr>    
##  1 Beta                           pbeta     qbeta     dbeta     rbeta    
##  2 Binomial                       pbinom    qbinom    dbinom    rbinom   
##  3 Cauchy                         pcauchy   qcauchy   dcauchy   rcauchy  
##  4 Chi-Square                     pchisq    qchisq    dchisq    rchisq   
##  5 Exponential                    pexp      qexp      dexp      rexp     
##  6 F                              pf        qf        df        rf       
##  7 Gamma                          pgamma    qgamma    dgamma    rgamma   
##  8 Geometric                      pgeom     qgeom     dgeom     rgeom    
##  9 Hypergeometric                 phyper    qhyper    dhyper    rhyper   
## 10 Logistic                       plogis    qlogis    dlogis    rlogis   
## 11 Log Normal                     plnorm    qlnorm    dlnorm    rlnorm   
## 12 Negative Binomial              pnbinom   qnbinom   dnbinom   rnbinom  
## 13 Normal                         pnorm     qnorm     dnorm     rnorm    
## 14 Poisson                        ppois     qpois     dpois     rpois    
## 15 Student t                      pt        qt        dt        rt       
## 16 Studentized Range              ptukey    qtukey    dtukey    rtukey   
## 17 Uniform                        punif     qunif     dunif     runif    
## 18 Weibull                        pweibull  qweibull  dweibull  rweibull 
## 19 Wilcoxon Rank Sum Statistic    pwilcox   qwilcox   dwilcox   rwilcox  
## 20 Wilcoxon Signed Rank Statistic psignrank qsignrank dsignrank rsignrank


# Calculating and showing confidence intervals ----------------------------
library(tidyverse)
imdb_5000 <- read_csv("data/imdb_5000.csv")
str(imdb_5000)
imdb_5000$color <- factor(imdb_5000$color)
sum(is.na(imdb_5000$color))
unique(imdb_5000$color)
levels(imdb_5000$color)
sum(is.na(imdb_5000$imdb_score))
# let's create confidence intervals for movies grouped by colors
imdb_5000 %>% group_by(color) %>%
  summarise(
    mean = mean(imdb_score), # sample mean
    n = n(), # sample size
    SE = sd(imdb_score)/sqrt(n), # standard error
    t_crit = qt(p = 0.975, df = n - 1), # critical t value for the given n and p = 0.95
    err = t_crit * SE, # error limit
    lower = mean - err, # lower boundary of the conf. interval
    upper = mean + err # upper boundary of the conf. interval
  )
# let's show the confidence interval using ggplot
imdb_5000 %>% ggplot(aes(x = color, y = imdb_score)) +
  stat_summary(geom = 'pointrange', fun.data = mean_cl_normal, shape = 3) + # mean_cl_normal - calculate confidence interval using t-distribution
# shape = 3 - we use + sign instead of dot
  scale_x_discrete('Movies', labels = c("Black-white","Color"),na.translate = FALSE) + # na.translate = FALSE - we remove na from x.
  labs(y = "IMDB rating")
