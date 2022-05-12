/************************************************************************
   
	************************
	Econometrics and Economic Data
	************************

Outline:
1. Cross-sectional data
2. Time Series data
3. Pooled Cross Sections
4. Panel/longitudinal data
   
Files:
	wage1.dta
	prminwge.dta
	hprice3.dta
	wagepan.dta
	
************************************************************************/

* setup
clear all
set more off 
global datadir "C:\Econometrics\Data" 

************************************************************************
****************** 1. Cross-sectional data  ****************************
************************************************************************

* Cross-sectional data set on wages and other characteristics
* Observations are individuals

* Load the Dataset
use "$datadir/wage1.dta",clear

* Describe and summarize data
describe
summarize

* show summary statistics for selected variables
summarize wage lwage educ exper expersq tenure married female

/*
How to view data
* open built-in data editor
* stata command "browse"
* stata command "list"
*/

* Browse like a spreadsheet
browse

* Show all data, all variables and observations 
* list 

* Show selected variables, all observations
* list wage educ

* Show all variables, the first 10 observations
* list in 1/10

* show the first ten observations for selected variables
list wage lwage in 1/10

* keep only selected variables in the dataset
keep wage lwage educ exper expersq tenure married female 

* Summarize data
describe
summarize
list in 1/10

* display additional summary statistics
summarize wage, detail

* provide frequency tables
tabulate female

************************************************************************
****************** 2. Time Series data  ********************************
************************************************************************

* Time series data on minimum wages and related variables

* Load the Dataset
use "$datadir/prminwge.dta",clear

keep year avgmin avgcov prunemp prgnp

* Describe and summarize data
describe
summarize
list in 1/10

* provide frequency tables
* One observation per year for time series data
tabulate year

* browse

************************************************************************
****************** 3. Pooled Cross Sections  ***************************
************************************************************************

* Pooled cross sections on housing prices
* House prices for two years, 1978 and 1981 
* Houses are different in each year. 
* We do not have the price of the same house in both years. 

use "$datadir/hprice3.dta",clear

* Keep selected variables 
keep year y81 price lprice rooms baths

describe
summarize
list in 1/10

* Let's see how many observations per year
tabulate year

* Summary statistics for price and year
summarize price year

* Summary statistics for selected sample
* Before is year 1978, see average price before
summarize price if year == 1978

* After is year 1981, see average price after
summarize price if year == 1981


************************************************************************
****************** 4. Panel/longitudinal data  *************************
************************************************************************

* Panel data for wages of individuals across years 
* 8-year panel data on wages of individuals and other variables
* there are observations for the same individual for multiple years
* person identifier is nr
* time identifier is year

use "$datadir/wagepan.dta",clear

keep nr year lwage exper educ hours

describe
summarize
list in 1/10

tabulate year

