setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")
source("R/data_cleanup.R")
source("R/parse_raw_scores.R")
library('RPostgreSQL')


path <- "feather/02_10_17.feather"
normal_pop <- read_feather(path)
research_batteries <- tbl(src_postgres("researchdb"), "batteries")
research_users <- tbl(src_postgres("researchdb"), "users")
################

research_batteries <- as.data.frame(research_batteries)
research_users <- as.data.frame(research_users)
research_batteries$created_at <- as.character(research_batteries$created_at)
research_batteries$created_at <- lapply(research_batteries$created_at, clean_date_test_taken)

research_batteries <- research_batteries %>% 
                      rename(battery_id = id) %>%
                      filter(incomplete == 'FALSE') %>%
                      mutate(created_at = ymd(created_at) )

research_users <- research_users %>%
                  select(id, date_of_birth, gender) %>%
                  rename(user_id = id) %>%
                  mutate(date_of_birth = ymd(date_of_birth))
              
research_dat  

#research_batteries$raw_scores <- clean_user_scores(research_batteries$raw_scores)


