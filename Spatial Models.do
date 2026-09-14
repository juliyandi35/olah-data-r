sysuse data3

label variable fips "District ID"
label variable district "District name"
label variable pov " Poverty Rate"
label variable gap " Poverty Gap Index"
label variable sev " Poverty Severity Index"
label variable agr " Total GRDP of Agriculture sector at district-i"
label variable ind "Total GRDP of Industry sector at district-i"
label variable gpov "Growth of Poverty Rate"
label variable gsev "Growth of Poverty Severity Index"
label variable ggap "Growth of Poverty Gap Index"
label variable mys "Mean Year School"
label variable shr_agr "Share of Agricultural sector to total GRDP"
label variable unemp "Unemployment Rate"
label variable gdpgr "Economic growth"
label variable shr_ind "Share of industry sector to total GRDP"
label variable subs_rice "Percentage of poor purchase subsidized rice"
label variable inv_shr "Share of Public investment to GDP"
label variable gdi "Gender Development Index"
describe
summarize

sysuse data3
save, replace

* 3 Explore my Map
spshape2dta INDO_KAB_2016, replace

* NOTE:  Two stata files will be created
* INDO_KAB_2016_shp.dta
* INDO_KAB_2016.dta

*Explore my spatial data: myMAP
use INDO_KAB_2016

*Describe and summarize myMAP.dta
describe
summarize

*Generate new spatial-unit id: fips
destring IDKAB, generate(fips)

save, replace

*Change the spatial-unit id from _ID to fips
spset fips, modify replace

*Modify the coordinate system from planar to latlong
spset, modify coordsys(latlong, miles)

*Check spatial ID and coordinate system
spset

* 3.1 Merge with myPANEL data : data3.dta
sysuse data3
xtset fips year 
spbalance 
merge m:1 fips using INDO_KAB_2016
keep if _merge==3 
drop _merge
tset

**Save the merge of my map and panel data
save mymap_and_panel,replace 

* 4 Describe the new dataset
sysuse mymap_and_panel
describe

* 5 Create our spatial weights matrix
sysuse datacross.dta
spmat idistance datacross coord_x coord_y, id(fips) normalize (row)
spmat export datacross using Wa

* 6 OLS: Non spatial model
**OLS Fixed Effect
sysuse mymap_and_panel

*Poverty rate
quietly xtreg gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, fe
gen speed1 = - (log(1+_b[ln_pov])/8)
gen halfLife1 = log(2)/speed1
quietly estat ic
eststo model1

*The same for poverty gap
quietly xtreg ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, fe 
gen speed2 = - (log(1+_b[ln_gap])/8)
gen halfLife2  = log(2)/speed2
quietly estat ic
eststo model2


*The same for poverty severity
quietly xtreg gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, fe
gen speed3 = - (log(1+_b[ln_sev])/8)
gen halfLife3 = log(2)/speed3
quietly estat ic
eststo model3
esttab, r2 aic bic

estimates store ols_fe

* 7 The spatial model: SLM
**SAR Fixed Effect Model 
sysuse mymap_and_panel

spmat import Wi using Wa

**Poverty rate
quietly xsmle gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sar) fe type (ind) effects
gen speed4 = - (log(1+_b[ln_pov])/8)
gen halfLife4 = log(2)/speed4
quietly estat ic
eststo model4

** The same for poverty gap
quietly xsmle ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sar) fe type (ind) effects
gen speed5 = - (log(1+_b[ln_gap])/8)
gen halfLife5 = log(2)/speed5
quietly estat ic
eststo model5

** The same for poverty severity
quietly xsmle gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, wmat (Wi) model (sar) fe type (ind) effects
gen speed6 = - (log(1+_b[ln_sev])/8)
gen halfLife6 = log(2)/speed6
quietly estat ic
eststo model6
esttab, r2 aic bic

estimates store sar_fe


** SAR Random Effect


*Poverty rate
quietly xsmle gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, wmat (Wi) model (sar) re 
gen speed7 = - (log(1+_b[ln_pov])/8)
gen halfLife7 = log(2)/speed7
quietly estat ic
eststo model7

