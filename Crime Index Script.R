library(readxl)
library(dplyr)
library(tidyr)

# Replace "your_excel_file.xlsx" with your actual file name
file_path <- "Global Crime Index 2013 to 2023.xlsx"

# Get sheet names
sheet_names <- excel_sheets(file_path)

# Read data from each sheet and combine
data_list <- lapply(sheet_names, function(sheet) {
  sheet_data <- read_excel(file_path, sheet = sheet)
  sheet_data <- sheet_data[, c("Country", "Crime Index")]
  colnames(sheet_data)[2] <- paste0("Tahun.", sheet)
  return(sheet_data)
})

# Merge data from all sheets
combined_data <- Reduce(function(x, y) merge(x, y, by = "Country", all = TRUE), data_list)

# Print the combined data
print(combined_data)

#Optional: Save the combined data to a new Excel file
writexl::write_xlsx(combined_data, "Crime Index Data.xlsx")
