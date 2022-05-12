/**************************************************************
    
	**********************
	Simultaneous Equations
	**********************

Outline:
	Simultaneous equations
	Testing for rank condition

Data files: 
	MROZ.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/" 

**********************************
***** Simultaneous equations *****
**********************************

* Labor supply and demand data for working women
use "$datadir/MROZ.dta", clear
* keep only working women
keep if inlf==1

describe hours lwage educ exper expersq age kidslt6 nwifeinc
summarize hours lwage educ exper expersq age kidslt6 nwifeinc
list hours lwage educ exper expersq age kidslt6 nwifeinc in 1/10

* Regression for hours using OLS estimation
reg hours lwage educ age kidslt6 nwifeinc

* Regression for hours using 2SLS estimation
* lwage is instrumented by variables from the other equation
ivreg hours (lwage = exper expersq) educ age kidslt6 nwifeinc, first

* Regression for lwage using OLS estimation
reg lwage hours educ exper expersq

* Regression for lwage using 2SLS estimation
* hours is instrumented by variables from the other equation 
ivreg lwage (hours = age kidslt6 nwifeinc) educ exper expersq, first

**************************************
***** Testing for rank condition *****
**************************************

* Testing for rank condition involves estimating the reduced form equation 
* and testing for significance of the instrument variables.

* Reduced form equation for lwage, indentifying equation for hours
reg lwage educ age kidslt6 nwifeinc exper expersq
test exper expersq

* Reduced form equation for hours, indentifying equation for lwage
reg hours educ age kidslt6 nwifeinc exper expersq
test age kidslt6 nwifeinc
