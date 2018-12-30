# Download ACS data on non-English languages spoken at home for US and states

# Authors: Sara Altman, Bill Behrman
# Version: 2018-10-11

# Libraries
library(tidyverse)

# Parameters
  # Base API query
api_base <- "https://api.census.gov/data/2013/language?get=NAME,LANLABEL,EST,LAN39,LAN7&for="
  # API queries for aggregation at country and state levels
api_query <-
  c("us", "state") %>%
  set_names() %>%
  map_chr(~ str_c(api_base, ., ":*&LAN="))
  # Output file for non-English languages spoken at home for the US
file_us <- "non-english_languages_us.rds"
  # Output file for non-English languages spoken at home for the states
file_states <- "non-english_languages_states.rds"
  # Output file for non-English/Spanish languages spoken at home in Utah
file_utah <- "non-english-spanish_languages_utah.rds"

#===============================================================================

# Get languages for region
get_languages <- function(region) {
  v <- jsonlite::fromJSON(api_query[region])
  colnames(v) <- v[1, ]
  v %>%
    as_tibble() %>%
    slice(-1) %>%
    rename_all(str_to_lower) %>%
    rename(
      language = lanlabel,
      speakers = est
    ) %>%
    mutate_at(vars(-name, -language), as.integer)
}

# Check US data
v <- get_languages("us")
v1 <-
  v %>%
  filter(language == "Speak a language other than English at home") %>%
  pull(speakers)
v2 <-
  v %>%
  filter(lan > 0, !is.na(speakers)) %>%
  pull(speakers) %>%
  sum()
v2 - v1

# Out of over 60 million speakers, the sum for the individual languages
# undercounts the total by only 265. Some of the languages have NAs, which may
# account for the discrepancy.

# Non-English languages spoken at home for the US
get_languages("us") %>%
  filter(lan > 0, speakers > 0) %>%
  select(language, speakers) %>%
  arrange(desc(speakers), language) %>%
  write_rds(file_us)

# Check consistency of US and state data
v2 <-
  get_languages("state") %>%
  filter(state <= 56, lan > 0, speakers > 0) %>%
  pull(speakers) %>%
  sum()
v2 - v1

# Out of over 60 million speaker, the sum of the individual languages for the
# states undercounts the total for the US by 25882, or 0.04%. Again some of the
# languages for states have NAs, which may account for the discrepancy.

# Non-English languages spoken at home for the states
get_languages("state") %>%
  filter(state <= 56, lan > 0, speakers > 0) %>%
  select(state = name, language, speakers) %>%
  arrange(state, desc(speakers)) %>%
  write_rds(file_states)

get_languages("state") %>%
  filter(name == "Utah", language != "Spanish", lan > 0, speakers > 0) %>%
  top_n(n = 20, wt = speakers) %>%
  select(language, speakers) %>%
  arrange(desc(speakers)) %>%
  write_rds(file_utah)

# get_languages("state") %>%
#   filter(
#     name %in% c("Massachusetts", "Tennessee"),
#     language != "Spanish",
#     lan > 0,
#     speakers > 0
#   ) %>%
#   group_by(language) %>% 
#   mutate(total = sum(speakers, na.rm = TRUE)) %>% 
#   ungroup() %>% 
#   top_n(n = 40, wt = total) %>%
#   select(
#     state = name, 
#     language, 
#     speakers
#   ) -> x
#   arrange(language, desc(speakers)) %>% 
#   write_rds(file_virginias)


 