clear all
set more off

* Memuat Data
use "Country Data 2013.dta", clear

* Membuat Matriks Bobot Spasial (Menggunakan koordinat)
spatwmat, name(W) xcoord(_CX) ycoord(_CY) band(0 93)

* Menghitung Moran's I untuk Variabel 'CrimeIndex'
spatgsa CrimeIndex, weights(W) moran

* Membuat Matriks Bobot Spasial (Menggunakan matriks Biner)
spatwmat, name(W1) xcoord(_CX) ycoord(_CY) band(0 93) bin
spatgsa CrimeIndex, weights(W1) moran

