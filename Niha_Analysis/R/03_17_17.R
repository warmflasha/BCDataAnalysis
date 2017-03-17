library('RPostgreSQL')
library('dplyr')
library('lubridate')

path <- "/Users/Niha/Data-Analysis-BrainCheck/Niha_Analysis/cleaned_data/normal/03_14_17.csv"
normal_pop <- read.csv(path, stringsAsFactors = FALSE)

batteries <- tbl(src_postgres("researchdb"),sql("SELECT * FROM batteries WHERE created_at >= '2017-03-16'"),check.names = FALSE)
batteries <- as.data.frame(batteries)
raw_scores_query <- "SELECT DISTINCT skeys(raw_scores) FROM batteries"
raw_scores <- tbl(src_postgres("researchdb"),sql(raw_scores_query))
raw_score_keys <- as.data.frame(raw_scores)$skeys
query_template <- "SELECT id, "

for(key in raw_score_keys ) {
  query_template <- (paste(query_template,paste("raw_scores -> '",key,"'"," AS ", key,",",sep = ""), sep = '\n'))
}

query_template <- substr(query_template, 1 , nchar(query_template) - 1)
query_template <- (paste(query_template,"FROM batteries WHERE created_at >= '2017-03-02'" ))
cat(query_template)
raw_scores_parsed <- tbl(src_postgres("researchdb"),sql(query_template), check.names = FALSE)
raw_scores_parsed <- as.data.frame(raw_scores_parsed)
metadata_query <- "SELECT DISTINCT  skeys(rtrim(ltrim((raw_scores -> 'researchData'), '{'), '}')::hstore) FROM batteries"
metadata <-tbl(src_postgres("researchdb"),sql(metadata_query))
metadata_keys <- as.data.frame(metadata)$skeys
query_template_2 <- "SELECT id, "
for(key in metadata_keys ) {
  query_template_2 <- (paste(query_template_2,paste("researchData -> '",key,"'"," AS ", key,",",sep = ""), sep = '\n'))
}

cat(query_template_2)
##remove final comma
query_template_2 <- substr(query_template_2, 1 , nchar(query_template_2) - 1)
query_template_2 <- (paste(query_template_2,"FROM (SELECT id, rtrim(ltrim((raw_scores -> 'researchData'), '{'), '}')::hstore AS researchData FROM batteries WHERE created_at >= '2017-03-02') AS foo" ))
cat(query_template_2)
metadata_parsed <- tbl(src_postgres("researchdb"),sql(query_template_2), check.names = FALSE)
metadata_parsed <- as.data.frame(metadata_parsed)


###users
research_users <- tbl(src_postgres("researchdb"), "users")
research_users <- as.data.frame(research_users)

research_batteries <- batteries %>% left_join(raw_scores_parsed, by = "id") %>% left_join(metadata_parsed, by ="id")

research_batteries <- research_batteries %>% 
  rename(battery_id = id) %>%
  filter(incomplete == 'FALSE', baseline == 'TRUE') %>%
  mutate(created_at = ymd_hms(created_at) )

research_users <- research_users %>%
  select(id, date_of_birth, gender) %>%
  rename(user_id = id) %>%
  mutate(date_of_birth = ymd(date_of_birth))

research_dat <- research_users %>% left_join(research_batteries, by = "user_id") %>%
  filter(!raw_scores == "", baseline == 'TRUE', malingering == FALSE)

research_dat <- research_dat %>% mutate(age = year(as.period(interval(research_dat$date_of_birth, research_dat$created_at))))

test_cols_research <- which(colnames(research_dat)=='stroop_reaction_time_incongruent_median'):which(colnames(research_dat)=='flanker_reaction_time_correct_median')

research_dat[, test_cols_research] <- lapply(research_dat[, test_cols_research], as.numeric)

str(research_dat)

###write new dat to csv
write.csv(research_dat, file = "/Users/Niha/Data-Analysis-BrainCheck/Niha_Analysis/cleaned_data/new_data_03_17_17.csv"  )
path2 <- "/Users/Niha/Data-Analysis-BrainCheck/Niha_Analysis/cleaned_data/new_data_03_17_17.csv"
new_dat <- read.csv(path2, stringsAsFactors = FALSE)
new_dat$baseline <- as.character(new_dat$baseline)
new_dat$incomplete <- as.character(new_dat$incomplete)
new_dat$researchdata <- as.character(new_dat$researchdata)
##read in csv and add to normal pop

updated <- new_dat %>% full_join(normal_pop,  by = c("user_id", "date_of_birth", "gender", "battery_id", "battery_type_id", "administered_by_id", "created_at", "updated_at", "device_id", "organization_id", "baseline", "incomplete", "scores", "raw_scores", "device_model", "os_version", "version", "age", "stroop_reaction_time_incongruent_median", "digit_symbol_duration_median", "delayed_recall_correct", "immediate_recall_correct", "balance_mean_distance_from_center", "trails_b_duration_mean", "flanker_reaction_time_correct_median"))

write.csv(updated, file = "03_17_17.csv")

