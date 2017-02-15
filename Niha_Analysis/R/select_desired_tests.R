select_desired_tests -> function(df){
  df <- df %>% select(stroop_reaction_time_incongruent_median, digit_symbol_duration_median, 
                      immediate_recall_correct, delayed_recall_correct, balance_mean_distance_from_center, 
                      trails_b_duration_mean, flanker_reaction_time_correct_median, battery_id)
}