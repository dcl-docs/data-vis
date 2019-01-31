# Download Gapminder country GDP per capita data.

# Documentation
# https://www.gapminder.org/data/documentation/gd001/

# Source
# https://github.com/Gapminder-Indicators/gdppc_cppp/raw/master/gdppc_cppp-by-gapminder.xlsx

# Author: Bill Behrman
# Version: 2018-10-13

# Libraries
library(tidyverse)
library(readxl)

# Parameters
  # URL of Excel spreadsheet with GDP per capita data
url_gdp_per_capita <- 
  "https://github.com/Gapminder-Indicators/gdppc_cppp/raw/master/gdppc_cppp-by-gapminder.xlsx"
  # Sheet with country GDP per capita data
sheet <- "countries_and_territories"
  # Temporary directory
dir_tmp <- str_c("/tmp/", Sys.time() %>% as.integer(), "/")
  # Temporary file
file_tmp <- "gdp_per_capita.xlsx"
  # Output file
file_out <- "../data/gdp_per_capita.rds"

#===============================================================================

# Create temp directory
if (!file.exists(dir_tmp)) {
  dir.create(dir_tmp, recursive = TRUE)
}

# Download Excel spreadsheet
path <- str_c(dir_tmp, file_tmp)
if (download.file(url = url_gdp_per_capita, destfile = path)) {
  stop("Error: Failed to download Excel spreadsheet")
}

# Read in and tidy data
df <- 
  read_excel(path, sheet = sheet) %>% 
  select(-starts_with("indicator")) %>% 
  select(iso_a3 = geo, name = geo.name, everything()) %>% 
  gather(
    key = year,
    value = gdp_per_capita,
    -iso_a3,
    -name,
    na.rm = TRUE,
    convert = TRUE
  ) %>% 
  mutate_if(is.character, str_trim) %>%
  mutate_at(vars(iso_a3), ~ recode(., hos = "vat")) %>% 
  arrange(name, year)

# Remove temporary directory
if (unlink(dir_tmp, recursive = TRUE, force = TRUE)) {
  print("Error: Remove temporary directory failed")
}

# Check data
stopifnot(
  sum(is.na(df)) == 0,
  all(str_length(df$iso_a3) == 3),
  n_distinct(df$iso_a3) == n_distinct(df$name),
  df$year >= 1800,
  df$year <= 2040,
  df$gdp_per_capita > 0,
  df$gdp_per_capita < 2e5
)

# Write out results
df %>% write_rds(file_out)
