/**************************************************************
   
	***********************
	Probit and Logit Models
	***********************

Outline:
	Probit and logit models
	Predicted probabilities
	Marginal effects
	Pseudo R-squared
	Percent correctly predicted

Data Files: 
	MROZ.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/" 

***********************************
***** Probit and logit models *****
***********************************

* Model of being in labor force for women
use "$datadir/MROZ.dta", clear

describe inlf nwifeinc educ exper age kidslt6
summarize inlf nwifeinc educ exper age kidslt6
list inlf nwifeinc educ exper age kidslt6 in 1/10
tabulate inlf

* Linear probability model (LPM) 
reg inlf nwifeinc educ exper age kidslt6

* Probit model 
probit inlf nwifeinc educ exper age kidslt6

* Logit model 
logit inlf nwifeinc educ exper age kidslt6

***********************************
***** Predicted probabilities *****
***********************************

* Predicted probabilities for LPM
quietly regress inlf nwifeinc educ exper age kidslt6
predict inlfhat_lpm, xb

* Predicted probablities for probit model
quietly probit inlf nwifeinc educ exper age kidslt6 
predict inlfhat_probit, pr

* Predicted probabilities for logit model
quietly logit inlf nwifeinc educ exper age kidslt6
predict inlfhat_logit, pr

* Summarize predicted values for inlf
summarize inlf inlfhat_lpm inlfhat_probit inlfhat_logit 
list inlf inlfhat_lpm inlfhat_probit inlfhat_logit in 1/5
list inlf inlfhat_lpm inlfhat_probit inlfhat_logit in 601/605

****************************
***** Marginal effects *****
****************************

* Linear probability model (LPM) 
reg inlf nwifeinc educ exper age kidslt6
* Coefficients are marginal effects in a linear model

* Probit model
probit inlf nwifeinc educ exper age kidslt6

* Probit - marginal effect at the mean
margins, dydx(*) atmeans

* Probit - average marginal effect
margins, dydx(*)

* Logit model
logit inlf nwifeinc educ exper age kidslt6

* Logit - marginal effect at the mean
margins, dydx(*) atmeans

* Logit - average marginal effect
margins, dydx(*)

****************************
***** Pseudo R-squared ***** 
****************************

* Probit model - unrestricted model with all variables
probit inlf nwifeinc educ exper age kidslt6

* Pseudo R-squared
display e(r2_p)

* Log-likelihood for unrestricted model
display e(ll)
gen LLur=e(ll)

* Probit model with only constant
probit inlf
* Log-likelihood for model with only constant
display e(ll)
gen LL0=e(ll) 

* Calculate pseudo R-squared
gen pseudo_r2=1-LLur/LL0
display pseudo_r2

***************************************
***** Percent correctly predicted *****
***************************************

* Percent correctly predicted for probit model
quietly probit inlf nwifeinc educ exper age kidslt6
estat classification

* Percent correctly predicted for logit model
quietly logit inlf nwifeinc educ exper age kidslt6
estat classification
