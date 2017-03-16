setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")

load_combined_concussion <- function(mypath = "cleaned_data/07_01_16_to_02_10_17/combined_concussion.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}
load_memory <- function(mypath ="cleaned_data/07_01_16_to_02_10_17/memory_cleaned_up.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}
load_new_feb_data <- function(mypath ="cleaned_data/07_01_16_to_02_10_17/new_feb_data.csv" ){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}
load_new_iphone_feb_data <- function(mypath ="cleaned_data/07_01_16_to_02_10_17/new_iphone_stuffs.csv" ){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

combine_all_data <- function(){
    concussion <- load_combined_concussion()
    concussion <- concussion %>% mutate(., created_at = as.character(created_at)) 

    memory <- load_memory()
    memory <- memory %>% mutate(., created_at = as.character(created_at)) 
  
    new_things <- load_new_feb_data() 
    new_things$baseline <- as.character(new_things$baseline)
    new_things$incomplete <- as.character(new_things$incomplete)
    
    new_iphone_things <- load_new_iphone_feb_data() %>% 
      select(-c(symptoms_checklist, administered_by_date_of_birth, administered_by_age))
    new_iphone_things <- new_iphone_things %>% mutate(., created_at = as.character(created_at)) 
    
    concussion_memory_combined <- concussion %>% full_join(memory) %>%
                                    select(-c(flanker_reaction_time_incorrect_mean))
    concussion_memory_feb <- concussion_memory_combined %>% full_join(new_things)
    everything <- concussion_memory_feb %>% full_join(new_iphone_things)
    everything <- unique(everything)
    everything$created_at <- ymd( everything$created_at)
    everything$date_of_birth <- ymd(everything$date_of_birth)
    return(everything)

}

dat <- combine_all_data() %>% unique()

path <- "02_10_17.feather"
write_feather(dat, path)


