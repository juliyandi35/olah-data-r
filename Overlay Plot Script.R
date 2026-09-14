library(readxl)
data <- read_excel("Overlay Data.xlsx")
names(data)

# Imputasi NA berdasarkan rata-rata per Country
data <- data %>%
  group_by(Country) %>%
  mutate(
    Crime.Index = ifelse(is.na(Crime.Index), mean(Crime.Index, na.rm = TRUE), Crime.Index),
    Gini.Index = ifelse(is.na(Gini.Index), mean(Gini.Index, na.rm = TRUE), Gini.Index)
  ) %>%
  ungroup()

data_2023 <- data %>% filter(Tahun == 2023)

# Rename kolom agar sesuai dengan yang digunakan pada merge nanti
crime.gini.dataset <- data_2023 %>%
  select(Country, Code = sov_a3, Crime = Crime.Index, Gini = Gini.Index)

library(sf)
world <- read_sf("world_shapefile.shp")
world$sov_a3[17] <- "USA"
world$sov_a3[196] <- "CHN"
world$sov_a3[32] <- "GBR"
world$sov_a3[97] <- "NLD"
world$sov_a3[161] <- "FRA"
world$sov_a3[170] <- "FIN"
world$sov_a3[182] <- "DNK"
world$sov_a3[226] <- "AUS"

world_bound <- world[,c(5,169)]
colnames(world_bound) <- c("Code","geometry")

# Merge data shapefile dan dataset Crime-Gini
sf_data <- merge(crime.gini.dataset, world_bound, by = "Code")

# Visualisasi
library(ggplot2)
library(gridExtra)

# Peta Crime Index
ggplot(data = st_as_sf(sf_data)) +
  geom_sf(aes(fill = Crime)) +
  scale_fill_viridis_c() +
  theme_minimal()

# Peta Gini Index
ggplot(data = st_as_sf(sf_data)) +
  geom_sf(aes(fill = Gini)) +
  scale_fill_viridis_c() +
  theme_minimal()

# Gabungan Crime + Gini Index
sf_data$CrimeandGini <- sf_data$Crime + sf_data$Gini
ggplot(data = st_as_sf(sf_data)) +
  geom_sf(aes(fill = CrimeandGini)) +
  scale_fill_viridis_c() +
  theme_minimal()
