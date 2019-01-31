Gapminder EDA
================
Bill Behrman
2018-10-09

-   [Country codes and names](#country-codes-and-names)

``` r
# Libraries
library(tidyverse)

# Parameters
  # Data files
file_countries <- "../data/countries.rds"
file_gdp_per_capita <- "../data/gdp_per_capita.rds"
file_life_expectancy <- "../data/life_expectancy.rds"
file_population <- "../data/population.rds"

#===============================================================================

# Read in data
countries <- read_rds(file_countries)
gdp_per_capita <- read_rds(file_gdp_per_capita)
life_expectancy <- read_rds(file_life_expectancy)
population <- read_rds(file_population)
```

Country codes and names
-----------------------

``` r
country_codes_names <- 
  countries %>% 
  select(iso_a3, name, un_status) %>% 
  rename(country = name) %>% 
  full_join(
    gdp_per_capita %>% 
      filter(!is.na(gdp_per_capita)) %>% 
      distinct(iso_a3, name) %>% 
      rename(gdp_per_capita = name),
    by = "iso_a3"
  ) %>% 
  full_join(
    life_expectancy %>% 
      filter(!is.na(life_expectancy)) %>% 
      distinct(iso_a3, name) %>% 
      rename(life_expectancy = name),
    by = "iso_a3"
  ) %>% 
  full_join(
    population %>% 
      filter(!is.na(population)) %>% 
      distinct(iso_a3, name) %>% 
      rename(population = name),
    by = "iso_a3"
  )
```

Check to see which countries do not have data for all three variables.

``` r
v <- 
  country_codes_names %>% 
  filter(
    !is.na(country) &
      (is.na(gdp_per_capita) | is.na(life_expectancy) | is.na(population))
  )

v %>% 
  knitr::kable()
```

| iso\_a3 | country             | un\_status | gdp\_per\_capita    | life\_expectancy | population          |
|:--------|:--------------------|:-----------|:--------------------|:-----------------|:--------------------|
| vat     | Holy See            | observer   | NA                  | NA               | Holy See            |
| lie     | Liechtenstein       | member     | NA                  | NA               | Liechtenstein       |
| mco     | Monaco              | member     | Monaco              | NA               | Monaco              |
| nru     | Nauru               | member     | Nauru               | NA               | Nauru               |
| plw     | Palau               | member     | Palau               | NA               | Palau               |
| smr     | San Marino          | member     | San Marino          | NA               | San Marino          |
| kna     | St. Kitts and Nevis | member     | St. Kitts and Nevis | NA               | St. Kitts and Nevis |
| tuv     | Tuvalu              | member     | Tuvalu              | NA               | Tuvalu              |

8 countries in `countries` lack data in `gdp_per_capita` or `life_expectancy`.

Check consistency of names.

``` r
country_codes_names %>% 
  select(-un_status) %>% 
  gather(key = data, value = name, -iso_a3) %>% 
  filter(!is.na(name)) %>% 
  group_by(iso_a3) %>% 
  filter(n_distinct(name) > 1) %>% 
  nrow()
```

    ## [1] 0

The country names for each `iso_a3` code are the same in all four datasets.

Check consistency of `iso_a3` codes.

``` r
country_codes_names %>% 
  select(-un_status) %>% 
  gather(key = data, value = name, -iso_a3) %>% 
  filter(!is.na(name)) %>% 
  group_by(name) %>% 
  filter(n_distinct(iso_a3) > 1) %>% 
  nrow()
```

    ## [1] 0

The `iso_a3` codes for each country name are the same in all four datasets.
