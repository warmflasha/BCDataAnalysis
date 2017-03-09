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

normal_pop <- normal_pop %>% select(battery_id, user_id, gender, age, created_at, battery_type_id, stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median)



normal_youth <- normal_pop %>% filter(age %in% 10:18, battery_type_id == 1)
normal_youth <- normal_youth %>% ungroup() %>% 
                select( age,stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median) %>% 
                mutate(percentage_immediate_recall_correct = (immediate_recall_correct/20), percentage_delayed_recall_correct = (delayed_recall_correct/20))

concussed_youth[,6:12] <- sapply(concussed_youth[,6:12], as.numeric)

concussed_youth <- concussed_youth %>% ungroup() %>% 
                  select( age,stroop_reaction_time_incongruent_median, digit_symbol_duration_median, immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median) %>%
  mutate(percentage_immediate_recall_correct = (immediate_recall_correct/20), percentage_delayed_recall_correct = (delayed_recall_correct/20))


normal_youth$group <- 'Healthy'
concussed_youth$group <- 'Concussion'

###Flanker
normal_flanker_df <- normal_youth%>% select(group, flanker_reaction_time_correct_median) %>% drop_na()
concussed_flanker_df <- concussed_youth %>% select(group, flanker_reaction_time_correct_median) %>% drop_na()
##Stroop
normal_stroop_df <- normal_youth%>% select(group, stroop_reaction_time_incongruent_median) %>% drop_na()
concussed_stroop_df <- concussed_youth %>% select(group, stroop_reaction_time_incongruent_median) %>% drop_na()
##Digit-Symbol
normal_digit_symbol_df <- normal_youth%>% select(group, digit_symbol_duration_median) %>% drop_na()
concussed_digit_symbol_df <- concussed_youth %>% select(group, digit_symbol_duration_median) %>% drop_na()
##Trails
normal_trails_df <- normal_youth%>% select(group, trails_b_duration_mean) %>% drop_na()
concussed_trails_df <- concussed_youth %>% select(group, trails_b_duration_mean) %>% drop_na()
##Balance
normal_balance_df <- normal_youth%>% select(group, balance_mean_distance_from_center) %>% drop_na()
concussed_balance_df <- concussed_youth %>% select(group, balance_mean_distance_from_center) %>% drop_na()
##Immediate Recall
normal_immediate_recall_df <- normal_youth%>% select(group, percentage_immediate_recall_correct) %>% drop_na()
concussed_immediate_recall_df <- concussed_youth %>% select(group, percentage_immediate_recall_correct) %>% drop_na()
##Delayed Recall
normal_delayed_recall_df <- normal_youth%>% select(group, percentage_delayed_recall_correct) %>% drop_na()
concussed_delayed_recall_df <- concussed_youth %>% select(group, percentage_delayed_recall_correct) %>% drop_na()


##T-tests
flanker_t <- tidy(t.test(normal_flanker_df$flanker_reaction_time_correct_median,concussed_flanker_df$flanker_reaction_time_correct_median))  
stroop_t <- tidy(t.test(normal_stroop_df$stroop_reaction_time_incongruent_median,concussed_stroop_df$stroop_reaction_time_incongruent_median))
digit_symbol_t <- tidy(t.test(normal_digit_symbol_df$digit_symbol_duration_median,concussed_digit_symbol_df$digit_symbol_duration_median))
trails_t <- tidy(t.test(normal_trails_df$trails_b_duration_mean,concussed_trails_df$trails_b_duration_mean))
balance_t <- tidy(t.test(normal_balance_df$balance_mean_distance_from_center,concussed_balance_df$balance_mean_distance_from_center))
immediate_recall_t <- tidy(t.test(normal_immediate_recall_df$percentage_immediate_recall_correct,concussed_immediate_recall_df$percentage_immediate_recall_correct))
delayed_recall_t <- tidy(t.test(normal_delayed_recall_df$percentage_delayed_recall_correct,concussed_delayed_recall_df$percentage_delayed_recall_correct))


##K-S tests
flanker_ks<- tidy(ks.test(normal_flanker_df$flanker_reaction_time_correct_median,concussed_flanker_df$flanker_reaction_time_correct_median))
stroop_ks <- tidy(ks.test(normal_stroop_df$stroop_reaction_time_incongruent_median,concussed_stroop_df$stroop_reaction_time_incongruent_median))
digit_symbol_ks <- tidy(ks.test(normal_digit_symbol_df$digit_symbol_duration_median,concussed_digit_symbol_df$digit_symbol_duration_median))
trails_ks <- tidy(ks.test(normal_trails_df$trails_b_duration_mean,concussed_trails_df$trails_b_duration_mean))
balance_ks <- tidy(ks.test(normal_balance_df$balance_mean_distance_from_center,concussed_balance_df$balance_mean_distance_from_center))
immediate_recall_ks <- tidy(ks.test(normal_immediate_recall_df$percentage_immediate_recall_correct,concussed_immediate_recall_df$percentage_immediate_recall_correct))
delayed_recall_ks <- tidy(ks.test(normal_delayed_recall_df$percentage_delayed_recall_correct,concussed_delayed_recall_df$percentage_delayed_recall_correct))


flanker_groups_combined <- rbind(normal_flanker_df, concussed_flanker_df)
stroop_groups_combined <- rbind(normal_stroop_df, concussed_stroop_df)
digit_symbol_groups_combined <- rbind(normal_digit_symbol_df, concussed_digit_symbol_df)
trails_groups_combined <- rbind(normal_trails_df, concussed_trails_df)
balance_groups_combined <- rbind(normal_balance_df, concussed_balance_df)
immediate_recall_groups_combined <- rbind(normal_immediate_recall_df, concussed_immediate_recall_df)
delayed_recall_groups_combined <- rbind(normal_delayed_recall_df, concussed_delayed_recall_df)
