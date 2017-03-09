library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(pipefittr)
library(janitor)
library(purrr)

load_batteries <- function(mypath = "/Users/Niha/Desktop/Old_Data/batteries_2017-02-03_19h46m01.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}
load_users <- function(mypath = "/Users/Niha/Desktop/Old_Data/users_2017-02-03_19h45m57.csv") {
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

clean_user_scores <- function(user_scores) {
  user_scores %>% gsub("\\{", "", .) %>%
    gsub('")"', '', .) %>%
    gsub("\\}", "", .) %>% 
    gsub('\\"', '', .) %>%
    trimws()
  
} 

clean_date_test_taken<-function(date){
  date <- date %>% str_split(' ') %>% unlist()
  return(date[[1]])
}
# get_key_val <- function(score_chunk) {
#   key_val <- str_split(score_chunk, "=>") %>%
#     unlist() %>% trimws()
#   names(key_val) <- c("key", "val")
#   result <- c(key_val['val'])
#   names(result) <- key_val['key']
#   return(result)
# }
source("R/filter_batteries.R")

  ####Data Filtering###################



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
  dat$created_at <- lapply(dat$created_at, clean_date_test_taken)
  
  dat <- dat %>% mutate(created_at = ymd(created_at))
  dat <- dat %>% 
          mutate(age = year(as.period(interval(dat$date_of_birth, dat$created_at))))

  
  ###Split up dat into memory vs. concussion product
test_modules <- c("stroop_reaction_time_incongruent_median", "digit_symbol_duration_median", "immediate_recall_correct", "delayed_recall_correct", "balance_mean_distance_from_center", "trails_b_duration_mean", "flanker_reaction_time_correct_median")
  organizations <- c(2694, 2806, 2694, 2806)
  invalid_users <- c(11634, 7367, 7374, 7001, 6999, 7000, 7374, 8684, 8669, 11)
  #############CONCUSSION ANALYSIS#####################################
  concussion <- dat %>% filter(battery_type_id == 1, organization_id %in% organizations, !user_id %in% invalid_users)
  

################################################################################### 


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
  score_chunks <- concussion[,c("battery_id", "raw_scores")]

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


combined <- concussion %>% left_join(clean_scores_df, by = "battery_id")
View(combined)

combined %>% group_by(gender) %>%
  summarise(n = n())  

write.csv(combined, file = "concussion_production_data.csv")


#################################################################################################
