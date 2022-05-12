* Spatial Econometrics in Stata
* Copyright 2013 by Ani Katchova

clear all
set more off

* Download Stata ado files: spatreg

use C:\Econometrics\Data\spatial_columbus

global ylist crime
global xlist inc hoval
global xcoord x
global ycoord y
global band 10

describe $ylist $xlist 
summarize $ylist $xlist

* Spatial weight matrix
spatwmat, name(W) xcoord($xcoord) ycoord($ycoord) band(0 $band) standardize eigenval(E)
*matrix list W

* Regression
reg $ylist $xlist

* Spatial diagnostics
spatdiag, weights(W)

* Spatial error model
spatreg $ylist $xlist, weights(W) eigenval(E) model(error)

* Spatial lag model
spatreg $ylist $xlist, weights(W) eigenval(E) model(lag)

