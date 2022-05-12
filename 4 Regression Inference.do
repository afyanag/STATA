/**************************************************************
   
	********************
	Regression Inference
	********************

Outline:
	Shapiro-Wilk test for normality
	t-test for coefficient significance
	F-test for single coefficient significance
	F-test for joint coefficient significance
	F-test for overall significance
	Lagrange Multiplier chi-square test for coefficient significance
	
Data Files:
	wage1.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/" 

*************************************
***** Shapiro-Wilk test for normality 
*************************************

* Wage example
use "$datadir/wage1.dta",clear

* Draw a histogram of variable
histogram wage
histogram lwage

* The Shapiro Wilk test for normality 
swilk wage
swilk lwage
* if p-value <0.05, variable is not normally distributed

*****************************************
***** t-test for coefficient significance
*****************************************

* Wage example
use "$datadir/wage1.dta",clear

* Run Regression
reg wage educ exper tenure female 

* Hypothesis testing method 1: compare t-statistic with t-critical value(s)

* Display coefficient
gen coefficient=_b[exper]
display _b[exper]

* Display standard error
gen se=_se[exper]
display _se[exper]

* Calculate t-statistic = coefficient/standard error
gen tstat=_b[exper]/_se[exper]
display tstat

* Degrees of freedom (n-k-1)
display e(df_r)

* t-critical value at 5% significance level 
display invttail(e(df_r),0.025)
* If t-statistic is in the rejection region then reject null, coefficient is significant


* Hypothesis testing method 2: compare p-value with significance level (5%)

* H0: beta[exper] = 0;   H1: beta[exper] not equal to 0 
* P-value for a two-tailed test of coefficient signficance
display 2*ttail(e(df_r), abs(tstat))
* If p-value < significance level then reject null, coefficient is significant
		
* H0: beta[exper]<=0;   H1: beta[exper]>0  
* P-value for an upper one-tailed test of positive coefficient
display ttail(e(df_r),tstat)

* H0: beta[exper]>=0;   H1: beta[exper]<0  
* P-value for a lower one-tailed test of negative coefficient 
display 1-ttail(e(df_r),tstat)


* Hypothesis testing method 3: calculate confidence intervals

* Critical value at 5% significance level and 95% confidence interval
display "critical value at 5% significance level is " invttail(e(df_r),0.025)
display "lower bound at 95% confidence level is " _b[exper] - 1.96*_se[exper]
display "upper bound at 95% confidence level is " _b[exper] + 1.96*_se[exper]
* If confidence interval does not contain 0 then reject null, coefficient is significant

* Critical value at 10% significance level and 90% confidence interval
display "critical value at 10% significance level is " invttail(e(df_r),0.05)
display "lower_bound at 90% confidence level is" _b[exper] - 1.65*_se[exper]
display "upper bound at 90% confidence level is" _b[exper] + 1.65*_se[exper]


* The three methods of comparing t-statistic with critical values, p-value with significance level, and confidence intervals lead to the same conclusion.

************************************************
***** F-test for single coefficient significance
************************************************

* F-test for single coefficient significance is an alternative to t-test.

* Wage example
use "$datadir/wage1.dta",clear

* H0: beta[exper]=0 
* Restricted model: wage = alpha0 + alpha1*educ + alpha3*tenure + alpha4*female + e
reg wage educ tenure female

* SSR for the restricted model ssr_r
gen ssr_r=e(rss)

* Unrestricted model: wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + beta4*female + u
reg wage educ exper tenure female

* SSR for the unrestricted model = ssr_ur, q = number of restrictions and df_denom=n-k-1
gen ssr_ur=e(rss)
gen q=1

* Calculate F-stat using ssr_r and ssr_ur 
* F-stat=((ssr_r-ssr_ur)/q) / (ssr_ur/(n-k-1))
gen F_stat=((ssr_r-ssr_ur)/q) / (ssr_ur/e(df_r))
display F_stat

* Calculate F-critical value
display invFtail(q,e(df_r),0.05)
* If F-stat > F-critical value then reject null, coefficient is significant

* p-value for F-test
gen F_pvalue= Ftail(q,e(df_r),F_stat)
display F_pvalue
* If F p-value<0.05 then reject null, coefficient is significant

* F-test for coefficient significance using Stata commands
reg wage educ exper tenure female
test exper=0
* The F-statistic is different from the t-statistic for the coeff on exper 
* but the p-value is same for the F-test and t-test.

* Above is t-test or F-test for coefficient on exper = 0
* t-test for the variable experience = 0 is not what we want to test
ttest exper=0

***********************************************
***** F-test for joint coefficient significance  
***********************************************

* F-test for joint coefficient significance is used to test for several coefficients to be jointly signficantly different from zero.

* Wage example
use "$datadir/wage1.dta",clear

* H0: beta[exper]=0 beta[tenure]=0
* Restricted model: wage = alpha0 + alpha1*educ + alpha4*female + e
reg wage educ female

* SSR for the restricted model ssr_r
gen ssr_r=e(rss)

* Unrestricted model: wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + beta4*female + u
reg wage educ exper tenure female

* SSR for the unrestricted model = ssr_ur, q = number of restrictions and df_denom=n-k-1
gen ssr_ur=e(rss)
gen q=2

* Calculate F_stat using ssr_r and ssr_ur 
* F-stat=((ssr_r-ssr_ur)/q) / (ssr_ur/(n-k-1))
gen F_stat=((ssr_r-ssr_ur)/q) / (ssr_ur/e(df_r))
display F_stat

* F- critical value
display invFtail(q,e(df_r),0.05)
* If F-stat > F-critical value then reject null, coefficients are jointly significant

* p-value for F-test
gen F_pvalue= Ftail(q,e(df_r),F_stat)
display F_pvalue
* If F p-value<0.05 then reject null, coefficients are jointly significant

*** F-test using Stata commands
reg wage educ exper tenure female
test (exper=0) (tenure=0)

***************************************************
***** F-test for overall significance of regression 
***************************************************

* F-test for overall signficance is an F-test for all coefficients to be jointly significantly different from zero.

* Wage example
use "$datadir/wage1.dta",clear

* H0: beta[educ]=0 beta[exper]=0 beta[tenure]=0 beta[female]=0
* Restricted model: wage = alpha0 + e
* Note that alpha0 = avg(wage)
reg wage
summarize wage
* SSR for the restricted model ssr_r
gen ssr_r=e(rss)

* Unrestricted model: wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + beta4*female + u
reg wage educ exper tenure female
display e(F)

* SSR for the unrestricted model = ssr_ur, q = number of restrictions and df_denom=n-k-1
gen ssr_ur=e(rss)
gen q=4

* Calculate F_stat using ssr_r and ssr_ur 
* F-stat=((ssr_r-ssr_ur)/q) / (ssr_ur/(n-k-1))
gen F_stat=((ssr_r-ssr_ur)/q) / (ssr_ur/e(df_r))
display F_stat

* Calculate F-statistic using R-squared (alternative way)
* F-stat = (R^2/k)/(1-R^2)/(n-k-1)
gen F_stat1=(e(r2)/e(df_m)) / ((1-e(r2))/e(df_r))
display F_stat1

* F-critical value 
display invFtail(q,e(df_r),0.05)
* If F-stat > F-critical value then reject null, coefficients are jointly significant

* p-value for F-test
gen F_pvalue= Ftail(q,e(df_r),F_stat)
display F_pvalue
* If F p-value<0.05 then reject null, coefficients are jointly significant

*** F-test using Stata commands
reg wage educ exper tenure female
test (educ=0) (exper=0) (tenure=0) (female=0)

* F-stat and F p-value are the same as reported in the regression output

***********************************************************
***** Lagrange Multiplier test for coefficient significance  
***********************************************************

* Lagrange Multiplier test is a chi-square test for several coefficient to be jointly significantly different from zero.

* Wage example
use "$datadir/wage1.dta",clear

* Unrestricted model: wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + beta4*female + u
* H0: beta[exper]=0 beta[tenure]=0

* Restricted model: wage = alpha0 + alpha1*educ + alpha4*female + e
* Regress dependent variable on the restricted set of independent variables
reg wage educ female

gen q=2 /*2 restrictions*/

* Get residuals ehat
predict ehat, residuals 

* Regress residuals ehat on all independent variables
reg ehat educ exper tenure female

* LM statistic=n*(R_e)^2 = n * R-squared of above regression
display e(N)
display e(r2)
gen LM_stat=e(N)*e(r2)
display "LM_stat=" e(N)*e(r2)

* Critical value for chi-square distribution 
display invchi2tail(q,0.05)
* If LM-stat > chi2 critical value then reject null, coefficients are jointly significant

* P-value for chi-square distribution 
display nchi2tail(q,0.05,LM_stat)
* If p-value < 0.05 then reject null, coefficients are jointly significant

