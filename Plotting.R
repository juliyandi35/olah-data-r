setwd("D:/Kerjaan/Research Consultant/Project Olah Data, Bab 4, dan Bab 5 kak Fajar")
library(haven)
library(dplyr)
library(tidyr)
library(readxl)
# Baca semua sheet dalam file Excel
data <- read_dta("Panel Data Country Merged.dta")
names(data)
crime <- data[,c(1,2,3,4)]
crime_wide <- crime %>%
  pivot_wider(names_from = Tahun, values_from = CrimeIndex, names_prefix = "Tahun.")
crime_2023 <- crime_wide[,c(1,2,13)]

wage <- data[,c(1,2,3,5)]
wage_wide <- wage %>%
  pivot_wider(names_from = Tahun, values_from = MinimumWageAverage, names_prefix = "Tahun.")
wage_2023 <- wage_wide[,c(1,2,13)]

gdp <- data[,c(1,2,3,6)]
gdp_wide <- gdp %>%
  pivot_wider(names_from = Tahun, values_from = GDPPerCapita, names_prefix = "Tahun.")
gdp_2023 <- gdp_wide[,c(1,2,13)]

pop <- data[,c(1,2,3,7)]
pop_wide <- pop %>%
  pivot_wider(names_from = Tahun, values_from = PopulationDensity, names_prefix = "Tahun.")
pop_2023 <- pop_wide[,c(1,2,13)]

edu <- data[,c(1,2,3,8)]
edu_wide <- edu %>%
  pivot_wider(names_from = Tahun, values_from = YearsofEducation, names_prefix = "Tahun.")
edu_2023 <- edu_wide[,c(1,2,13)]

unmply <- data[,c(1,2,3,9)]
unmply_wide <- unmply %>%
  pivot_wider(names_from = Tahun, values_from = Unemployment, names_prefix = "Tahun.")
unmply_2023 <- unmply_wide[,c(1,2,13)]

gini <- data[,c(1,2,3,10)]
gini_wide <- gini %>%
  pivot_wider(names_from = Tahun, values_from = GiniIndex, names_prefix = "Tahun.")
gini_2023 <- gini_wide[,c(1,2,13)]

pov <- data[,c(1,2,3,11)]
pov_wide <- pov %>%
  pivot_wider(names_from = Tahun, values_from = Poverty, names_prefix = "Tahun.")
pov_2023 <- pov_wide[,c(1,2,13)]

law <- data[,c(1,2,3,12)]
law_wide <- law %>%
  pivot_wider(names_from = Tahun, values_from = Law, names_prefix = "Tahun.")
law_2023 <- law_wide[,c(1,2,13)]

imig <- data[,c(1,2,3,13)]
imig_wide <- imig %>%
  pivot_wider(names_from = Tahun, values_from = Imigrants, names_prefix = "Tahun.")
imig_2023 <- imig_wide[,c(1,2,13)]

crime.gini.dataset <- merge(crime_2023,gini_2023,by="sov_a3")
crime.gini.dataset <- crime.gini.dataset[,c(1,2,3,5)]
colnames(crime.gini.dataset) <- c("Code","Country","Crime","Gini") 

library(sf)
world <- read_sf("world_shapefile.shp")
head(world)
names(world)

world_bound <- world[,c(5,169)]
colnames(world_bound) <- c("Code","geometry")
st_write(world_bound,"World Bound by Code.shp",append = FALSE)

sf_data <- merge(crime.gini.dataset,world_bound,by="Code")
head(sf_data)
names(sf_data)

# Plot peta
library(ggplot2)
library(gridExtra)
ggplot(data = st_as_sf(sf_data)) +
  geom_sf(aes(fill = Crime)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data)) +
  geom_sf(aes(fill = Gini)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
sf_data$CrimeandGini <- sf_data$Crime+sf_data$Gini
ggplot(data = st_as_sf(sf_data)) +
  geom_sf(aes(fill = CrimeandGini)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()

sf_data_2023 <- data.frame(Code = crime_2023$sov_a3,
                           crime = crime_2023$Tahun.2023,
                           wage= wage_2023$Tahun.2023,
                           gdp = gdp_2023$Tahun.2023,
                           pop = pop_2023$Tahun.2023,
                           edu = edu_2023$Tahun.2023,
                           unmply = unmply_2023$Tahun.2023,
                           gini = gini_2023$Tahun.2023,
                           pov = pov_2023$Tahun.2023,
                           law = law_2023$Tahun.2023,
                           imig = imig_2023$Tahun.2023)
sf_data_2023 <- merge(sf_data_2023,world_bound,by="Code")

ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = wage)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = gdp)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = pop)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = edu)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = unmply)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = pov)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = law)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()
ggplot(data = st_as_sf(sf_data_2023)) +
  geom_sf(aes(fill = imig)) +
  scale_fill_viridis_c() +  # opsional untuk skala warna yang lebih baik
  theme_minimal()


# Plot Crime Temporal Trend
library(dplyr)
library(ggplot2)

crime_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_crime = mean(CrimeIndex, na.rm = TRUE))

ggplot(crime_avg_all, aes(x = Tahun, y = mean_crime)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_crime, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Crime Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Crime") +
  theme_minimal()

# Plot Gini Temporal Trend
library(dplyr)
library(ggplot2)

wage_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_wage = mean(MinimumWageAverage, na.rm = TRUE))

ggplot(wage_avg_all, aes(x = Tahun, y = mean_wage)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_wage, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Upah Minimum Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Upah") +
  theme_minimal()

gdp_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_gdp = mean(GDPPerCapita, na.rm = TRUE))

