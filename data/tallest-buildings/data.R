# Reads table from Wikipedia on world's tallest buildings
# Source: https://en.wikipedia.org/wiki/List_of_tallest_buildings

# Authors: Sara Altman, Bill Behrman
# Version: 2018-01-08

# Libraries
library(tidyverse)
library(rvest)

# Parameters
# URL for data
url_data <-
  "https://en.wikipedia.org/wiki/List_of_tallest_buildings"
# CSS selector
css_selector <- "#mw-content-text > div > table:nth-child(18)"
# Output file with all variables for all buildings
file_out_all <- "tallest_buildings.rds"
# Output file for just then te tallest buildings
file_out_10 <- "tallest_buildings_10.rds"

#===============================================================================

all_buildings <-
  url_data %>%
  read_html() %>%
  html_node(css = css_selector) %>%
  html_table() %>%
  as_tibble(.name_repair = "unique") %>% 
  rename_all(
    ~ str_to_lower(.) %>% str_remove_all(., "[:punct:].*[:punct:]")
  ) %>% 
  rename(height_m = height5, height_ft = height6) %>% 
  mutate_at(
    vars(contains("height"), built), 
    ~ str_remove_all(., ",|(\\s|\\[).*") %>% as.double()
  ) %>% 
  select(-rank) %>% 
  write_rds(file_out_all)

all_buildings %>% 
  top_n(n = 10, wt = height_m) %>% 
  write_rds(file_out_10)

             