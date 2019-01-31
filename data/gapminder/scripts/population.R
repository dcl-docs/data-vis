# Download Gapminder country population data.

# Documentation
# https://www.gapminder.org/data/documentation/gd003/

# Source
# https://docs.google.com/spreadsheets/d/18Ep3s1S0cvlT1ovQG9KdipLEoQ1Ktz5LtTTQpDcWbX0/edit#gid=1668956939

# Author: Bill Behrman
# Version: 2018-10-13

# Libraries
library(tidyverse)
library(googlesheets)

# Parameters
  # URL of Google sheet with population data
url_population <- "https://docs.google.com/spreadsheets/d/18Ep3s1S0cvlT1ovQG9KdipLEoQ1Ktz5LtTTQpDcWbX0/edit#gid=1668956939"
  # Sheet with country population data
sheet <- "data-countries-etc-by-year"
  # Output file
file_out <- "../data/population.rds"

#===============================================================================

# Read in data
df <- 
  extract_key_from_url(url_population) %>% 
  gs_key() %>% 
  gs_read(
    ws = sheet,
    col_types = cols(
      geo = col_character(),
      name = col_character(),
      time = col_integer(),
      population = col_double()
    )
  ) %>% 
  rename(
    iso_a3 = geo,
    year = time
  ) %>% 
  mutate_if(is.character, str_trim) %>% 
  mutate_at(vars(iso_a3), ~ recode(., hos = "vat")) %>% 
  arrange(name, year)

# Check data
stopifnot(
  sum(is.na(df)) == 0,
  all(str_length(df$iso_a3) == 3),
  n_distinct(df$iso_a3) == n_distinct(df$name),
  df$year >= 1800,
  df$year <= 2100,
  df$population > 0,
  df$population < 2e9
)

# Write out results
df %>% write_rds(file_out)
