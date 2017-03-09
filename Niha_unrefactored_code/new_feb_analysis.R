
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

clean_date_test_taken<-function(date){
  date <- date %>% str_split(' ') %>% unlist()
  return(date[[1]])
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
batteries$created_at <- lapply(batteries$created_at, clean_date_test_taken)
batteries <- batteries %>% mutate(created_at = mdy(created_at) )


####USER ID: 266 (SKIP USER)
feb_fixed <- ruby_script %>% clean_names() %>% left_join(batteries)  

View(feb_fixed)
write.csv(feb_fixed, file = "new_feb_data.csv")



