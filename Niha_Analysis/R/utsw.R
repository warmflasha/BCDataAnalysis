setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")
source("R/data_cleanup.R")
source("R/parse_raw_scores.R")

mypath <- "/Users/Niha/Downloads/utsw_data.csv"
mydf <- read.csv(mypath, stringsAsFactors = FALSE)
mydf <- mydf %>% clean_names() %>% rename(battery_id = battery) %>%
  rename(user_id = user) %>%
  rename(battery_type_id = battery_type) %>%
  rename(age = user_age) %>%
  rename(gender = user_gender) %>%
  filter(!raw_scores == "")

mydf$raw_scores <- clean_user_scores(mydf$raw_scores) 
score_chunks <- mydf[,c("battery_id", "raw_scores")]
raw_scores_row_1 <- (split_key_val(score_chunks$raw_scores[[1]]))
clean_scores_row_1 <- raw_scores_row_1[, 2]
names(clean_scores_row_1) <- raw_scores_row_1[,1]  %>% clean_user_scores()
clean_scores_df <- data.frame(clean_scores_row_1, stringsAsFactors = F) %>%
  t() %>%
  data.frame(stringsAsFactors = F)
clean_scores_df$battery_id <-score_chunks[1,]$battery_id



for(i in 2:nrow(score_chunks)) {
  key_val <- split_key_val(score_chunks$raw_scores[[i]]) ##dataframe
  clean_scores_row <- key_val[ ,2] ##character vector of number scores
  names(clean_scores_row) <- key_val[,1] %>% clean_user_scores() ##character vector with number scores named
  clean_scores_row <- data.frame(clean_scores_row, stringsAsFactors=FALSE)  %>%
    t() %>%
    data.frame(stringsAsFactors = F)
  clean_scores_row$battery_id <- score_chunks[i,]$battery_id ##assigning user_id of row to dataframe
  clean_scores_df<- merge(clean_scores_df, clean_scores_row, all = TRUE)
  
}


df<- clean_scores_df %>% select(battery_id,stroop_reaction_time_incongruent_median, balance_mean_distance_from_center, flanker_reaction_time_correct_median, trails_b_duration_mean, immediate_recall_correct, delayed_recall_correct, digit_symbol_duration_median)

df[] <- lapply(df, function(x) as.numeric(as.character(x)))

utsw <- mydf %>% left_join(df, by = "battery_id")

iPhone <- utsw %>% filter(!device_model == 'iPad')
