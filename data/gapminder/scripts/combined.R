# Gapminder data for country name, region_gm4, population, GDP per capita, and
# life expectancy every `interval` years from `year_begin` to `year_end`.

# Author: Bill Behrman
# Version: 2018-10-11

# Libraries
library(tidyverse)

# Parameters
  # Data files
file_countries <- "../data/countries.rds"
file_gdp_per_capita <- "../data/gdp_per_capita.rds"
file_life_expectancy <- "../data/life_expectancy.rds"
file_population <- "../data/population.rds"
  # Year range
year_begin <- 1950
year_end <- 2015
  # Year interval
interval <- 5
  # Output file prefix
file_out <- "../data/combined"

#===============================================================================

# Read in data
countries <- read_rds(file_countries)
gdp_per_capita <- read_rds(file_gdp_per_capita)
life_expectancy <- read_rds(file_life_expectancy)
population <- read_rds(file_population)

# Combine data and write out
countries %>% 
  filter(un_status == "member") %>% 
  select(iso_a3, name, region = region_gm4) %>% 
  mutate_at(vars(region), str_to_title) %>% 
  left_join(population %>% select(-name), by = "iso_a3") %>% 
  left_join(gdp_per_capita %>% select(-name), by = c("iso_a3", "year")) %>% 
  left_join(life_expectancy %>% select(-name), by = c("iso_a3", "year")) %>% 
  filter(year >= year_begin, year <= year_end, year %% interval == 0) %>% 
  group_by(iso_a3) %>% 
  filter(
    all(!is.na(population)) &
    all(!is.na(gdp_per_capita)) &
    all(!is.na(life_expectancy))
  ) %>% 
  ungroup() %>% 
  write_rds(str_glue(file_out, "_{year_begin}-{year_end}_{interval}yr.rds"))
