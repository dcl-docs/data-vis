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
# Output file 
file_out_all <- "tallest_buildings.rds"

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
  rename(height_ft = height6, year = built) %>% 
  mutate(height_ft = str_remove_all(height_ft, ",|(\\s|\\[).*") %>% as.double()) %>% 
  select(-rank, -height5) %>% 
  write_rds(file_out_all)

             