clear
set seed 12345
set obs 10
gen id = _n  // ID Kabupaten (1 sampai 10)
gen kabupaten = "Kab" + string(id) // Nama Kabupaten
gen income = round(runiform(1000, 5000), 10) // Pendapatan Acak (1000 - 5000)

save atribut_data.dta, replace

clear
set obs 40  // Setiap kabupaten memiliki 4 titik koordinat
gen id = ceil(_n / 4)  // ID Kabupaten (1 sampai 10, masing-masing punya 4 titik)
gen _X = runiform(95, 141)  // Longitude Acak
gen _Y = runiform(-10, 6)   // Latitude Acak

save map_coords.dta, replace

use map_coords.dta, clear
merge m:1 id using atribut_data.dta
drop _merge

spmap income using map_coords.dta, id(id) fcolor(Blues) ocolor(black) title("Peta Distribusi Pendapatan")

