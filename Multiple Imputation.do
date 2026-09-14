clear all
set more off

input id year income education age
1 2000 5000 12 30
1 2001 5200 .  31
1 2002 5400 12 .
1 2003 5500 12 33
2 2000 6000 16 28
2 2001 6200 16 29
2 2002 6400 .  30
2 2003 6600 16 .
end

xtset id year 

mi set flong  
mi register imputed education age 

mi impute chained (regress) education (regress) age = income, add(5)

mi describe 

mi estimate: reg income education age

save my_data.dta, replace
