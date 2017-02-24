setwd("~/Data-Analysis-BrainCheck/Niha_Analysis")
source("R/February_combined.R")

df <- dat %>% select(age, device_model, stroop_reaction_time_incongruent_median,digit_symbol_duration_median, immediate_recall_correct,delayed_recall_correct, balance_mean_distance_from_center, trails_b_duration_mean, flanker_reaction_time_correct_median)

##NEW AGE BINS
#df$agecat <-cut(df$age, c(10,14,19,36, 51, 66, 76,120), right = FALSE, labels = c("10-13", "14-18", "19-35", "36-50", "51-65", "66-75", "76+"))
##OLD AGE BINS
df$agecat <-cut(df$age, c(0,10,14,19,36, 51, 66,120), right = FALSE, labels = c("0-9", "10-13", "14-18", "19-35", "36-50", "51-65", "66-120"))
df$device <- NA
df$device[grepl("iPhone",df$device_model)] <- "iPhone"
df$device[grepl("iPad", df$device_model)] <- "iPad"
df$device[grepl("browser", df$device_model)] <- "browser"

##########
stroop_df <- df %>% select(agecat, device, stroop_reaction_time_incongruent_median) %>% drop_na()
stroop <- ddply(stroop_df, c("device", "agecat"), summarise,
                N = length(!is.na(stroop_reaction_time_incongruent_median)),
                mean = mean(stroop_reaction_time_incongruent_median, na.rm = TRUE),
                SD = sd(stroop_reaction_time_incongruent_median, na.rm = TRUE))
stroop["Test"] <- "stroop_reaction_time_incongruent_median"


digit_symbol_df <- df %>% select(agecat, device, digit_symbol_duration_median) %>% drop_na()
digit_symbol <- ddply(digit_symbol_df, c("device", "agecat"), summarise,
                N = length(!is.na(digit_symbol_duration_median)),
                mean = mean(digit_symbol_duration_median, na.rm = TRUE),
                SD = sd(digit_symbol_duration_median, na.rm = TRUE))
digit_symbol["Test"] <- "digit_symbol_duration_median"

immediate_recall_df <- df %>% select(agecat, device, immediate_recall_correct) %>% drop_na() 
immediate_recall <- ddply(immediate_recall_df, c("device", "agecat"), summarise,
                      N = length(!is.na(immediate_recall_correct)),
                      mean = mean(immediate_recall_correct, na.rm = TRUE),
                      SD = sd(immediate_recall_correct, na.rm = TRUE))
immediate_recall["Test"] <- "immediate_recall_correct"

delayed_recall_df <- df %>% select(agecat, device, delayed_recall_correct) %>% drop_na()
delayed_recall <- ddply(delayed_recall_df, c("device", "agecat"), summarise,
                          N = length(!is.na(delayed_recall_correct)),
                          mean = mean(delayed_recall_correct, na.rm = TRUE),
                          SD = sd(delayed_recall_correct, na.rm = TRUE))
delayed_recall["Test"] <- "delayed_recall_correct"

balance_df <- df %>% select(agecat, device, balance_mean_distance_from_center) %>% drop_na()
balance <- ddply(balance_df, c("device", "agecat"), summarise,
                        N = length(!is.na(balance_mean_distance_from_center)),
                        mean = mean(balance_mean_distance_from_center, na.rm = TRUE),
                        SD = sd(balance_mean_distance_from_center, na.rm = TRUE))
balance["Test"] <- "balance_mean_distance_from_center"

trails_df <- df %>% select(agecat, device, trails_b_duration_mean) %>% drop_na()
trails <- ddply(trails_df, c("device", "agecat"), summarise,
                 N = length(!is.na(trails_b_duration_mean)),
                 mean = mean(trails_b_duration_mean, na.rm = TRUE),
                 SD = sd(trails_b_duration_mean, na.rm = TRUE))
trails["Test"] <- "trails_b_duration_mean"

flanker_df <- df %>% select(agecat, device, flanker_reaction_time_correct_median) %>% drop_na()
flanker <- ddply(flanker_df, c("device", "agecat"), summarise,
                N = length(!is.na(flanker_reaction_time_correct_median)),
                mean = mean(flanker_reaction_time_correct_median, na.rm = TRUE),
                SD = sd(flanker_reaction_time_correct_median, na.rm = TRUE))
flanker["Test"] <- "flanker_reaction_time_correct_median"

population_stats <- stroop %>% bind_rows(digit_symbol, immediate_recall, delayed_recall, balance, trails, flanker)

csv_view <- population_stats %>% select(mean, SD, device, agecat, Test )
write.csv(csv_view, file = "population-data-2017-02-24.csv")