*The same for poverty gap
quietly xsmle ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, wmat (Wi) model (sar) re  
gen speed8 = - (log(1+_b[ln_gap])/8)
gen halfLife8  = log(2)/speed8
quietly estat ic
eststo model8


*The same for poverty severity
quietly  xsmle gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr  shr_agr shr_ind, wmat (Wi) model (sar) re 
gen speed9 = - (log(1+_b[ln_sev])/8)
gen halfLife9 = log(2)/speed9
quietly estat ic
eststo model9
esttab, r2 aic bic

estimates store sar_re

** Conducting Hausman Test

hausman sar_fe sar_re

* 8 The spatial model: SEM
*SEM Fixed Effect Model 
sysuse mymap_and_panel

spmat import Wi using Wa

**Poverty rate
quietly xsmle gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, emat (Wi) model (sem) fe type (ind)
gen speed10 = - (log(1+_b[ln_pov])/8)
gen halfLife10 = log(2)/speed10
quietly estat ic
eststo model10


**The same for poverty gap
quietly xsmle ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, emat (Wi) model (sem) fe type (ind) effects
gen speed11 = - (log(1+_b[ln_gap])/8)
gen halfLife11 = log(2)/speed11
quietly estat ic
eststo model11

**The same for poverty severity
quietly xsmle gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, emat (Wi) model (sem) fe type (ind) effects
gen speed12 = - (log(1+_b[ln_sev])/8)
gen halfLife12 = log(2)/speed12
quietly estat ic
eststo model12
esttab, r2 aic bic

estimates store sem_fe

* 9 The spatial model: SAC
*SAC Fixed Effect Model 
sysuse mymap_and_panel

spmat import Wi using Wa

**Poverty rate
quietly xsmle gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) emat (Wi) model (sac) fe type (ind) effects
gen speed13 = - (log(1+_b[ln_pov])/8)
gen halfLife13 = log(2)/speed13
quietly estat ic
eststo model13


**The same for poverty gap
quietly xsmle ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) emat (Wi) model (sac) fe type (ind) effects
gen speed14 = - (log(1+_b[ln_gap])/8)
gen halfLife14 = log(2)/speed14
quietly estat ic
eststo model14

**The same for poverty severity
quietly xsmle gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) emat (Wi) model (sac) fe type (ind) effects
gen speed15 = - (log(1+_b[ln_sev])/8)
gen halfLife15 = log(2)/speed15
quietly estat ic
eststo model15
esttab, r2 aic bic

estimates store sac_fe

* 10 The spatial model: SDM
*SDM Fixed Effect Model 
sysuse mymap_and_panel

spmat import Wi using Wa

**Poverty rate
quietly xsmle gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sdm) fe type (ind) effects
gen speed16 = - (log(1+_b[ln_pov])/8)
gen halfLife16 = log(2)/speed16
quietly estat ic
eststo model16


**The same for poverty gap
quietly xsmle ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sdm) fe type (ind) effects
gen speed17 = - (log(1+_b[ln_gap])/8)
gen halfLife17 = log(2)/speed17
quietly estat ic
eststo model17

**The same for poverty severity
quietly xsmle gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sdm) fe type (ind) effects
gen speed18 = - (log(1+_b[ln_sev])/8)
gen halfLife18 = log(2)/speed18
quietly estat ic
eststo model18
esttab, r2 aic bic

estimates store sdm_fe


*SDM Random Effect Model 

**Poverty rate
quietly xsmle gpov ln_pov mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sdm) re 
gen speed19 = - (log(1+_b[ln_pov])/8)
gen halfLife19 = log(2)/speed19
quietly estat ic
eststo model19


**The same for poverty gap
quietly xsmle ggap ln_gap mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sdm) re
gen speed20 = - (log(1+_b[ln_gap])/8)
gen halfLife20 = log(2)/speed20
quietly estat ic
eststo model20

**The same for poverty severity
quietly xsmle gsev ln_sev mys gdpgr unemp subs_rice gdi inv_shr shr_agr shr_ind, wmat (Wi) model (sdm) re
gen speed21 = - (log(1+_b[ln_sev])/8)
gen halfLife21 = log(2)/speed21
quietly estat ic
eststo model21
esttab, r2 aic bic

estimates store sdm_re

**Conducting Hausman Test

hausman sdm_fe sdm_re

