# Reads in Tidy Tuesday mortgage rate data originally from Freddie Mac

# Author: Sara Altman, Bill Behrman
# Version: 2019-02-08

# Libraries
library(tidyverse)

# Parameters
# Data URL
url_data <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-02-05/mortgage.csv"
# Output file
file_out <- "us_mortgage_rates.rds"
#===============================================================================

read_csv(url_data) %>% 
  select(date, fixed_rate_30_yr) %>% 
  filter(!is.na(fixed_rate_30_yr)) %>% 
  write_rds(file_out, compress = "gz")
