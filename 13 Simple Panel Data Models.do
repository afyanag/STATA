/**************************************************************
   
	************************
	Simple Panel Data Models
	************************

Outline:
	Difference-in-differences model
	Panel data model with first differences
	
Data Files: 
	KIELMC.dta
	wagepan.dta
	
***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data/" 

*******************************************
***** Difference-in-differences model *****
*******************************************

* House prices example
* DID effect of building an incinerator on house prices
use "$datadir/KIELMC.dta", clear

describe rprice nearinc y81 y81nrinc
summarize rprice nearinc y81 y81nrinc

* Summarize house prices near and far from incinerator, and before and after
tabulate nearinc y81, summarize(rprice) means 

* Regression in after period (after building the incinerator)
reg rprice nearinc if year==1981
scalar b1=_b[nearinc]
display b1

* Regression in before period (before building the incinerator)
reg rprice nearinc if year==1978
scalar b2=_b[nearinc]
display b2
    
* Difference-in-differences effect
display b1-b2

* Regression for treated units (near the incinerator)
reg rprice y81 if nearinc==1
scalar b3=_b[y81]
display b3

* Regression for control units (far from the incinerator)
reg rprice y81 if nearinc==0
scalar b4=_b[y81]
display b4
   
* Difference-in-differences effect 
display b3-b4
   
* Difference-in-differences regresssion 
* includes after, treated, and after*treated 
reg rprice nearinc y81 y81nrinc
display _b[y81nrinc]
* DID effect is the coefficient on after*treated
* DID effect is same as the difference-in-differences calculated above


***************************************************
***** Panel data model with first differences *****
***************************************************

* Panel data for wage example
use "$datadir/wagepan.dta", clear

* Keep only two years of data
keep if year==1980 | year==1981

* Generate dummy for year and interaction term
gen d1981=0
replace d1981=1 if year==1981
gen d1981hours=d1981*hours

* Get wage from log(wage)
gen wage=10^lwage

* Set the data as panel data
* nr is the cross sectional dimension, year is the time dimension
xtset nr year

* List, describe, and summarize data
list nr year wage hours educ exper in 1/10
describe nr year wage hours educ exper
summarize nr year wage hours educ exper

* Describe and summarize as panel data
xtdescribe 
xtsum nr year wage hours educ exper

* Regression model with both years (ignoring that it is panel data set)
reg wage hours educ exper
reg wage hours
reg wage d1981 hours

* Regression models for each year
reg wage hours if year==1980
reg wage hours if year==1981

* Regression model with different intercept and slope for both years
reg wage d1981 hours d1981hours

* Generate first differences
gen dwage=d.wage
gen deduc=d.educ
gen dhours=d.hours
gen dexper=d.exper
list nr year wage hours educ exper dwage dhours deduc dexper in 1/10

* Panel data model with first differences
* Cannot be estimated due to perfect collinearity of deduc and dexper
reg dwage deduc dexper dhours

* Panel data model with first differences
reg dwage dhours
