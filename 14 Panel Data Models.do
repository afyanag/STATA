/**************************************************************
   
	*****************
	Panel Data Models
	*****************

Outline:
	Pooled OLS estimator
	Between estimator
	First differences estimator
	Fixed effects within estimator
	Dummy variables regression
	Random effects estimator
	Hausman test for fixed versus random effects

Data files: 
	JTRAIN.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/" 
	
* Example: Effect of training grants on firm scrap rate
use "$datadir/JTRAIN.dta", clear

* Drop missing observations for dependent variable
drop if lscrap==.

describe fcode year lscrap tothrs d88 d89 grant grant_1
list fcode year lscrap tothrs d88 d89 grant grant_1 in 1/9
summarize fcode year lscrap tothrs d88 d89 grant grant_1

* Set as panel data
xtset fcode year
xtdescribe
xtsum fcode year lscrap tothrs d88 d89 grant grant_1

****************************************************************
***** Pooled OLS, between, and first differences estimator *****
****************************************************************

* Pooled OLS estimator
reg lscrap tothrs d88 d89 grant grant_1

* Between estimator
xtreg lscrap tothrs d88 d89 grant grant_1, be 

* Taking first differences
sort fcode year
gen dlscrap=d.lscrap
gen dtothrs=d.tothrs
gen dgrant=d.grant

* First differences estimator
reg dlscrap dtothrs dgrant

******************************************
***** Fixed effects within estimator *****
******************************************

* Fixed effects within estimator
xtreg lscrap tothrs d88 d89 grant grant_1, fe 

* Predict and summarize the individual specific effects a_i
* Stata denotes the individual specific effects as u
predict ai, u
list fcode year lscrap ai in 1/9
summarize ai

**************************************
***** Dummy variables regression *****
**************************************

* Sorting data
sort fcode

* Dummy variables regression with fixed effects
reg lscrap tothrs d88 d89 grant grant_1 i.fcode 
* i.fcode creates one dummy variable for each fcode

* R-squared for fixed effects estimator and dummy variables regression
xtreg lscrap tothrs d88 d89 grant grant_1, fe 
display e(mss)
display e(rss)
scalar rsquared0=e(mss)/(e(mss)+e(rss))
display rsquared0

reg lscrap tothrs d88 d89 grant grant_1 i.fcode
display e(mss)
display e(rss)
scalar rsquared=e(mss)/(e(mss)+e(rss))
display rsquared

************************************
***** Random effects estimator *****
************************************

* Random effects estimator
xtreg lscrap tothrs d88 d89 grant grant_1, re

* The random effects parameter theta
xtreg lscrap tothrs d88 d89 grant grant_1, re theta

* Calculate the random effects parameter theta
scalar theta=1-sqrt(e(sigma_e)^2/(e(sigma_e)^2+3*e(sigma_u)^2))
display theta

********************************************************
***** Hausman test for fixed versus random effects *****
********************************************************

* The Hausman test is used to decide whether to use fixed effects or random effects.
* H0: FE coefficients are not significantly different from the RE coefficients
* Ha: FE coefficients are significantly different from the RE coefficients

* Fixed effects estimator
xtreg lscrap tothrs d88 d89 grant grant_1, fe 
estimates store fixed

* Random effects estimator
xtreg lscrap tothrs d88 d89 grant grant_1, re
estimates store random

* Hausman test for fixed versus random effects
hausman fixed random
* If the Hausman test statistic is insignificant, use RE estimator because it is efficient
* If the Hausman test statistic is significant, use FE estimator because it is consistent
	
