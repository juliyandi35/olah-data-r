setwd("D:/Kerjaan/Research Consultant/Project Olah Data, Bab 4, dan Bab 5 kak Fajar")
library(readxl)
library(dplyr)
library(tidyr)

# Baca semua sheet dalam file Excel
file_path <- "Variables Dataset.xlsx"
sheets <- excel_sheets(file_path)
sheets
data_list <- lapply(sheets, function(sheet) {
  data <- read_excel(file_path, sheet = sheet)
  print(str(data))
  data %>%
    pivot_longer(cols = starts_with("Tahun"),
                 names_to = "Tahun",
                 names_prefix = "Tahun.",
                 values_to = sheet)
})
# Gabungkan semua data berdasarkan "Nama" dan "Tahun"
panel_data <- Reduce(function(x, y) full_join(x, y, by = c("Code", "Tahun")), data_list)
# Ubah kolom Tahun menjadi tipe numerik
panel_data <- panel_data %>% mutate(Tahun = as.integer(Tahun))

colnames(panel_data)
panel_data <- panel_data[,-c(1,5,7,11,13,15,17,19,21,23,25)]
names(panel_data)
panel_data <- data.frame(panel_data)
panel_data <- panel_data[, c(6,1,2,7,3,4,5,8,9,10,11,12,13,14,15)]
head(panel_data)

# Menghapus baris dengan NA di 'Country' DAN 'Crime.Index'
panel_clean <- panel_data %>% 
  filter(!is.na(Country4) & !is.na(Crime.Index))

head(panel_clean)
names(panel_clean)
colnames(panel_clean) <- c("Country","sov_a3","Tahun","Crime.Index","Minimum.Wage.Average","GDP.Per.Capita",
                           "Population.Density","Years.of.Education","Divorce","Unemployment",
                           "Gini.Index","Poverty","Net.Migration","Emigran","Law")
panel_clean$Imigrants <- panel_clean$Net.Migration+panel_clean$Emigran
# Simpan hasil sebagai Excel
writexl::write_xlsx(panel_clean, "Variables Panel Cleanead Data.xlsx")

# Rentang tahun lengkap
tahun_lengkap <- 2013:2023

# Buat kombinasi lengkap Negara, Kode, dan Tahun
panel_lengkap <- panel_clean %>%
  distinct(Country, sov_a3) %>%
  tidyr::crossing(Tahun = tahun_lengkap)

# Gabungkan dengan data asli
panel_balanced <- panel_lengkap %>%
  left_join(panel_clean, by = c("Country", "sov_a3", "Tahun"))

# Lihat hasilnya
head(panel_balanced)

writexl::write_xlsx(panel_balanced, "Variables Panel Balanced Data.xlsx")
