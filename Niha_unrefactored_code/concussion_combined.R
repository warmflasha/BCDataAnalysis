library(dplyr)
library(readr)
library(ggplot2)
library(lubridate)
library(tidyr)
library(stringr)
library(pipefittr)
library(janitor)
library(purrr)



load_concussion_production <- function(mypath = "/Users/Niha/Desktop/Old_Data/concussion_production_data.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

load_concussion_research <- function(mypath = "/Users/Niha/Desktop/Old_Data/concussion_research_data.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

production <- load_concussion_production() %>% select(-X)
research <- load_concussion_research() %>% select(-X)


combined_production_research <- production %>% bind_rows(research)
write.csv(combined_production_research, file = "combined_concussion.csv")


######plot different tests (score, frequency) ## 8 histograms
