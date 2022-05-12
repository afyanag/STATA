/**************************************************************
   
	************************
	Regression Specification
	************************
   
Outline:
	RESET
	Proxy variables
	Measurement error in the dependent and independent variables
   
Data files: 
	wage1.dta
	wage2.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/"

*******************
****** RESET ******
*******************

* RESET includes squares and cubes of the fitted values in 
* the regression model and tests for joint coefficient significance.

* Wage example
use "$datadir/wage1.dta", clear

* Regression model of wage 
reg wage educ exper tenure
predict yhat, xb
gen yhatsq = yhat^2
gen yhatcube = yhat^3

* RESET, testing for joint significance of coefficients on yhatsq and yhatcube
reg wage educ exper tenure yhatsq yhatcube
* The null hypothesis is the model is well-specified 
test (yhatsq=0) (yhatcube=0) 
* p-value<0.05 so the model is misspecified.

* Regression model of log wage
reg lwage educ exper tenure
predict lyhat, xb
gen lyhatsq = lyhat^2
gen lyhatcube = lyhat^3
reg lwage educ exper tenure lyhatsq lyhatcube
test (lyhatsq=0) (lyhatcube=0)

* Generating squares of variables
gen educsq=educ^2
gen tenuresq=tenure^2

* Regression model of wage including square terms
reg wage educ exper tenure educsq expersq tenuresq
predict yhat1, xb
gen yhat1sq=yhat1^2
gen yhat1cube=yhat1^3
reg wage educ exper tenure educsq expersq tenuresq yhat1sq yhat1cube
test (yhat1sq=0) (yhat1cube=0)

* Regression model of lwage including square terms
reg lwage educ exper tenure educsq expersq tenuresq
predict lyhat1, xb
gen lyhat1sq=lyhat1^2
gen lyhat1cube=lyhat1^3
reg lwage educ exper tenure educsq expersq tenuresq lyhat1sq lyhat1cube 
test (lyhat1sq=0) (lyhat1cube=0) 
* This is a correctly specified model.

**************************
***** Proxy variable *****
**************************

* Wage example with IQ
use "$datadir/wage2.dta", clear

* Generate a standard normal variable
set obs 935
set seed 0
generate r=rnormal()
list r in 1/10

* Generate a fake "abil" variable
gen abil1=5+10*IQ+r
gen abil=round(abil1,1)

* New dataset
summarize wage educ abil IQ
list wage educ abil IQ in 1/5

* True model with educ and ability 
* wage = beta0 + beta1*educ + beta2*abil + u
reg wage educ abil
gen beta2 = _b[abil]
display beta2

* Model with omitted variable abil, coefficient on educ is biased
reg wage educ 

* IQ is proxy for omitted variable abil
* Model for abil on IQ
* abil = delta0 + delta2*IQ + v
reg abil IQ
gen delta2 = _b[IQ]
display delta2

* Model with IQ as proxy for abil
reg wage educ IQ
display _b[IQ]
display beta2*delta2
* The coefficient on educ is not biased in a model with proxy.
* The coefficient on the proxy variable is a multiple of two coefficients
* beta2 (coeff on ability in wage eq) and delta2 (coeff on IQ in abil eq).


*****************************
***** Measurement error *****
*****************************

* Wage example
use "$datadir/wage1.dta", clear

* Generate mismeasured variable wage_m, rounded up to next 5 dollars
gen wage_m=5 if wage>0
replace wage_m=10 if wage>5
replace wage_m=15 if wage>10
replace wage_m=20 if wage>15
replace wage_m=25 if wage>20

* Generate mismeasured variable exper_m, rounded up to next 10 years
gen exper_m=10 if exper>0
replace exper_m=20 if exper>10
replace exper_m=30 if exper>20
replace exper_m=40 if exper>30
replace exper_m=50 if exper>40

list wage wage_m exper exper_m in 1/10
summarize wage wage_m exper exper_m

* Model with no measurement error
reg wage educ exper tenure

* Model with mismeasured dependent variable wage_m
reg wage_m educ exper tenure
* Coefficients are not biased, but the coefficient on exper became insignificant.

* Model with mismeasured independent variable exper_m
reg wage educ exper_m tenure
* Attentuation bias - coefficient on exper is biased toward zero and became insignificant.
