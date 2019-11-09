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

# what is probablity that 4 out of 10 next customers will make a purchase? The probablity of a purchase on one tril is .3
dbinom(x = 4,size = 10,prob = 0.3)


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



# t-test in R -------------------------------------------------------------

# We will use builin dataset sleep, for more info ?sleep

# two sample t-test
# 1 let's first check the independent t-test assumptions 
# Assumption 1: are the two samples independent, well here we can only assume that the experiment was designed and prepared in such a way that the samples are independent. So, yes.

# Assumption 2: are the data in two groups normally distributed?
if(!require(car)) install.packages("car")
library(car)
library(tidyverse)
group_2 <- sleep$group == 2
qqPlot(sleep$extra[group_2])
qqPlot(sleep$extra[! group_2])
# On the qqplot the extra variable is within the confidence area.
# Other ways to check normality is Shapiro-Wilk normality test fro two groups:
shapiro.test(sleep$extra[group_2]) # p-value = 0.3511 > 0.05 
shapiro.test(sleep$extra[! group_2]) # p-value = 0.4079 > 0.05
# From the output two p-values are greater than 0.05, so we can assume  the normality

# Assumption 3: Do the two populations have the same variances?
# Checking if there are no NAs
colSums(is.na(sleep)) # good, no NAs
# Let's check the summary statistics:
sleep %>% group_by(group) %>%
  summarise(
    count = n(),
    mean = mean(extra, na.rm = TRUE),
    sd = sd(extra, na.rm = TRUE))
# let's see the box plots as well:
sleep %>% ggplot(aes(y=extra,color = group)) +
  geom_boxplot()
# To check the variances we will perform an F test to compare the variances of two samples from normal populations:
f_test <- var.test(extra ~ group,data = sleep)
f_test # p-value = 0.7427 > 0.05. => no significant difference between the variances of two groups. therefor we can use t-test with two equal variances.
# Now we can do t-test, to answer the question if there is any significant difference between two groups?
t_test <- t.test(extra ~ group,data = sleep, var.equal = TRUE)
t_test # the p-value of the test is 0.07919 > 0.05. We can not reject the null hyposesis and can conclude that the two groups are not significantly different.
# to access individual componenets of the test result type: t_test$ and select from the list.
# Should we want to perform one-sided tests:
t_test_less <- t.test(extra ~ group,data = sleep, var.equal = TRUE, alternative = "less") 
t_test_greater <- t.test(extra ~ group,data = sleep, var.equal = TRUE, alternative = "greater")

# Finally, let's show the test results, with confidence levels, using ggplot:
sleep %>% ggplot(aes(x = group, y = extra)) +
  theme_bw() +
  stat_summary(fun.data = mean_cl_normal)
# Voila from the plot we can also see that the confidence intervals of the two groups overlap, which supports the null hyposesis.
