/**************************************************************
   
	***************
	OLS Asymptotics
	***************
   
Outline:
	OLS standard errors
   
Data Files:
	wage1.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data" 

*******************************
***** OLS standard errors *****
*******************************

*Wage example
use "$datadir/wage1.dta",clear

* Regression with full sample
reg wage educ tenure exper
gen se1=_se[exper]
display se1
gen n1=e(N)
display n1

* Regression with half the sample
reg wage educ tenure exper if _n<_N/2
gen se2=_se[exper]
display se2
gen n2=e(N)
display n2

display se1/se2
display sqrt(n2/n1)
* These ratios are almost the same. 
* As the sample size n increases, standard errors change at the rate sqrt(1/n).
* With a larger sample size, standard errors are smaller, leading to more significant coefficients. 