ggplot(gdp_avg_all, aes(x = Tahun, y = mean_gdp)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_gdp, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata GDP Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata GDP") +
  theme_minimal()

pop_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_pop = mean(PopulationDensity, na.rm = TRUE))

ggplot(pop_avg_all, aes(x = Tahun, y = mean_pop)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_pop, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Kepadatan Penduduk Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Kepadatan Penduduk") +
  theme_minimal()

edu_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_edu = mean(YearsofEducation, na.rm = TRUE))

ggplot(edu_avg_all, aes(x = Tahun, y = mean_edu)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_edu, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Lama Pendidikan Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Lama Pendidikan") +
  theme_minimal()

unemploy_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_unemploy = mean(Unemployment, na.rm = TRUE))

ggplot(unemploy_avg_all, aes(x = Tahun, y = mean_unemploy)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_unemploy, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Tingkat Pengangguran Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Tingkat Pengangguran") +
  theme_minimal()

gini_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_gini = mean(GiniIndex, na.rm = TRUE))

ggplot(gini_avg_all, aes(x = Tahun, y = mean_gini)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_gini, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Gini Index Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Gini") +
  theme_minimal()

pov_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_pov = mean(Poverty, na.rm = TRUE))

ggplot(pov_avg_all, aes(x = Tahun, y = mean_pov)) +
  geom_line(color = "steelblue", size = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_pov, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Tingkat Kemiskinan Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Tingkat Kemiskinan") +
  theme_minimal()

law_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_law = mean(Law, na.rm = TRUE))

ggplot(law_avg_all, aes(x = Tahun, y = mean_law)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_law, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Tingkat Law Enforcement Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Tingkat Law Enforcement") +
  theme_minimal()

imig_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(mean_imig = mean(Imigrants, na.rm = TRUE))

ggplot(imig_avg_all, aes(x = Tahun, y = mean_imig)) +
  geom_line(color = "steelblue", linewidth = 1.2) +
  geom_point(color = "steelblue", size = 2.5) +
  geom_text(aes(label = round(mean_imig, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Rata-rata Jumlah Imigran Seluruh Negara per Tahun",
       x = "Tahun",
       y = "Rata-rata Jumlah Imigran") +
  theme_minimal()

library(dplyr)
library(ggplot2)
library(patchwork)  # untuk menggabungkan plot

# Hitung rata-rata tiap variabel per tahun untuk seluruh negara
df_avg_all <- data %>%
  group_by(Tahun) %>%
  summarise(
    crime = mean(CrimeIndex, na.rm = TRUE),
    gini = mean(GiniIndex, na.rm = TRUE),
    unemploy = mean(Unemployment, na.rm = TRUE),
    pop = mean(PopulationDensity, na.rm = TRUE),
    pov = mean(Poverty, na.rm = TRUE),
    gdp = mean(GDPPerCapita, na.rm = TRUE),
    wage = mean(MinimumWageAverage, na.rm = TRUE),
    edu = mean(YearsofEducation, na.rm = TRUE),
    law = mean(Law, na.rm = TRUE),
    imig = mean(Imigrants, na.rm = TRUE),
  ) %>%
  ungroup()

# Fungsi untuk membuat plot satu variabel
plot_variable <- function(var_name) {
  ggplot(df_avg_all, aes_string(x = "Tahun", y = var_name)) +
    geom_line(color = "blue", size = 1) +
    labs(title = paste("Rata-rata", var_name),
         x = "Tahun",
         y = var_name) +
    theme_minimal()
}

# Buat plot untuk semua variabel
p1 <- plot_variable("crime")
p2 <- plot_variable("gini")
p3 <- plot_variable("unemploy")
p4 <- plot_variable("pop")
p5 <- plot_variable("pov")
p6 <- plot_variable("gdp")
p7 <- plot_variable("wage")
p8 <- plot_variable("edu")
p9 <- plot_variable("law")
p10 <- plot_variable("imig")

# Gabungkan semua plot dalam satu frame (3 kolom x 3 baris)
(p1 | p2 | p3) /
  (p4 | p5 | p6) /
  (p7 | p8 | p9 | p10)


library(ggplot2)
library(tidyr)

# Ubah data ke format long untuk variabel selain crime
df_long <- data %>%
  pivot_longer(cols = c(GiniIndex, Unemployment, PopulationDensity, Poverty, GDPPerCapita, MinimumWageAverage, YearsofEducation, Law, Imigrants),
               names_to = "variable",
               values_to = "value")

# Buat scatter plot crime vs variabel lain
ggplot(df_long, aes(x = value, y = CrimeIndex)) +
  geom_point(alpha = 0.5) +
  facet_wrap(~ variable, scales = "free_x") +
  labs(title = "Scatter Plot Variabel terhadap Crime",
       x = "Nilai Variabel",
       y = "Crime") +
  theme_minimal()


# Scatter Plot Gini vs Crime 2023
crime.gini.2023 <- data.frame(Country = crime_2023$Country,
                              sov_a3 = crime_2023$sov_a3,
                              crime = crime_2023$Tahun.2023,
                              gini = gini_2023$Tahun.2023)
install.packages("ggrepel")  # jika belum terinstall
library(ggrepel)

ggplot(crime.gini.2023, aes(x = gini, y = crime)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "blue", linetype = "dashed") +
  geom_text_repel(aes(label = Country), size = 3, max.overlaps = 6)+
  labs(title = "Scatter Plot Gini Index terhadap Crime Index",
       x = "Gini Index",
       y = "Crime Index") +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black", size = 0.5),
    axis.ticks = element_line(color = "black", size = 0.5)
  )

