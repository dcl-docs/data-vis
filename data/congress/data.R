# Reads in data on Congress members' ages

# Authors: Sara Altman, Bill Behrman
# Version: 2018-01-10

# Libraries
library(jsonlite)
library(tidyverse)
library(lubridate)

# Parameters
# URL for historical data
url_current_data <- 
  "https://theunitedstates.io/congress-legislators/legislators-current.json"
# URL for current data
url_historical_data <-
  "https://theunitedstates.io/congress-legislators/legislators-historical.json"

# Output file
file_out <- "congress_ages.rds"

#===============================================================================

congress_pull <- function(category, var, default = NA) {
  all %>% 
    map(category) %>% 
    map_chr(var, .default = default)
}

all <-
  list(
    read_json(url_historical_data),
    read_json(url_current_data)
  ) %>%
  purrr::flatten()

v <-
  tibble(
    id = congress_pull("id", "bioguide"),
    first_name = congress_pull("name", "first"),
    last_name = congress_pull("name", "last"),
    birthday = congress_pull("bio", "birthday") %>% as_date(),
    gender = congress_pull("bio", "gender"),
    terms_data = map(all, "terms")
  ) %>% 
  unnest(terms_data) %>% 
  mutate(
    start_date = map_chr(terms_data, "start", .default = NA) %>% as_date(),
    end_date = map_chr(terms_data, "end", .default = NA) %>% as_date(),
    party = map_chr(terms_data, "party", .default = NA),
    chamber = map_chr(terms_data, "type", .default = NA),
    state = map_chr(terms_data, "state", .default = NA)
  ) %>%  
  mutate(
    age = decimal_date(start_date) - decimal_date(birthday),
    chamber = 
      recode(
        chamber, 
        rep = "house", 
        sen = "senate", 
        .default = NA_character_
      )
  ) %>% 
  filter(!is.na(birthday), age > 24) %>% 
  select(
    id, 
    first_name, 
    last_name, 
    birthday,
    age, 
    gender, 
    chamber, 
    state, 
    party, 
    start_date, 
    end_date
  ) %>% 
  write_rds(file_out)
  

# some birthdays are wrong
# check if the birthday is the same for each person
# fix party names


