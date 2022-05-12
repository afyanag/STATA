/**************************************************************
   
	**********************
	Instrumental variables
	**********************

Outline:
	IV estimation
	2SLS (two stage least squares)
	Testing for endogeneity

Data files: 
	MROZ.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/"

* Wages for working women example
use "$datadir/MROZ.dta", clear
* keep only working women
keep if inlf==1

describe lwage educ exper expersq fatheduc motheduc
summarize lwage educ exper expersq fatheduc motheduc
list lwage educ exper expersq fatheduc motheduc in 1/10

* Regression model
reg lwage educ
display _b[educ]

*************************
***** IV estimation *****
*************************

* Dependent variable y, endogenous variable x, instrument z
* Coefficient_ols = sum((x-xbar)*(y-ybar))/sum((x-xbar)*(x-xbar))
* Coefficient_iv = sum((z-zbar)*(y-ybar))/sum((z-zbar)*(x-xbar))

* Calculating means
egen mean_fatheduc=mean(fatheduc)
egen mean_educ=mean(educ)
egen mean_lwage=mean(lwage)

* OLS coefficient on educ
gen numerator_ols=(educ-mean_educ)*(lwage-mean_lwage)
gen denominator_ols=(educ-mean_educ)*(educ-mean_educ)
egen sum_numerator_ols=sum(numerator_ols)
egen sum_denominator_ols=sum(denominator_ols)

scalar coeff_ols=sum_numerator_ols/sum_denominator_ols
display coeff_ols

* IV coefficient on educ
gen numerator_iv=(fatheduc-mean_fatheduc)*(lwage-mean_lwage)
gen denominator_iv=(fatheduc-mean_fatheduc)*(educ-mean_educ)

egen sum_numerator_iv=sum(numerator_iv)
egen sum_denominator_iv=sum(denominator_iv)

scalar coeff_iv=sum_numerator_iv/sum_denominator_iv
display coeff_iv

******************************************
***** 2SLS (two stage least squares) *****
******************************************

* Simple regression model with one instrument

* OLS estimation
reg lwage educ 

* 2SLS 
ivreg lwage (educ = fatheduc), first

* 2SLS - first stage 
* Regression of endogenous variable educ on instrument fatheduc
reg educ fatheduc 

* Display R-squared of educ on fatheduc model
display e(r2)

* Predicted values for educ_hat
predict educ_hat, xb

* Compare educ with educ_hat
list educ fatheduc educ_hat in 1/10

* 2SLS - second stage 
* Replace educ with predicted value educ_hat
reg lwage educ_hat
* Coefficients are correct but the standard errors are not correct

******************************************
***** 2SLS (two stage least squares) *****
******************************************

* Multiple regression model with several independent variables and two instruments

* OLS estimation
reg lwage educ exper expersq

* 2SLS 
ivreg lwage (educ = fatheduc motheduc) exper expersq, first

* 2SLS - first stage 
* Regression of endogenous variable educ on instruments fatheduc and motheduc
reg educ exper expersq fatheduc motheduc 

* Testing whether educ and fatheduc and motheduc are correlated
test fatheduc motheduc 
* Predicted values for educ_hat1
predict educ_hat1, xb

* 2SLS - second stage 
* Replace endogenous variable educ with predicted value educ_hat1
reg lwage educ_hat1 exper expersq
* Coefficients are correct but the standard errors are not correct

***********************************
***** Testing for endogeneity *****
***********************************

* Testing for endogeneity of education in model for log wage

* Structural equation
reg lwage educ exper expersq

* Estimate reduced form model for education
reg educ exper expersq fatheduc motheduc 
* Predict the residuals vhat
predict vhat, residual

* Structural equation for log wage that includes residuals vhat
reg lwage educ exper expersq vhat

* H0: coeff on vhat=0 (exogeneity) and H1: coeff on vhat ne 0 (endogeneity)
* The coefficient on vhat is significant so education is endogenous.
