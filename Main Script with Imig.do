cd "D:\Kerjaan\Research Consultant\Project Olah Data, Bab 4, dan Bab 5 kak Fajar"

clear all
set more off

use "Panel Data Country Merged.dta",replace
describe

xtset _ID Tahun
spbalance 

tset

duplicates drop _ID, force
save "Country Data 2013.dta",replace

* Create our spatial weights matrix
use "Country Data 2013.dta",clear

* Membuat Matriks Bobot Spasial (Menggunakan koordinat)
spatwmat, name(W) xcoord(_CX) ycoord(_CY) band(0 50)
spatgsa crime, weights(W) moran

* Membuat Matriks Bobot Spasial (Menggunakan matriks Biner)
spatwmat, name(W1) xcoord(_CX) ycoord(_CY) band(0 50) bin standardize
spatgsa crime, weights(W1) moran

* OLS: Non spatial model
**OLS Fixed Effect
use "Panel Data Country Merged.dta",clear
misstable summarize

* Estimasi dengan fixed effects model (panel data)
xtreg crime wage gdp pop edu unmply gini pov imig, fe

estat ic
eststo model1
esttab, r2 aic 
estimates store ols_fe

* The spatial model: SLM
**SAR Fixed Effect Model 
xsmle crime wage gdp pop edu unmply gini pov imig, wmat (W1) model (sar) fe type (ind) effects
estat ic
eststo model2
esttab, r2 aic 
estimates store sar_fe

* SAR Random Effect
xsmle crime wage gdp pop edu unmply gini pov imig, wmat (W1) model (sar) re 
estat ic
eststo model3
esttab, r2 aic 
estimates store sar_re

* The spatial model: SEM
* SEM Fixed Effect Model 
xsmle crime wage gdp pop edu unmply gini pov imig, emat (W1) model (sem) fe type (ind) effects
estat ic
eststo model4
esttab, r2 aic 
estimates store sem_fe

* The spatial model: SAC
* SEM Random Effect Model 
xsmle crime wage gdp pop edu unmply gini pov imig, emat (W1) model (sem) re
estat ic
eststo model5
esttab, r2 aic 
estimates store sem_re

* The spatial model: SDM
* SDM Fixed Effect Model 
xsmle crime wage gdp pop edu unmply gini pov imig, wmat (W1) model (sdm) fe type (ind) effects
estat ic
eststo model6
esttab, r2 aic 
estimates store sdm_fe

* SDM Random Effect Model 
xsmle crime wage gdp pop edu unmply gini pov imig, wmat (W1) model (sdm) re
estat ic
eststo model7
esttab, r2 aic 
estimates store sdm_re

save "Panel Data Country Merged Final.dta",replace