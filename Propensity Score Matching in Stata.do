* Propensity Score Matching in Stata


clear all
set more off

* Download and install Stata ado files for pscore 
* net install st0026_2.pkg

use C:\Econometrics\Data\matching_earnings

* Define treatment, outcome, and independent variables
global treatment TREAT
global ylist RE78
global xlist AGE EDUC MARR 
global breps 5

* For difference-in-differences, outcome is the differences in outcomes after and before REDIFF=RE78-RE75
* global ylist REDIFF 

describe $treatment $ylist $xlist
summarize $treatment $ylist $xlist

bysort $treatment: summarize $ylist $xlist

* Regression with a dummy variable for treatment (t-test)
reg $ylist $treatment 

* Regression with a dummy variable for treatment controlling for x
reg $ylist $treatment $xlist

* Propensity score matching with common support
pscore $treatment $xlist, pscore(myscore) blockid(myblock) comsup

* Matching methods 

* Nearest neighbor matching 
attnd $ylist $treatment $xlist, pscore(myscore) comsup boot reps($breps) dots 

* Radius matching 
attr $ylist $treatment $xlist, pscore(myscore) comsup boot reps($breps) dots radius(0.1)

* Kernel Matching
attk $ylist $treatment $xlist, pscore(myscore) comsup boot reps($breps) dots

* Stratification Matching
atts $ylist $treatment $xlist, pscore(myscore) blockid(myblock) comsup boot reps($breps) dots


* Propensity score matching using psmatch2 package

* Install psmatch2 package
ssc install psmatch2

* Propensity score matching
psmatch2 $treatment $xlist, outcome($ylist) ate 

* Propensity score matching with logit instead of probit model
psmatch2 $treatment $xlist, outcome($ylist) logit

* Propensity score matching with common support
psmatch2 $treatment $xlist, outcome($ylist) common

* Nearest neighbor matching - neighbor(number of neighbors)
psmatch2 $treatment $xlist, outcome($ylist) common neighbor(1)

* Radius matching - caliper(distance)
psmatch2 $treatment $xlist, outcome($ylist) common radius caliper(0.1)

* Kernel matching
psmatch2 $treatment $xlist, outcome($ylist) common kernel

* Bootstrapping 
set seed 0
bootstrap r(att): psmatch2 $treatment $xlist, outcome($ylist)

* Balancing - comparisons of treated and controls after matching
pstest 

