library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(pipefittr)
library(janitor)
library(purrr)

load_batteries <- function(mypath = "/Users/Niha/Desktop/Old_Data/batteries-2017-02-10 (1).csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}
clean_user_scores <- function(user_scores) {
  user_scores %>% gsub("\\{", "", .) %>%
    gsub('")"', '', .) %>%
    gsub("\\}", "", .) %>% 
    gsub('\\"', '', .) %>%
    gsub("researchData=>", '', .) %>%
    trimws()
  
}

clean_date_test_taken<-function(date){
  date <- date %>% str_split(' ') %>% unlist()
  return(date[[1]])
}



 batteries <- load_batteries () %>% clean_names() %>%
  rename(battery_id = battery) %>%
  rename(user_id = user) %>%
  rename(battery_type_id = battery_type) %>%
  rename(age = user_age) %>%
  rename(gender = user_gender) %>%
  filter(incomplete == 'false', !raw_scores == "", baseline == "true")

  batteries$raw_scores <- clean_user_scores(batteries$raw_scores)
  batteries$created_at <- lapply(batteries$created_at, clean_date_test_taken)
  batteries <- batteries %>% mutate(created_at = ymd(created_at) )

# 
# load_bat_3 <- function(mypath = "/Users/Niha/Desktop/battery_type_3_cleaned_up.csv" )
# {
#   mydf <- read.csv(mypath, stringsAsFactors = FALSE)
#   return(mydf)
# }
# 
# cleaned_up_bat <- load_bat_3()
score_chunks <- batteries[,c("battery_id", "raw_scores")]

split_key_val <- function(raw_scores){
  test_dat <- raw_scores %>% str_replace_all(., "[\r\n]" , "") %>%
    str_split(",") %>%
    unlist() %>%
    str_split("=>") %>%
    unlist() %>%
    matrix(ncol=2,byrow=T) %>%
    data.frame(stringsAsFactors=F)
  return(test_dat)
}

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
View(clean_scores_df)

clean_scores_df <- clean_scores_df %>% 
  select( stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median, battery_id)

iPhone <- batteries %>% left_join(clean_scores_df, by = "battery_id")  %>%
            select(-c(user_first_name, user_last_name, user_email))
write.csv(iPhone, file = "new_iphone_stuffs.csv")
