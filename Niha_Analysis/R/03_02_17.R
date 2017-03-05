setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")
source("R/data_cleanup.R")
source("R/parse_raw_scores.R")
library('RPostgreSQL')


path <- "feather/02_10_17.feather"
normal_pop <- read_feather(path)
research_batteries <- tbl(src_postgres("researchdb"),"batteries")

raw_scores_query <- "SELECT id, 
                  raw_scores -> 'researchData' AS researchData,
                  raw_scores -> 'stroop_reaction_time_incongruent_median' AS stroop_reaction_time_incongruent_median,
                  raw_scores -> 'digit_symbol_duration_median' AS digit_symbol_duration_median,
                raw_scores -> 'delayed_recall_correct' AS delayed_recall_correct,
                raw_scores -> 'immediate_recall_correct' AS immediate_recall_correct,
                raw_scores -> 'balance_mean_distance_from_center' AS balance_mean_distance_from_center,
                raw_scores -> 'trails_b_duration_mean' AS trails_b_duration_mean,
                  raw_scores -> 'flanker_reaction_time_correct_median' AS flanker_reaction_time_correct_median
FROM batteries"


raw_scores_db <- src_postgres('researchdb_copy') 
raw_scores_parsed <- tbl(raw_scores_db, sql(raw_scores_query))

raw_scores_parsed <- as.data.frame(raw_scores_parsed)
raw_scores_parsed <- raw_scores_parsed %>% 
                     rename(battery_id = id)
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
              
research_dat <- research_users %>% left_join(research_batteries, by = "user_id") %>%
                  filter(!raw_scores == "", baseline == 'TRUE', malingering == FALSE)

research_dat$created_at <- lapply(research_dat$created_at, clean_date_test_taken)
research_dat <- research_dat %>% mutate(created_at = ymd(created_at))  %>%
                     filter(created_at >= "2017-02-10")
research_dat <- research_dat %>% mutate(age = year(as.period(interval(research_dat$date_of_birth, research_dat$created_at))))
research_dat <- research_dat %>% left_join(raw_scores_parsed, by = "battery_id")

###################



