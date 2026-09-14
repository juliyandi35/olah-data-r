data <- read.csv("divorces-per-1000-people.csv")
head(data)

data2 <- data[data$Year>=2013 & data$Year<=2023,]
head(data2)
data2 <- data2[,-5]
colnames(data2) <- c("Country","Code","Year","Divorce.Rate")

writexl::write_xlsx(data2,"Divorce Rate By Country.xlsx")

# Install dan load paket yang diperlukan
library(forecast)
library(dplyr)
library(tidyr)

# Membuat daftar tahun yang diinginkan
full_years <- 2013:2023

# Melengkapi data yang hilang
completed_data <- data2 %>%
  group_by(Country, Code) %>%
  complete(Year = full_years) %>%
  ungroup()

# Mengisi nilai yang hilang dengan SES
completed_data <- completed_data %>%
  group_by(Country, Code) %>%
  mutate(Divorce.Rate = ifelse(
    is.na(Divorce.Rate), 
    {
      hist_data <- na.omit(Divorce.Rate)
      if (length(hist_data) >= 2) {
        model <- lm(Value ~ Year, data = data.frame(Year = Year[!is.na(Divorce.Rate)], Value = hist_data))
        pred <- predict(model, newdata = data.frame(Year = Year[is.na(Divorce.Rate)]))
      } else {
        NA
      }
    }, 
    Divorce.Rate
  )) %>%
  ungroup()


# Menampilkan hasil
print(completed_data)

writexl::write_xlsx(completed_data,"Divorce Rate By Country 2013 2023.xlsx")
