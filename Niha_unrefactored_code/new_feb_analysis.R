
library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(pipefittr)
library(janitor)
library(purrr)



load_new_stuff <- function(mypath = "/Users/Niha/Desktop/Old_Data/02-10_no_metadata_raw_scores.csv" )
{
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}


load_ruby_script <- function(mypath = "/Users/Niha/Desktop/Old_Data/ruby_weird_data_feb.csv") {
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

ruby_script <- load_ruby_script()


clean_user_scores <- function(user_scores) {
  user_scores %>% gsub("\\{", "", .) %>%
    gsub('")"', '', .) %>%
    gsub("\\}", "", .) %>% 
    gsub('\\"', '', .) %>%
    gsub("researchData=>", '', .) %>%
    trimws()
  
}

clean_date_test_taken <-function(date){
  date <- date %>% str_split(' ') %>% unlist()
  return(date[1])
}


batteries <- load_new_stuff () 

batteries <- batteries %>% clean_names() %>%
  rename(battery_id = battery) %>%
  rename(user_id = user) %>%
  rename(battery_type_id = battery_type) %>%
  rename(age = user_age) %>%
  rename(gender = user_gender) %>%
  filter(incomplete == 'FALSE', !raw_scores == "", baseline == "TRUE")


batteries$raw_scores <- clean_user_scores(batteries$raw_scores) 
batteries$created_at <- clean_date_test_taken(batteries$created_at)
batteries <- batteries %>% mutate(created_at = mdy(created_at) )

# score_chunks <- batteries[,c("battery_id", "raw_scores")]
# 
# split_key_val <- function(raw_scores){
#   test_dat <- raw_scores %>% str_replace_all(., "[\r\n]" , "") %>%
#     str_split(",") %>%
#     unlist() %>%
#     str_split("=>") %>%
#     unlist() %>%
#     matrix(ncol=2,byrow=T) %>%
#     data.frame(stringsAsFactors=F)
#   return(test_dat)
# }
# 
# raw_scores_row_1 <- (split_key_val(score_chunks$raw_scores[[1]]))
# clean_scores_row_1 <- raw_scores_row_1[, 2]
# names(clean_scores_row_1) <- raw_scores_row_1[,1]  %>% clean_user_scores()
# clean_scores_df <- data.frame(clean_scores_row_1, stringsAsFactors = F) %>%
#   t() %>%
#   data.frame(stringsAsFactors = F)
# clean_scores_df$battery_id <-score_chunks[1,]$battery_id
# 
# 
# for(i in 2:nrow(score_chunks)) {
#   key_val <- split_key_val(score_chunks$raw_scores[[i]]) ##dataframe
#   clean_scores_row <- key_val[ ,2] ##character vector of number scores
#   names(clean_scores_row) <- key_val[,1] %>% clean_user_scores() ##character vector with number scores named
#   clean_scores_row <- data.frame(clean_scores_row, stringsAsFactors=FALSE)  %>%
#     t() %>%
#     data.frame(stringsAsFactors = F)
#   clean_scores_row$battery_id <- score_chunks[i,]$battery_id ##assigning user_id of row to dataframe
#   clean_scores_df<- merge(clean_scores_df, clean_scores_row, all = TRUE)
#   
# }
# clean_scores_df <- clean_scores_df %>% 
#   select( stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median, battery_id)
# 
# combined <- batteries %>% left_join(clean_scores_df, by = "battery_id") %>%
#                 select(-c(user_first_name, user_last_name, user_email, baseline, incomplete)) %>%
#                 filter(battery_id != 266)


####USER ID: 266 (SKIP USER)
feb_fixed <- ruby_script %>% clean_names() %>% left_join(batteries)  

View(feb_fixed)
write.csv(feb_fixed, file = "new_feb_data.csv")









#test <- batteries$raw_scores[1] 

# 
# load_bat_3 <- function(mypath = "/Users/Niha/Desktop/battery_type_3_cleaned_up.csv" )
# {
#   mydf <- read.csv(mypath, stringsAsFactors = FALSE)
#   return(mydf)
# }
# 
# cleaned_up_bat <- load_bat_3()
# score_chunks <- clean ed_up_bat[,c("battery_id", "raw_scores")]
# 
# split_key_val <- function(raw_scores){
#   test_dat <- raw_scores %>% str_replace_all(., "[\r\n]" , "") %>%
#     str_split(",") %>%
#     unlist() %>%
#     str_split("=>") %>%
#     unlist() %>%
#     matrix(ncol=2,byrow=T) %>%
#     data.frame(stringsAsFactors=F)
#   return(test_dat)
# }
# 
# raw_scores_row_1 <- (split_key_val(score_chunks$raw_scores[[1]]))
# clean_scores_row_1 <- raw_scores_row_1[, 2]
# names(clean_scores_row_1) <- raw_scores_row_1[,1]  %>% clean_user_scores()
# clean_scores_df <- data.frame(clean_scores_row_1, stringsAsFactors = F) %>%
#   t() %>%
#   data.frame(stringsAsFactors = F)
# clean_scores_df$battery_id <-score_chunks[1,]$battery_id
# 
# 
# for(i in 2:nrow(score_chunks)) {
#   key_val <- split_key_val(score_chunks$raw_scores[[i]]) ##dataframe
#   clean_scores_row <- key_val[ ,2] ##character vector of number scores
#   names(clean_scores_row) <- key_val[,1] %>% clean_user_scores() ##character vector with number scores named
#   clean_scores_row <- data.frame(clean_scores_row, stringsAsFactors=FALSE)  %>%
#     t() %>%
#     data.frame(stringsAsFactors = F)
#   clean_scores_row$battery_id <- score_chunks[i,]$battery_id ##assigning user_id of row to dataframe
#   clean_scores_df<- merge(clean_scores_df, clean_scores_row, all = TRUE)
#   
# }
# View(clean_scores_df)
# 
# clean_scores_df <- clean_scores_df %>% 
#   select( stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median, battery_id)
# 
# combined <- cleaned_up_bat %>% left_join(clean_scores_df, by = "battery_id") %>% filter(battery_id != 266)
# write.csv(combined, file= "new_stuff.csv")

 
# 
# users <- load_users() %>% clean_names() %>%
#   select(id, date_of_birth) %>%
#   rename(user_id = id) %>%
#   filter(!date_of_birth == "") %>%
#   mutate(date_of_birth = ymd(date_of_birth)) 
# current_time <- now()
# users$age <- year(as.period(interval(ymd(users$date_of_birth), current_time)))
# dat <- users %>% left_join(batteries) %>%
#   select(user_id,battery_id, age, battery_type_id, organization_id,baseline, device_model, raw_scores ) %>%
#   filter(!raw_scores == "", baseline == 't')



#metadata_ids <- c(31, 159, 65, 96, 133, 191, 184, 61, 32, 195, 101, 132, 194, 155, 190, 99, 167, 125, 38, 134, 193, 136, 94, 46, 128, 66, 57, 52, 93, 192, 29, 75, 39, 70, 189, 56, 186, 59, 45, 43, 197, 183, 86, 40, 19, 17, 37, 35, 21, 83, 53,23, 22, 76, 131, 84, 106, 135, 50, 34, 139, 169, 98, 156, 109, 147, 162, 168, 141, 150, 158, 157, 71, 79, 164, 160, 137, 64, 182, 165, 138, 80, 153, 181, 142, 97, 199, 198, 146, 127, 140, 126, 51, 73, 95, 77, 187, 124, 171, 172, 196, 78, 72, 163, 129, 60, 88, 185, 143, 173, 148, 170, 85, 81, 28, 188,145, 149, 26, 27, 54, 74, 44, 62, 11, 68, 1, 18, 42, 48, 82, 33)




