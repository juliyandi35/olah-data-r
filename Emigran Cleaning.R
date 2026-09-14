library(readxl)
library(tidyverse)
library(zoo)
library(tidyr)
library(dplyr)

# Emigran
emigran <- read.csv("total-number-of-emigrants.csv")
head(emigran)
emigran <- subset(emigran,Year>=2010)

# Buat sequence tahun lengkap
full_years <- tibble(Year = seq(2010, 2024))

# Gabungkan untuk dapat semua tahun per entity
data_complete <- emigran %>%
  complete(Entity, Year = full_years$Year) %>%
  arrange(Entity, Year)

# Lakukan interpolasi linier
data_interpolated <- data_complete %>%
  group_by(Entity) %>%
  mutate(
    Total.number.of.emigrants = na.approx(Total.number.of.emigrants, x = Year, na.rm = FALSE)
  ) %>%
  ungroup()

# Hasil
print(data_interpolated)

emigran <- subset(data.frame(data_interpolated),Year>=2013 & Year<=2023)

# Ubah format long menjadi wide
emigran_wide <- emigran %>%
  pivot_wider(names_from = Year, values_from = Total.number.of.emigrants, names_prefix = "Tahun.")

# Menampilkan hasil
print(emigran_wide)

crime <- data.frame(read_excel("Variables Dataset.xlsx",sheet="Crime Index"))
length(crime$Country4)

crime_panel <- crime %>%
  pivot_longer(cols = starts_with("Tahun"),
               names_to = "Tahun",
               names_prefix = "Tahun.",
               values_to = "Crime")
crime_panel <- data.frame(crime_panel)

# Ubah kolom Tahun menjadi tipe numerik
crime_panel <- crime_panel %>% mutate(Tahun = as.integer(Tahun))
colnames(crime_panel) <- c("Entity","Code","Tahun","Crime")

# Cari yang hanya ada di salah satu
only_in_emigran <- setdiff(emigran$Entity, unique(crime_panel$Entity))
only_in_crime <- setdiff(unique(crime_panel$Entity), emigran$Entity)
only_in_crime

emigran$Entity[emigran$Entity == "Czechia"] <- "Czech Republic"
emigran$Entity[emigran$Entity == "Bosnia and Herzegovina"] <- "Bosnia And Herzegovina"
emigran$Entity[emigran$Entity == "Cote d'Ivoire"] <- "Ivory Coast"
emigran$Entity[emigran$Entity == "Trinidad and Tobago"] <- "Trinidad And Tobago"
emigran$Entity[emigran$Entity == "United States Virgin Islands"] <- "Us Virgin Islands"
emigran$Entity[emigran$Entity == "Isle of Man"] <- "Isle Of Man"

colnames(crime_panel) <- c("Entity","Code","Year","Crime")

emigran_crime <- merge(emigran,crime_panel,by=c("Entity","Year"))
emigran_data <- emigran_crime[,c(1,4,2,3)]

emigran_wide <- emigran_data %>%
  pivot_wider(names_from = Year, values_from = Total.number.of.emigrants, names_prefix = "Tahun.")

writexl::write_xlsx(emigran_wide,"Emigran.xlsx")

unique(emigran_data$Entity)
