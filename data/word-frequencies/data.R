# Downloads in all words from Tolstoy's War and Peace. 
# Outputs file with rank and frequency for all words.
# Authors: Sara Altman, Bill Behrman
# Version: 2018-02-01

# Libraries
library(tidyverse)
library(gutenbergr)
library(tidytext)

# Parameters
  # Ebook number from www.gutenberg.org
war_and_peace_id <- 2600
  # Output file
file_out <- "war_and_peace.rds"
#===============================================================================

gutenberg_download(war_and_peace_id) %>% 
  unnest_tokens(word, text) %>% 
  count(word, sort = TRUE, name = "freq") %>% 
  mutate(rank = row_number()) %>% 
  write_rds(file_out, compress = "gz")

