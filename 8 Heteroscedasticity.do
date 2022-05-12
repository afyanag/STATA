/**************************************************************
   
	******************
	Heteroscedasticity
	******************

Outline:
	Graphical analysis of heteroscedasticity 
	Heteroscedasticity tests
		Breusch-Pagan test
		White test
		Alternative White test
	Heteroscedasticity robust standard errors
	Weighted Least Squares (WLS)
	Feasible Generalized Least Squares (FGLS)

Data files: 
	hprice1.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/"

****************************************************
***** Graphical analysis of heteroscedasticity *****
****************************************************

* Data set on house prices
use "$datadir/hprice1.dta", clear

describe price lprice lotsize sqrft bdrms
summarize price lprice lotsize sqrft bdrms
list price lprice lotsize sqrft bdrms in 1/10

* Regression model for price
reg price lotsize sqrft bdrms
predict uhat, residual
* Graph of residuals against independent variable
graph twoway (scatter uhat sqrft)
* Graph of residuals against fitted values
rvfplot, yline(0) 

* Regression model for lprice
reg lprice lotsize sqrft bdrms
predict uhat1, residual
* Graph of residuals against independent variable
graph twoway (scatter uhat1 sqrft)
* Graph of residuals against fitted values
rvfplot, yline(0) 


************************************
***** Heteroscedasticity tests *****
************************************

* Heteroscedasticity tests involve estimating the regression model, 
* regressing the squared residuals uhatsq on combination of independent variables
* and doing F-test and LM-test for joint coefficient significance.

* Data set on house prices
use "$datadir/hprice1.dta", clear

* Generate squares and interaction of independent variables
gen lotsizesq=lotsize*lotsize
gen sqrftsq=sqrft*sqrft
gen bdrmssq=bdrms*bdrms
gen lotsizeXsqrft=lotsize*sqrft
gen lotsizeXbdrms=lotsize*bdrms
gen sqrftXbdrms=sqrft*bdrms

***** Heteroscedasticity tests for price *****

* Regression model
reg price lotsize sqrft bdrms

* Get residuals and predicted values, and square them
predict uhat, residual
gen uhatsq = uhat^2
predict yhat, xb
gen yhatsq = yhat^2


****** Breusch-Pagan test *****

* Regression for Breusch-Pagan test
reg uhatsq lotsize sqrft bdrms

* Number of independent variables k1 
gen k1=3

* F-test and LM-test for heteroscedasticity
display "F-stat: " (e(r2)/k1)/((1-e(r2))/(e(N)-k1-1))
display "p-value: " Ftail(k1,e(N)-e(df_m)-1,(e(r2)/k1)/((1-e(r2))/(e(N)-k1-1)))

display "LM-stat: " e(N)*e(r2)
display "p-value: " chi2tail(k1, e(N)*e(r2))


***** White test *****

* Regression for White test
reg uhatsq lotsize sqrft bdrms lotsizesq sqrftsq bdrmssq lotsizeXsqrft lotsizeXbdrms sqrftXbdrms

* Number of independent variables k2
gen k2=9

* F-test and LM-test for heteroscedasticity
display "F-stat: " (e(r2)/k2)/((1-e(r2))/(e(N)-k2-1))
display "p-value: " Ftail(k2,e(N)-e(df_m)-1,(e(r2)/k2)/((1-e(r2))/(e(N)-k2-1)))

display "LM-stat: " e(N)*e(r2)
display "p-value: " chi2tail(k2, e(N)*e(r2))


**** Alternative White test *****

* Regression for alternative White test
reg uhatsq yhat yhatsq

* Number of independent variables k3
gen k3=2

* F-test and LM-test for heteroscedasticity
display "F-stat: " (e(r2)/k3)/((1-e(r2))/(e(N)-k3-1))
display "p-value: " Ftail(k3,e(N)-e(df_m)-1,(e(r2)/k3)/((1-e(r2))/(e(N)-k3-1)))

display "LM-stat: " e(N)*e(r2)
display "p-value: " chi2tail(k3, e(N)*e(r2))

* All tests show heteroscedasticity for price 


***** Heteroscedasticity tests for log price *****

* Regression model for log price
reg lprice lotsize sqrft bdrms

* Get residuals and predicted values, and square them
predict uhat1, residual
gen uhat1sq = uhat1^2
predict yhat1, xb
gen yhat1sq = yhat1^2


****** Breusch-Pagan test *****

* Regression for Breusch-Pagan test
reg uhat1sq lotsize sqrft bdrms

* Number of independent variables k1 
* gen k1=3

* F-test and LM-test for heteroscedasticity
display "F-stat: " (e(r2)/k1)/((1-e(r2))/(e(N)-k1-1))
display "p-value: " Ftail(k1,e(N)-e(df_m)-1,(e(r2)/k1)/((1-e(r2))/(e(N)-k1-1)))

display "LM-stat: " e(N)*e(r2)
display "p-value: " chi2tail(k1, e(N)*e(r2))


***** White test *****

* Regression for White test
reg uhat1sq lotsize sqrft bdrms lotsizesq sqrftsq bdrmssq lotsizeXsqrft lotsizeXbdrms sqrftXbdrms

* Number of independent variables k2
* gen k2=9

* F-test and LM-test for heteroscedasticity
display "F-stat: " (e(r2)/k2)/((1-e(r2))/(e(N)-k2-1))
display "p-value: " Ftail(k2,e(N)-e(df_m)-1,(e(r2)/k2)/((1-e(r2))/(e(N)-k2-1)))

display "LM-stat: " e(N)*e(r2)
display "p-value: " chi2tail(k2, e(N)*e(r2))


**** Alternative White test *****

* Regression for alternative White test
reg uhat1sq yhat1 yhat1sq

* Number of independent variables k3
* gen k3=2

* F-test and LM-test for heteroscedasticity
display "F-stat: " (e(r2)/k3)/((1-e(r2))/(e(N)-k3-1))
display "p-value: " Ftail(k3,e(N)-e(df_m)-1,(e(r2)/k3)/((1-e(r2))/(e(N)-k3-1)))

display "LM-stat: " e(N)*e(r2)
display "p-value: " chi2tail(k3, e(N)*e(r2))

* All tests show homoscedasticity for lprice 


*****************************************************
***** Heteroscedasticity robust standard errors *****
*****************************************************

* Robust standard errors correct for heteroscedasticity

* Regression model for price
reg price lotsize sqrft bdrms

* Regression model for price with robust standard errors
reg price lotsize sqrft bdrms, robust
* Same coefficients, but robust standard errors

* Regression model for log price
reg lprice lotsize sqrft bdrms

* Regression model for log price with robust standard errors
reg lprice lotsize sqrft bdrms, robust
* Robust standard errors are not needed since log price is homoscedastic 


****************************************
***** Weighted Least Squares (WLS) *****
****************************************

* When the heteroscedastisticy form is known var(u|x)=(sigma^2)*(sqrft), 
* use WLS with weight=1/sqrft.

* WLS: estimate model with weight=1/sqrft 
reg price lotsize sqrft bdrms [aweight=1/sqrft]

* Multiply all variables and the constant by 1/sqrt(sqrft)
gen pricestar = price/sqrt(sqrft) 
gen lotsizestar = lotsize/sqrt(sqrft) 
gen sqrftstar = sqrft/sqrt(sqrft) 
gen bdrmsstar = bdrms/sqrt(sqrft) 
gen constantstar = 1/sqrt(sqrft) 

*  WLS: estimate model with transformed variables by OLS
reg pricestar lotsizestar sqrftstar bdrmsstar constantstar, noconstant


*******************************
****** Feasible GLS (FGLS)*****
*******************************

* When the heteroscedasticity form is not known, 
* var(u|x) = sigma^2*exp(delta0 + delta1*lotsize + delta2*sqrft + delta3*bdrms)
* estimate hhat and use WLS with weight=1/hhat.

* Heteroscedasticity form, estimate hhat
reg price lotsize sqrft bdrms
predict u, residual
gen g=ln(u*u)
reg g lotsize sqrft bdrms
predict ghat, xb
gen hhat=exp(ghat)

* FGLS: estimate model using WLS with weight=1/hhat
reg price lotsize sqrft bdrms [aweight=1/hhat]

* Multiply all variables and the constant by 1/sqrt(hhat)
gen pricestar1 = price/sqrt(hhat)
gen lotsizestar1 = lotsize/sqrt(hhat)
gen sqrftstar1 = sqrft/sqrt(hhat)
gen bdrmsstar1 = bdrms/sqrt(hhat)
gen constantstar1 = 1/sqrt(hhat)

* FGLS: estimate model with transformed variables by OLS
reg pricestar1 lotsizestar1 sqrftstar1 bdrmsstar1 constantstar1, noconstant
