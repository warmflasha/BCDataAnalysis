setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")
source("R/data_cleanup.R")
source("R/parse_raw_scores.R")
library('RPostgreSQL')


path <- "feather/02_10_17.feather"
normal_pop <- read_feather(path)
research_batteries <- tbl(src_postgres("researchdb"),"batteries")
research_users <- tbl(src_postgres("researchdb"), "users")
production_batteries <- tbl(src_postgres("productiondb"), "batteries")
production_users <- tbl(src_postgres("productiondb"), "users")


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


other_query <- "SELECT DISTINCT skeys(raw_scores) FROM batteries"

####RAW_SCORES RESEARCH
raw_scores_db_research <- src_postgres('researchdb_copy') 
raw_scores_parsed_research <- tbl(raw_scores_db_research, sql(raw_scores_query))
raw_scores_parsed_research <- as.data.frame(raw_scores_parsed_research)
raw_scores_parsed_research <- raw_scores_parsed_research %>% 
                     rename(battery_id = id)


keys <- src_postgres('researchdb_copy')
keys_parsed <- tbl(keys, sql(other_query))
keys_parsed <- as.data.frame(keys_parsed)



####RAW_SCORES PRODUCTION
raw_scores_db_production <- src_postgres('productiondb_copy')
raw_scores_parsed_production <- tbl(raw_scores_db_production, sql(raw_scores_query))
raw_scores_parsed_production <- as.data.frame(raw_scores_parsed_production) %>%
                               rename(battery_id = id)

################RESEARCH SERVER
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
research_dat <- research_dat %>% left_join(raw_scores_parsed_research, by = "battery_id")


########PRODUCTION SERVER
production_batteries <- as.data.frame(production_batteries)
production_users <- as.data.frame(production_users)
production_batteries$created_at <- as.character(production_batteries$created_at)
production_batteries$created_at <- lapply(production_batteries$created_at, clean_date_test_taken)

production_batteries <- production_batteries %>% 
  rename(battery_id = id) %>%
  filter(incomplete == 'FALSE') %>%
  mutate(created_at = ymd(created_at) )

production_users <- production_users %>%
  select(id, date_of_birth, gender) %>%
  rename(user_id = id) %>%
  mutate(date_of_birth = ymd(date_of_birth))

production_dat <- production_users %>% left_join(production_batteries, by = "user_id") %>%
  filter(!raw_scores == "", baseline == 'TRUE', malingering == FALSE)

production_dat$created_at <- lapply(production_dat$created_at, clean_date_test_taken)
production_dat <- production_dat %>% mutate(created_at = ymd(created_at))  %>%
  filter(created_at >= "2017-02-08")
production_dat <- production_dat %>% mutate(age = year(as.period(interval(production_dat$date_of_birth, production_dat$created_at))))
production_dat <- production_dat %>% left_join(raw_scores_parsed_production, by = "battery_id")




#########FILTER OUT FAKE DATA FROM RESEARCH AND PRODUCTION
##RESEARCH FILTERING
##convert character-type raw scores to numeric-type
test_cols_research <- which(colnames(research_dat)=='stroop_reaction_time_incongruent_median'):which(colnames(research_dat)=='flanker_reaction_time_correct_median')

research_dat[, test_cols_research] <- lapply(research_dat[, test_cols_research], as.numeric)


normal_slums_user_ids <- c(1140,1141, 1146, 1153, 1155, 1158, 1160, 1164, 1166, 1169, 
                           1170, 1175, 1176, 1190,1191,1197, 1198, 684, 954, 968, 982, 1008, 1093)
#research_dat <- research_dat %>% filter(user_id %in% normal_slums_user_ids)



##PRODUCTION FILTERING
###norm@, AWTY HS included
production_dat <- production_dat %>% filter(organization_id %in% c(3750, 3392))
test_cols_production <- which(colnames(production_dat)=='stroop_reaction_time_incongruent_median'):which(colnames(production_dat)=='flanker_reaction_time_correct_median')

production_dat[, test_cols_production] <- lapply(production_dat[, test_cols_production], as.numeric)

####COMBINE RESEARCH/PRODUCTION DATA
