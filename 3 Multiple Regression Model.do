/**************************************************************
   
	************************************
	Multiple Regression Model
	************************************

Outline:
	Multiple regression
	Partialling out
	Goodness of fit (R-squared and adjusted R-squared)
	Perfect collinearity 
	Multicollinearity using VIF	
	Omitted variable bias
	Variance in misspecified models	
	Homoscedasticity and heteroscedasticity

Data Files:
	wage1.dta
	CEOSAL1.dta
	HTV.dta
	elemapi2.dta

***************************************************************/

clear all
set more off 
global datadir "C:\Econometrics\Data" 


*************************************************************************
**************************  Multiple regression *************************
*************************************************************************

* Run a multiple regression analysis, interpret the coefficients
* See how the coefficients are different for simple vs multiple regression
	
* Wage Example
use "$datadir/wage1.dta",clear
list wage educ exper tenure in 1/10
describe wage educ exper tenure
summarize wage educ exper tenure

* Compare results from simple regression and multiple regression:
* If education increases by 1 year, by how many dollars does wage increase? 

* Simple regression 
reg wage educ

* Multiple regressions
reg wage educ exper
reg wage educ exper tenure

* Display the coefficients
display _b[educ]
display _b[exper]
display _b[tenure]

* Predicted values and residuals (same as simple regression)
predict wagehat, xb
predict uhat, residual

summarize wage wagehat uhat
* wage = wagehat + uhat
* mean(uhat)=0 and mean(wage)=mean(wagehat)


*************************************************************************
************************** Partialling out ******************************
*************************************************************************

* Partialling out shows the coefficients beta1 are the same in first and last regression.

* Wage example
use "$datadir/wage1.dta",clear

* wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + u
reg wage educ exper tenure

* educ = alpha0 + alpha2*exper + alpha3*tenure + e
reg educ exper tenure

* predict residuals ehat
predict  ehat, residual

* wage = gamma0 + beta1*ehat + v
reg wage ehat
 

*************************************************************************
************** Goodness of fit (R-squared and adjusted R-squared) *******
*************************************************************************

* Goodness of fit measures are R-squared and adjusted R-squared showing
* the proportion of variation explained by the regression

* Wage example
use "$datadir/wage1.dta",clear

* Run a simple regression with 1 regressor
reg wage educ 

* Display stored R-squared
display e(r2)

* Display stored adjusted R-squared
display e(r2_a)

* Run a multiple regression with 2 regressors
reg wage educ exper 
display e(r2)
display e(r2_a)

* Run a multiple regression with 3 regressors
reg wage educ exper tenure
display e(r2)
display e(r2_a)

* To calculate R-squared manually
gen SSE=e(mss) /*sum of squares explained or model*/
gen SSR=e(rss) /*sum of squares residual*/
gen SST=e(mss)+e(rss) /*sum of squares total*/

gen df_SSE=e(df_m) /*degrees of freedom for model = k = # regressors */
gen df_SSR=e(N)-e(df_m)-1 /*degress of freedom for residual = n-k-1 */
gen df_SST=e(N)-1 /*degrees of freedom total = n-1 = number of observ - 1 */

* Formula for R-squared
gen R_squared=SSE/SST
* same as R-squared = 1 - SSR/SST
display R_squared

* Formula for adjusted R-squared
gen adj_R_squared=1-(SSR/df_SSR)/(SST/df_SST)
display adj_R_squared
 
 
* CEO Salary Example
use "$datadir/CEOSAL1.dta",clear
list salary lsalary roe sales lsales in 1/10
describe salary lsalary roe sales lsales
summarize salary lsalary roe sales lsales

*Linear form
reg salary roe sales

* Linear-log form
reg salary roe lsales 

* Log-linear form
reg lsalary roe sales 

* Log-log form
reg lsalary roe lsales

* Compare R-squared and adjusted R-squared
* SST are different for salary vs lsalary
* Log-log model has the highest adjusted R-squared


*************************************************************************
**************** Perfect collinearity ***********************************
*************************************************************************

* Perfect collinearity is an exact linear relationship between the variables
* Perfect collinearity example is when male = 1-female

* Wage example
use "$datadir/wage1.dta",clear

* Model for wage with female
reg wage educ female 

* Male is an exact linear function of female (perfect collinearity)
gen male=1-female

* Try to run regression with both female and male
reg wage educ female male
* This model cannot be estimated because of perfect collinearity
* Stata drops one variable, but it chooses which one to drop

* Run regression with "no constant" option
reg wage educ female male, nocons


*************************************************************************
************* Multicollinearity using VIF *******************************
*************************************************************************

* Multicollinearity is when regressors are highly correlated with each other.

* Test scores example
use "$datadir/elemapi2.dta", clear

keep api00 avg_ed grad_sch col_grad
describe
summarize
list in 1/10

* Multicollinearity: parents' average education is collinear with
* whether they completed grad school or college

* Correlation table
correlate avg_ed grad_sch col_grad 

* Run regression, find VIF. If VIF>10 then drop the variable
reg api00 avg_ed grad_sch col_grad
vif

* Run regression without variable that has high VIF
reg api00 grad_sch col_grad
vif

* Run regression without the other variables
reg api00 avg_ed
vif 
*VIF=1 for simple regression


*************************************************************************
**************** Omitted variable bias **********************************
*************************************************************************

* Omitted variable bias is when an omitted variable causes biased coefficients

* Wage 2 example
use "$datadir/HTV.dta",clear
keep wage educ abil
describe
summarize
list in 1/5

*True model with educ and ability 
* wage = beta0 + beta1*educ + beta2*abil + u
reg wage educ abil
gen beta1 = _b[educ]
gen beta2 = _b[abil]

* Model between ability and education
* abil = delta0 + delta1*educ + v
reg abil educ 
gen delta1 = _b[educ]

* Model where ability is omitted variable, so coefficient on educ is biased
* wage = (beta0+beta2*delta0) + (beta1+beta2*delta1)*educ +(beta2*v+u)
reg wage educ 
gen beta1_biased=_b[educ]
display beta1_biased

* Calculate bias and biased coefficient
gen bias = beta2*delta1
display bias

gen beta1_biased_calculated=beta1+beta2*delta1
display beta1_biased_calculated


* Wage example
use "$datadir/wage1.dta",clear

*True model with educ and exper
reg wage educ exper

* Model between exper and education
reg exper educ

* Model where exper is omitted, so coefficient on educ is biased
reg wage educ 


*************************************************************************
************* Variance in misspecified models ***************************
*************************************************************************

* Variance in misspecified model (same as omitted variable bias example) 

* Wage 2 example
use "$datadir/HTV.dta",clear

* True model with educ ability
reg wage educ abil

* Model where ability is omitted variable
reg wage educ
* The coefficient on educ is biased but has lower standard error


*************************************************************************
******************* Homoscedasticity and heteroscedasticity *************
*************************************************************************

* Homoscedasticy is when the variance of the error is constant for each x
* Heteroscedasticy is when the variance of the error is not constant for each x

* Wage example
use "$datadir/wage1.dta",clear	

reg wage educ exper tenure

* Plotting residuals with "graph twoway scatter"
predict uhat, residual
graph twoway scatter uhat educ
graph twoway scatter uhat exper

* Ploting residuals with "rvpplot" (same graphs as above)
rvpplot educ, yline(0) 
rvpplot exper, yline(0) 
* Graphs show heteroscedasticity for educ and homoscedasticity for exper
