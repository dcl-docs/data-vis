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
# US Census divisions
# Source: https://en.wikipedia.org/wiki/List_of_regions_of_the_United_States#Census_Bureau-designated_regions_and_divisions
divisions <-
  list(
    `East North Central` = c("IL", "IN", "MI", "OH", "WI"),
    `East South Central` = c("AL", "KY", "MS", "TN"),
    `Middle Atlantic` =	c("NJ", "NY", "PA"),
    `Mountain` = c("AZ", "CO", "ID", "MT", "NM", "NV", "UT", "WY"),
    `New England` = c("CT", "MA", "ME", "NH", "RI", "VT"),
    `Pacific` =	c("AK", "CA", "HI", "OR", "WA"),
    `South Atlantic` = c("DC", "DE", "FL", "GA", "MD", "NC", "SC", "VA", "WV"),
    `West North Central` = c("IA", "KS", "MN", "MO", "ND", "NE", "SD"),
    `West South Central` = c("AR", "LA", "OK", "TX")
  ) %>% 
  enframe(name = "division", value = "state") %>% 
  unnest()
  
# Output file
file_out <- "congress_2019.rds"
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
    first = congress_pull("name", "first"),
    last = congress_pull("name", "last"),
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
  select(-terms_data) %>% 
  mutate(
    name = str_c(first, last, sep = " "),
    age = round(decimal_date(start_date) - decimal_date(birthday), 2),
    chamber = 
      recode(
        chamber, 
        rep = "house", 
        sen = "senate", 
        .default = NA_character_
      ),
    party = fct_lump(party, n = 2)
  ) %>% 
  left_join(divisions, by = "state") 

# right now there are only 524 because there is one vacancy in North Carolina due to election fraud
v %>% 
  filter(
    year(end_date) > 2019, 
    !is.na(division) # exclude non-voting members from territories
  ) %>% 
  select(name, age, chamber, state, division, party) %>% 
  arrange(state, division, chamber, party) %>% 
  write_rds(file_out)
