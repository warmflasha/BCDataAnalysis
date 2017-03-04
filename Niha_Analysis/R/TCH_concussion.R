setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/load_libraries.R")
source("R/data_cleanup.R")
source("R/parse_raw_scores.R")


load_TCH <- function(mypath = "raw_data/tch_data.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

load_morton_ranch <- function(mypath = "raw_data/morton_ranch.csv"){
  mydf <- read.csv(mypath, stringsAsFactors = FALSE)
  return(mydf)
}

path <- "feather/02_10_17.feather"
normal_pop <- read_feather(path)
                                                                                                                  
invalid_users <- c(6815, 7482, 10057, 10082, 11678, 12018, 13049, 13161, 14968, 17355, 20460)


tch_batteries <- load_TCH()
tch_batteries <- clean_admin_view_csv_header(tch_batteries)
morton_ranch_batteries <- load_morton_ranch()
morton_ranch_batteries <- clean_admin_view_csv_header(morton_ranch_batteries)
batteries <- tch_batteries %>% rbind(morton_ranch_batteries) %>%
                    filter(!(user_id %in% invalid_users))
batteries$raw_scores <- clean_user_scores(batteries$raw_scores) 

###########################################################################################

score_chunks <- batteries[,c("battery_id", "raw_scores")]

raw_scores_row_1 <- (split_key_val(score_chunks$raw_scores[[1]]))
clean_scores_row_1 <- raw_scores_row_1[, 2]
names(clean_scores_row_1) <- raw_scores_row_1[,1]  %>% clean_user_scores()
clean_scores_df <- data.frame(clean_scores_row_1, stringsAsFactors = F) %>%
  t() %>%
  data.frame(stringsAsFactors = F)
clean_scores_df$battery_id <-score_chunks[1,]$battery_id


for(i in 2:nrow(score_chunks)) {
  key_val <- split_key_val(score_chunks$raw_scores[[i]])
  clean_scores_row <- key_val[ ,2] 
  names(clean_scores_row) <- key_val[,1] %>% clean_user_scores() 
  clean_scores_row <- data.frame(clean_scores_row, stringsAsFactors=FALSE)  %>%
    t() %>%
    data.frame(stringsAsFactors = F)
  clean_scores_row$battery_id <- score_chunks[i,]$battery_id 
  clean_scores_df<- merge(clean_scores_df, clean_scores_row, all = TRUE)
  
}

batteries <- batteries %>% left_join(clean_scores_df, by = "battery_id")

batteries <- batteries %>% select(battery_id, user_id, created_at, age, gender,stroop_reaction_time_incongruent_median,digit_symbol_duration_median, immediate_recall_correct,delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median) 

sorted_bat <- batteries %>% group_by(user_id) %>% arrange(battery_id)
concussed_youth <- sorted_bat[!duplicated(sorted_bat$user_id),]

youth <- normal_pop %>% filter(age %in% 10:18)
normal_age_group_1 <- youth %>% filter(age %in% 10:13) %>% sample_n(5)
normal_age_group_2 <- youth %>% filter(age %in% 14:18) %>% sample_n(16)
normal_youth <- normal_age_group_1 %>% bind_rows(normal_age_group_2)

