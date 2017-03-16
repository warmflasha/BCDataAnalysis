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

normal_users <- c(1184, 1187, 1188, 1189, 1200, 1201,1204,1205, 1211, 1212, 1213, 1221, 1230, 1231, 1235, 1236)
research_dat <- research_dat %>% filter(user_id %in% normal_users)
sorted_research_dat <- research_dat %>% group_by(user_id) %>% arrange(battery_id)
research_dat <- sorted_research_dat[!duplicated(sorted_research_dat$user_id),]



##PRODUCTION FILTERING
###norm@, AWTY HS included
production_dat <- production_dat %>% filter(organization_id %in% c(3750, 3392))
test_cols_production <- which(colnames(production_dat)=='stroop_reaction_time_incongruent_median'):which(colnames(production_dat)=='flanker_reaction_time_correct_median')

production_dat[, test_cols_production] <- lapply(production_dat[, test_cols_production], as.numeric)

####COMBINE RESEARCH/PRODUCTION DATA
combined <- research_dat %>% full_join(production_dat)

####join with normal pop data
combined$administered_at <- as.character(combined$administered_at)
combined$updated_at <- as.character(combined$updated_at)
combined$baseline <- as.character(combined$baseline)
combined$incomplete <- as.character(combined$incomplete)

normal_pop_updated <- normal_pop %>% full_join(combined, by =c("user_id", "date_of_birth", "gender", "battery_id", "battery_type_id", "administered_by_id", "created_at", "updated_at", "device_id", "organization_id", "baseline", "incomplete", "scores", "raw_scores", "device_model", "os_version", "version", "age", "stroop_reaction_time_incongruent_median", "digit_symbol_duration_median", "delayed_recall_correct", "immediate_recall_correct", "balance_mean_distance_from_center", "trails_b_duration_mean", "flanker_reaction_time_correct_median"))

normal_pop_updated <- normal_pop_updated %>% select(-c(X,administered_at.x, completed_at.x, completed_at.y, speedometer_score.x, speedometer_score.y, notes.x, notes_updated_at.y, notes_updated_at.x, notes_updated_at.y, malingering.x, malingering.y))



write.csv(normal_pop_updated, file = "normal_pop_2017_03_02.csv")
