cd "D:\Kerjaan\Research Consultant\Project Olah Data, Bab 4, dan Bab 5 kak Fajar"

clear all
set more off

import excel "Variables Panel Balanced Data.xlsx", sheet("Sheet1") firstrow
drop Divorce
misstable summarize

egen mean_crime = mean(CrimeIndex), by(Country)
replace CrimeIndex = mean_crime if missing(CrimeIndex)
drop mean_crime

* Set multiple imputation
mi set flong  
mi register imputed MinimumWageAverage GDPPerCapita PopulationDensity YearsofEducation Unemployment GiniIndex Poverty Law Imigrants

* Imputasi missing value dengan chained equations
mi impute chained (regress) MinimumWageAverage GDPPerCapita PopulationDensity YearsofEducation Unemployment GiniIndex Poverty Law Imigrants = CrimeIndex, add(5)
mi describe 

* Ekspor satu hasil imputasi jadi data biasa
mi xeq 1: save imputed_data1.dta, replace
use imputed_data1.dta, clear
misstable summarize
drop NetMigration Emigran

summarize CrimeIndex
gen crime = (CrimeIndex - r(mean)) / r(sd)

summarize MinimumWageAverage
gen wage= (MinimumWageAverage - r(mean)) / r(sd)

summarize GDPPerCapita
gen gdp = (GDPPerCapita - r(mean)) / r(sd)

summarize PopulationDensity
gen pop = (PopulationDensity - r(mean)) / r(sd)

summarize YearsofEducation
gen edu = (YearsofEducation - r(mean)) / r(sd)

summarize Unemployment
gen unmply= (Unemployment - r(mean)) / r(sd)

summarize GiniIndex
gen gini = (GiniIndex - r(mean)) / r(sd)

summarize Poverty
gen pov = (Poverty - r(mean)) / r(sd)

summarize Law
gen law = (Law - r(mean)) / r(sd)

summarize Imigrants
gen imig = (Imigrants - r(mean)) / r(sd)

label variable sov_a3 "Country code"
label variable Country "Country name"
label variable CrimeIndex "Crime Index"
label variable crime "normalized Crime Index"
label variable MinimumWageAverage "Average Minimum Wage"
label variable wage "normalized Average Minimum Wage"
label variable GDPPerCapita "GDP per Capita"
label variable gdp "normalized GDP per Capita"
label variable PopulationDensity "Population Density"
label variable pop "normalized Population Density"
label variable YearsofEducation "Years of Education"
label variable edu "normalized Years of Education"
label variable Unemployment "Unemployment Rate"
label variable unmply "normalized Unemployment Rate"
label variable GiniIndex "Gini Index"
label variable gini "normalized Gini Index"
label variable Poverty "Poverty Rate"
label variable pov "normalized Poverty Rate"
label variable Law "Law Enforcement"
label variable law "normalized Law Enforcement"
label variable Imigrants "Imigrants"
label variable imig "normalized Imigrations"

describe
summarize

save "Panel Data Country.dta", replace

* Explore Map
spshape2dta "World Bound by Code.shp", replace

* NOTE:  Two stata files will be created
* World Bound by Code_shp.dta
* World Bound by Code.dta

* Explore my spatial data
use "World Bound by Code.dta", replace

* Describe and summarize
describe
summarize

save "World Bound by Code.dta", replace

* Merge with myPANEL data : data3.dta
use "Panel Data Country.dta", replace
merge m:m sov_a3 using "World Bound by Code.dta"
keep if _merge==3 
drop _merge

save "Panel Data Country Merged.dta",replace