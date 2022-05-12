/**************************************************************
   
	***********************************
	Regression Variable Transformations
	***********************************
   
Outline:
	Regression with quadratic term
	Regression with interaction term
	Regression with rescaled variables
	Regression with logged rescaled variables
   
Files:
	wage1.dta
	CEOSAL2.dta

***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data"


********************************************
****** Regression with quadratic term ******
********************************************
	
* Wage example
use "$datadir/wage1.dta",clear

* Regression 
reg wage educ
predict wagehat1, xb
graph twoway (scatter wage educ) (scatter wagehat1 educ)

* Regression with quadratic term
* wage = beta0 + beta1*educ + beta2*educsq + u
gen educsq=educ*educ
reg wage educ educsq
predict wagehat2, xb
graph twoway (scatter wage educ) (scatter wagehat2 educ)

* Calculate min or max point for partial effect, educ*=-beta1/2*beta2
display -(_b[educ])/(2*_b[educsq])

* Partial effect of educ on wage = beta1 + 2*beta2*educ
display (_b[educ]+2*_b[educsq]*5)
display (_b[educ]+2*_b[educsq]*6.18)
display (_b[educ]+2*_b[educsq]*10)
display (_b[educ]+2*_b[educsq]*15)

* Calculate partial effect at the mean
egen mean_educ=mean(educ)
display mean_educ
gen pem_educ=_b[educ]+2*_b[educsq]*mean_educ
display pem_educ

* Calculating average partial effect
gen pe_educ=_b[educ]+2*_b[educsq]*educ
egen ape_educ=mean(pe_educ)
display ape_educ

* Example with experience instead of education
	
* Regression 
reg wage exper
predict wagehat3, xb
graph twoway (scatter wage exper) (scatter wagehat3 exper)

* Regression with quadratic term
* wage = beta0 + beta1*exper + beta2*expersq + u
* expersq is given in dataset
reg wage exper expersq
predict wagehat4, xb
graph twoway (scatter wage exper) (scatter wagehat4 exper)

* Calculate min or max point for partial effect, exper*=-beta1/2*beta2
display -(_b[exper])/(2*_b[expersq])

* Partial effect of exper on wage = beta1 + 2*beta2*exper
display (_b[exper]+2*_b[expersq]*10)
display (_b[exper]+2*_b[expersq]*20)
display (_b[exper]+2*_b[expersq]*24.3)
display (_b[exper]+2*_b[expersq]*30)

* Calculating partial effect at the mean
egen mean_exper=mean(exper)
display mean_exper
gen pem_exper=_b[exper]+2*_b[expersq]*mean_exper
display pem_exper

* Calculating average partial effect
gen pe_exper=_b[exper]+2*_b[expersq]*exper
egen ape_exper=mean(pe_exper)
display ape_exper


********************************************
***** Regression with interaction term *****
********************************************

* Regression
reg wage educ exper tenure
predict wagehat5, xb
graph twoway (scatter wage educ) (scatter wagehat5 educ)

* Generate interaction term
gen educXexper=educ*exper
gen experXtenure=exper*tenure

* Regression with interaction term
* wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + beta4*educ*exper
reg wage educ exper tenure educXexper 
predict wagehat6, xb
graph twoway (scatter wage educ) (scatter wagehat6 educ)

* Calculate partial effect of education on wage at several levels of experience = beta1+beta4*exper
display (_b[educ]+_b[educXexper]*10)
display (_b[educ]+_b[educXexper]*17)
display (_b[educ]+_b[educXexper]*30)

* Regression with another interaction term
reg wage educ exper tenure experXtenure
predict wagehat7, xb
graph twoway (scatter wage exper) (scatter wagehat7 exper)

**********************************************
***** Regression with rescaled variables *****
**********************************************
 
*CEO salary example
use "$datadir/CEOSAL2.dta", clear

keep salary sales profits lsalary lsales
describe 
summarize 

* Rescale salary from thousands of dollars into dollars
gen salary_d = salary*1000 

* Rescale sales from millions of dollars to thousands of dollars
gen sales_k = sales*1000

* Descriptive statistics
summarize salary salary_d sales sales_k profits

* Regressions with original and rescaled variables
reg salary sales profits
reg salary_d sales profits
reg salary sales_k profits
reg salary_d sales_k profits
* When variables are rescaled, the coefficients are rescaled.

*****************************************************
***** Regression with logged rescaled variables *****
*****************************************************

* Regressions with log transformation

*Level-level regression
reg salary sales profits
*Log-level regression
reg lsalary sales profits
*Level-log regression
reg salary lsales profits
*Log-log regression
reg lsalary lsales profits

* Rescale salary from thousands of dollars into dollars
gen lsalary_d = log(salary_d)
* Rescale sales from millions of dollars to thousands of dollars
gen lsales_k = log(sales_k)

* Descriptive statistics
summarize lsalary lsalary_d lsales lsales_k profits

* Regressions with original logged variables and rescaled logged variables
reg lsalary lsales profits
reg lsalary_d lsales profits
reg lsalary lsales_k profits
reg lsalary_d lsales_k profits
* When logged variables are rescaled, the coefficients do not change.
