# Data from "From Boom to Bust: A Typology of Real Commodity Prices in the Long Run." NBER Working Paper 18874.

# Author: Sara Altman, Bill Behrman
# Version: 2019-02-06

# Libraries
library(tidyverse)
library(readxl)

# Parameters
  # Data URL
url_data <- "http://www.sfu.ca/~djacks/data/boombust/Real%20commodity%20prices,%201850-2017.xlsx"
  # Output file
file_out <- "wheat_prices.rds"
#===============================================================================

# Create temporary directory
dir_tmp <- str_glue("/tmp/{Sys.time() %>% as.integer()}")
if (!file.exists(dir_tmp)) {
  dir.create(dir_tmp, recursive = TRUE)
}

destination <- str_glue("{dir_tmp}/commodities.xlsx")

if (download.file(url = url_data, destfile = destination, quiet = TRUE)) {
  stop("Error: Download failed")
}

read_excel(destination, skip = 1) %>% 
  rename(year = `(1900=100)`) %>% 
  gather(key = "product", value = "price", -year) %>% 
  filter(product == "Wheat") %>% 
  mutate(product = str_to_lower(product)) %>% 
  write_rds(file_out)

# Remove temporary directory
if (unlink(dir_tmp, recursive = TRUE, force = TRUE)) {
  print("Error: Remove temporary directory failed")
}