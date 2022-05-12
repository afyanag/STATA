/**************************************************************
   
	***********************************************************
	Regression with Indicator Variables
	***********************************************************
   
Outline:
	Single indicator variable
	Interaction terms with another indicator variable
	Several related indicator variables
	Interaction terms with a non-indicator variable
	F-test for differences across groups
	Chow test for differences across groups

Data files:
	wage1.dta

***************************************************************/

clear all
set more off 
global datadir "C:/Econometrics/Data" 

**************************************
****** Single indicator variable *****
**************************************

* Wage example
use "$datadir/wage1.dta", clear

* Average wage
reg wage
summarize wage

* Regression of wage on female
reg wage female

* Graph of wage on female
graph twoway (scatter wage female) (lfit wage female)

* Summary statistics for groups of females and males
bysort female: summarize wage

* T-test for average wage for females and males
ttest wage, by(female)
* The mean, t-statitic, and p-value are the same for the coefficient on female 
* in the regression and the t-test comparing wages for females and males.

* Generate indicator variable for male
gen male=1-female

* Regression of wage on female and regression of wage on male
reg wage female
reg wage male
* The coefficient on male has the same magnitude and significance 
* but opposite sign from the coefficient on female.

* Regression with female and male cannot be estimated because of perfect collinearity
reg wage female male

* Regression with female and male can be estimated with no constant
reg wage female male, nocons


*************************************************************
***** Interaction terms with another indicator variable *****
*************************************************************

* Generate indicator variables
gen single = 1-married 

* Categories: female*single, male*single, female*married, male*married
gen female_single=female*single
gen male_single=male*single
gen female_married=female*married
gen male_married=male*married

* List indicator variables and interaction terms for indicator variables
list female male single married female_single male_single female_married male_married in 1/10

* Regression with all four categories, Stata will drop one
reg wage female_single male_single female_married male_married

* Regression with male_single as reference category
reg wage female_single female_married male_married

* Marginal effect for female and single on wage
display _b[female_single] 

* Marginal effect for female and married on wage
display _b[female_married] 

* Alternative categories: female, married, and femaleXmarried

* Generate interaction variable 
gen femaleXmarried=female*married

* Regression with interaction term
reg wage female married femaleXmarried

* Marginal effect for female and single on wage
display _b[female]

* Marginal effect for female and married on wage
display _b[female] + _b[married] + _b[femaleXmarried]


************************************************
****** Several related indicator variables *****
************************************************

* Regression with several related indicator variables needs to drop one as the reference category.

* Indicator variables for region (northcentral, south, and west)
gen east = 1 - northcen - south - west
summarize northcen south west east

* Average wage by region
summarize wage if northcen==1
summarize wage if south==1
summarize wage if west==1
summarize wage if east==1

* Regression with east as the reference category
reg wage northcen south west

* Regression with west as the reference category
reg wage northcen south east

* Regression with east as the reference category
reg wage educ northcen south west

* Regression with west as the reference category
reg wage educ northcen south east


************************************************************
****** Interaction terms with a non-indicator variable *****
************************************************************

* Regression of wage on educ 
* Model with same intercept and slope for females and males
reg wage educ
graph twoway (scatter wage educ) (lfit wage educ) 

* Regression of wage on educ and female
* Model with same slope but different intercepts for females and males
reg wage educ female
predict wagehat, xb

* Graph of wage on education, same slope and different intercepts for females and males
graph twoway (scatter wage educ) (lfit wagehat educ if female==1) (lfit wagehat educ if female==0)

* Regression of wage on education and male
reg wage educ male 
* The coefficient on male has the same magnitude and significance 
* but opposite sign than coefficient on female.

* Regression of wage on educ for females
reg wage educ if female==1

* Regression of wage on education for males
reg wage educ if female==0

* Graph of wage on education, different slopes and intercepts for females and males
graph twoway (scatter wage educ) (lfit wage educ if female==1) (lfit wage educ if female==0)

* Generate an interaction term between female and education
gen femaleXeduc = female*educ

* Regression of wage on educ, female, and female*educ
* Model with different intercepts and slopes for females and males
reg wage educ female femaleXeduc

* Intercepts and slopes for males and females
display "intercept for males is " _b[_cons]
display "intercept for females is " _b[_cons] + _b[female]
display "marginal effect of education on wage for males is " _b[educ] 
display "marginal effect of education on wage for females is " _b[educ] + _b[femaleXeduc]
* Same coefficients as running two separate regressions for female and male.


************************************************
***** F-test for differences across groups *****
************************************************

* F-test for joint coefficient significance is used to test for several coefficients to be jointly signficantly different from zero.

use "$datadir/wage1.dta",clear

* Generate interaction terms
gen femaleXeduc=female*educ
gen femaleXexper=female*exper
gen femaleXtenure=female*tenure

* H0: delta0=0 and delta1=0 and delta2=0 and delta3=0

* Restricted model: wage = alpha0 + alpha1*educ + alpha2*exper + alpha3*tenure + e
reg wage educ exper tenure 
gen ssr_r=e(rss)

* Unrestricted model: wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + delta0*female + delta1*female*educ + delta2*female*exper + delta3*female*tenure + u
reg wage educ exper tenure female femaleXeduc femaleXexper femaleXtenure
gen ssr_ur=e(rss)
gen q=4

* Calculate F_stat 
gen F_stat=((ssr_r-ssr_ur)/q) / (ssr_ur/e(df_r))
display F_stat

* F-critical value
display invFtail(q,e(df_r),0.05)
* If F-stat > F-critical value then reject null, coefficients are jointly significant

* p-value for F-test
gen F_pvalue= Ftail(q,e(df_r),F_stat)
display F_pvalue
* If F p-value<0.05 then reject null, coefficients are jointly significant

*** F-test using Stata commands
reg wage educ exper tenure female femaleXeduc femaleXexper femaleXtenure
test (female=0) (femaleXeduc=0) (femaleXexper=0) (femaleXtenure=0)

***************************************************
***** Chow test for differences across groups *****
***************************************************

* Chow test is an F-test for signficantly different coefficients between two groups. Instead of one unrestricted model, two separate models are estimated for each group.  

* Wage example
use "$datadir/wage1.dta",clear

* H0: beta0=alpha0 and beta1=apha1 and beta2=alpha2 and beta3=alpha3

* Restricted model: wage = gamma0 + gamma1*educ + gamma2*exper + gamma3*tenure + v
reg wage educ exper tenure 
gen k=3
gen n=e(N)
gen ssr_r=e(rss)

* Unrestricted model for females: 
* wage = beta0 + beta1*educ + beta2*exper + beta3*tenure + u
reg wage educ exper tenure if female==1
gen ssr1=e(rss)

* Unrestricted model for males: 
* wage = aplha0 + alpha1*educ + alpha2*exper + alpha3*tenure + e
reg wage educ exper tenure if female==0
gen ssr2=e(rss)

* Calculate Chow F-statistic
gen F_stat=((ssr_r-(ssr1+ssr2))/(k+1)) / ((ssr1+ssr2)/(n-2*(k+1)))
display F_stat

* F-critical value
display invFtail((k+1),(n-2*(k+1)),0.05)
* If F-stat > F-critical value then reject null, coefficients are jointly significant

* p-value for F-test
gen F_pvalue= Ftail((k+1),(n-2*(k+1)),F_stat)
display F_pvalue
* If F p-value<0.05 then reject null, coefficients are jointly significant
