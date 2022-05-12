/**************************************************************
   
	****************************
	Simple Regression Model
	****************************

Outline:
1. Simple regression
2. Prediction after regression
3. Goodness-of-fit measure (R-squared)
4. Log forms: log-log and log-linear forms

   
Files:
	CEOSAL1.dta
	wage1.dta
	
***************************************************************/

* setup
clear all
set more off 
global datadir "C:\Econometrics\Data" 

************************************************************************
****************** 1. Simple regression  *******************************
************************************************************************
	
	
	*** CEO Example ***
	*******************
			
* Load the Dataset
use "$datadir/CEOSAL1.dta",clear

keep salary roe
describe 
summarize
list in 1/10

* Exploring data
corr salary roe
egen avg_salary=mean(salary)
label variable avg_salary "average salary"

* Simple Regression: salary=f(roe)
regress salary roe

* Plot the observations with a fitted line
graph twoway (scatter salary roe) (lfit salary roe)

	*** Wage Example ***
	********************

use "$datadir/wage1.dta", clear
keep wage educ
describe
summarize
list in 1/10
reg wage educ


************************************************************************
****************** 2. Prediction after regression **********************
************************************************************************
		 
	*** CEO Example ***
	*******************
		 
* type "help predict" at the command window for detailed options
* Obtain predictions, residuals, etc., after estimation
* help predict

* (1) Load Dataset
use "$datadir/CEOSAL1.dta",clear

* (2) Run regression 
reg salary roe 

* (3) Predicted value for the dependent variable (salaryhat)
predict salaryhat, xb
summarize salary salaryhat
graph twoway (scatter salary roe) (scatter salaryhat roe)

* (4) Residuals 
predict uhat, residuals
summarize salary uhat
graph twoway (scatter salary roe) (scatter uhat roe)
	 
list roe salary salaryhat uhat in 1/10

* (5) Graph Actual and Predicted Values and Residuals
graph twoway (scatter salary roe, msymbol(smcircle) mcolor(black)) ///
			 (scatter salaryhat roe, msymbol(smcircle) mcolor(yellow)) ///
			 (scatter uhat roe, msymbol(smcircle_hollow) mcolor(green)) ///
			 (lfit salary roe), ///
			 legend(order(1 "True value" 2 "Predicted value" 3 "Residual")) 
* help twoway // see options for twoway command


	*** Wage Example ***
	********************

use "$datadir/wage1.dta", clear
reg wage educ
predict wagehat, xb
predict uhat, resid
graph twoway (scatter wage educ) (scatter wagehat educ) (scatter uhat educ) (lfit wage educ)


************************************************************************
************* 3. Goodness-of-fit measure (R-squared) *******************
************************************************************************

	*** CEO Example ***
	*******************

use "$datadir/CEOSAL1.dta",clear
reg salary roe

* Use "ereturn" command to show results that Stata saves automatically
ereturn list
* "display" shows only one of the results that STATA saves automatically
* e(r2) is for R-squared
display e(r2)
* e(N) is for the number of observations
display e(N)
* NOTE: e(.) has to be used right after the regression

	*** Wage Example ***
	********************

use "$datadir/wage1.dta",clear
reg wage educ

ereturn list
display e(r2)
display e(N)
	

************************************************************************
****** 4. Log forms: log-log and log-linear form ******
************************************************************************

	*** CEO Example ***
	*******************

* log-log regression

use "$datadir/CEOSAL1.dta",clear
list salary lsalary sales lsales in 1/10

*Linear form
reg salary sales
graph twoway (scatter salary sales) (lfit salary sales)

* Showing results in table
*install outreg2 package
*outreg2 using results.doc, replace

* You can create the log of a variable using the log function
*gen lsales=log(sales)
*gen lsalary=log(salary)

* Log-log form
reg lsalary lsales
* Graph 
graph twoway (scatter lsalary lsales) (lfit lsalary lsales)
*outreg2 using results.doc, append

* Log-linear form
reg lsalary sales
* Graph 
graph twoway (scatter lsalary sales) (lfit lsalary sales)
*outreg2 using results.doc, append

* Linear-log form
reg salary lsales
* Graph 
graph twoway (scatter salary lsales) (lfit salary lsales)
*outreg2 using results.doc, append

	*** Wage Example ***
	********************

* log-linear regression

use "$datadir/wage1.dta", clear

list wage lwage educ in 1/10

* Linear form
reg wage educ
* Graph
graph twoway (scatter wage educ) (lfit wage educ)
*outreg2 using results.doc, replace

* Log-linear form
reg lwage educ
* Graph 
graph twoway (scatter lwage educ) (lfit lwage educ)
*outreg2 using results.doc, append

