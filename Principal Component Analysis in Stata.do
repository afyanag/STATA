* Principal Component Analysis and Factor Analysis in Stata


clear all
set more off

use C:\Econometrics\Data\pca_gsp

global xlist Ag Mining Constr Manuf Manuf_nd Transp Comm Energy TradeW TradeR RE Services Govt
global id State
global ncomp 3

describe $xlist
summarize $xlist
corr $xlist

* Principal component analysis (PCA)
pca $xlist

* Scree plot of the eigenvalues
screeplot
screeplot, yline(1)

* Principal component analysis
pca $xlist, mineigen(1)
pca $xlist, comp($ncomp) 
pca $xlist, comp($ncomp) blanks(.3)

* Component rotations
rotate, varimax
rotate, varimax blanks(.3)
rotate, clear

rotate, promax
rotate, promax blanks(.3)
rotate, clear

* Scatter plots of the loadings and score variables
loadingplot
scoreplot
scoreplot, mlabel($id)

* Loadings/scores of the components
estat loadings
predict pc1 pc2 pc3, score

* KMO measure of sampling adequacy
estat kmo


* Factor analysis
factor $xlist

* Scree plot of the eigenvalues
screeplot
screeplot, yline(1)

* Factor analysis (pf principal factors, pcf principal component factors)
factor $xlist, mineigen(1)
factor $xlist, factor($ncomp) 
factor $xlist, factor($ncomp) blanks(0.3)
factor $xlist, factor($ncomp) pcf

* Factor rotations
rotate, varimax 
rotate, varimax blanks(.3)
rotate, clear

rotate, promax
rotate, promax blanks(.3)
rotate, clear

estat common

* Scatter plots of the loadings and score variables
loadingplot
scoreplot

* Scores of the components
predict f1 f2 f3

* KMO measure of sampling adequacy
estat kmo

* Average interitem covariance
alpha $xlist

* Barlett's test for sphericity 
ssc install factortest
factortest $xlist
