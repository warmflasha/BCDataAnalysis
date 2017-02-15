library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(pipefittr)
library(janitor)
library(purrr)

load_batteries <- function(mypath = "/Users/Niha/Desktop/Old_Data/batteries_2017-02-03_22h48m55.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}
load_users <- function(mypath = "/Users/Niha/Desktop/Old_Data/users_2017-02-03_22h48m54.csv") {
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

#load_new_stuff <- function(mypath = "/Users/Niha/Desktop/Braincheck/Code/.csv")



load_ruby_script <- function(mypath = "/Users/Niha/Desktop/Old_Data/ruby_new_data.csv") {
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

ruby_script <- load_ruby_script()
View(ruby_script)


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


batteries <- load_batteries() %>% clean_names() %>%
  select(-(created_at)) %>%
  rename(battery_id = id) %>%
  filter(incomplete == 'f')

users <- load_users() %>% clean_names() %>%
  select(id, created_at, gender, date_of_birth) %>%
  rename(user_id = id) %>%
  mutate(date_of_birth = ymd(date_of_birth)) 

dat <- users %>% left_join(batteries, by = "user_id") %>%
  filter(!raw_scores == "", baseline == 't')

dat$raw_scores <- clean_user_scores(dat$raw_scores) 
dat$created_at <- clean_date_test_taken(dat$created_at)

dat <- dat %>% mutate(created_at = ymd(created_at))
dat <- dat %>% 
  mutate(age = year(as.period(interval(dat$date_of_birth, dat$created_at))))

###Split up dat into memory vs. concussion product
test_modules <- c("stroop_reaction_time_incongruent_median", "digit_symbol_duration_median", "immediate_recall_correct", "delayed_recall_correct", "balance_mean_distance_from_center", "trails_b_duration_mean", "flanker_reaction_time_correct_median")
organizations <- c(10)
valid_batteries <- c(29, 46 ,61 ,23 ,13 ,28 ,45 ,50 ,51 ,52 ,59 ,65 ,73 ,71 ,84 ,88 ,22 ,27 ,35, 40,54, 26,30, 42, 44, 12, 18, 43, 64, 78, 21, 169,155, 165,156 ,137, 160, 139, 150, 158, 173, 162, 163, 172, 164, 170, 168, 138, 148, 147, 146, 153, 143, 159, 171, 141, 142, 145, 157, 149, 140, 167, 195,199,196,187,182, 189, 193)


memory <- dat %>% filter(battery_type_id == 2, organization_id %in% organizations, battery_id %in% valid_batteries)


# score_chunks <- memory[,c("battery_id", "raw_scores")]
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

####get all the names of the columns first (read in all key names)
###only keep unique columns
##create empty dataframe with those column names
##add rows to dataframe

# ###dataframe initialized with first row 
# raw_scores_row_1 <- (split_key_val(score_chunks$raw_scores[[1]]))
# clean_scores_row_1 <- raw_scores_row_1[, 2] %>% str_replace_all(., "[[:punct:]]", "") 
# names(clean_scores_row_1) <- raw_scores_row_1[,1]  
# clean_scores_df <- data.frame(clean_scores_row_1, stringsAsFactors = F) %>%
#    t() %>%
#    data.frame(stringsAsFactors = F)
#  clean_scores_df$battery_id <-score_chunks[1,]$battery_id
# 
# ## empty data frame, append onto it in loop
# all_the_names <- character()
# for(i in 1:nrow(score_chunks)) {
#   key_val <- split_key_val(score_chunks$raw_scores[[i]]) ##dataframe
#   clean_scores_row <- key_val[ ,2] ##character vector of number scores
#   names(clean_scores_row) <- key_val[,1] %>% clean_user_scores() 
#   all_the_names[i] <- key_val[,1]
#   ##character vector with number scores named
#   #clean_scores_row$battery_id <- score_chunks[i,]$battery_id ##assigning user_id of row to dataframe
#   #clean_scores_df<- merge(clean_scores_df, clean_scores_row, all = TRUE)
# }
# 
# all_the_names <- character()
# for(i in 1:nrow(score_chunks)) {
#   print(score_chunks$raw_scores[[i]])
#   key_val <- split_key_val(score_chunks$raw_scores[[i]])
#   print("key_val_col1")
#   print(key_val[, 1])
#   print("size of key_val_col1")
#   print(length(key_val[, 1]))
#   print("type of key_val_col1")
#   print(typeof(key_val[, 1]))
#   all_the_name <- append(all_the_names, key_val[, 1])
# }
# 
# 
# clean_scores_df <- clean_scores_df %>% select(battery_id, stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, trails_b_duration_mean)


####Combine dataframes
 memory_fixed <- ruby_script %>% clean_names() %>% left_join(memory)  
 memory_fixed <- memory_fixed %>% select(-c(raw_scores)) 
View(memory_fixed)

memory_fixed %>% group_by(gender) %>%
  summarise(n = n())  


write.csv(memory_fixed, file = "memory_cleaned_up.csv")
