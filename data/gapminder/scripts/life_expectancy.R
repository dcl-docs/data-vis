# Download Gapminder country life expectancy data.

# Documentation
# https://www.gapminder.org/data/documentation/gd004/

# Source
# https://github.com/Gapminder-Indicators/lex/raw/master/lex-by-gapminder.xlsx

# Author: Bill Behrman
# Version: 2018-10-14

# Libraries
library(tidyverse)
library(readxl)

# Parameters
  # URL of Excel spreadsheet with life expectancy data
url_life_expectancy <-
  "https://github.com/Gapminder-Indicators/lex/raw/master/lex-by-gapminder.xlsx"
  # Sheet with country life expectancy data
sheet <- "countries_and_territories"
  # Temporary directory
dir_tmp <- str_c("/tmp/", Sys.time() %>% as.integer(), "/")
# Temporary file
file_tmp <- "life_expectancy.xlsx"
  # Output file
file_out <- "../data/life_expectancy.rds"

#===============================================================================

# Create temp directory
if (!file.exists(dir_tmp)) {
  dir.create(dir_tmp, recursive = TRUE)
}

# Download Excel spreadsheet
path <- str_c(dir_tmp, file_tmp)
if (download.file(url = url_life_expectancy, destfile = path)) {
  stop("Error: Failed to download Excel spreadsheet")
}

# Read in and tidy data
df <- 
  read_excel(path, sheet = sheet) %>% 
  select(-starts_with("indicator")) %>% 
  select(iso_a3 = geo, name = geo.name, everything()) %>% 
  gather(
    key = year,
    value = life_expectancy,
    -iso_a3,
    -name,
    na.rm = TRUE,
    convert = TRUE
  ) %>% 
  mutate_if(is.character, str_trim) %>%
  filter(str_length(iso_a3) == 3) %>% 
  mutate_at(vars(iso_a3), ~ recode(., hos = "vat")) %>% 
  arrange(name, year)

# Remove temporary directory
if (unlink(dir_tmp, recursive = TRUE, force = TRUE)) {
  print("Error: Remove temporary directory failed")
}

# If no value for Taiwan in 2017, use value for 2016

if (!any(df$iso_a3 == "twn" & df$year == 2017)) {
  df <- 
    df %>% 
    add_row(
      iso_a3 = "twn",
      name = "Taiwan",
      year = 2017,
      life_expectancy = 
        df %>% filter(iso_a3 == "twn", year == 2016) %>% pull(life_expectancy)
    ) %>% 
    arrange(name, year)
}

# Check data
stopifnot(
  sum(is.na(df)) == 0,
  all(str_length(df$iso_a3) == 3),
  n_distinct(df$iso_a3) == n_distinct(df$name),
  df$year >= 1800,
  df$year <= 2100,
  df$life_expectancy > 0,
  df$life_expectancy < 100
)

# Write out results
df %>% write_rds(file_out)
