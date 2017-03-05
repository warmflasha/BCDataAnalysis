setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")
library('RPostgreSQL')
research_batteries <- tbl(src_postgres("researchdb"), "batteries")
research_slums <- tbl(src_postgres("researchdb"), "slums_screeners")

clean_user_scores <- function(user_scores) {
  user_scores %>% gsub("\\{", "", .) %>%
    gsub('")"', '', .) %>%
    gsub("\\}", "", .) %>% 
    gsub('\\"', '', .) %>%
    trimws()
} 

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

#34  pg = dbDriver("PostgreSQL")
#con = dbConnect(pg, dbname = "researchdb")
#dtab = dbGetQuery(con, "select raw_scores::text from batteries")
#SELECT raw_score FROM raw_scores;read

research_batteries <- as.data.frame(research_batteries)
research_batteries$raw_scores <- clean_user_scores(research_batteries$raw_scores)

