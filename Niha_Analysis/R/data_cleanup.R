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

clean_admin_view_csv_header <- function(batteries){
  batteries_cleaned <- batteries %>% clean_names() %>%
    rename(battery_id = battery) %>%
    rename(user_id = user) %>%
    rename(battery_type_id = battery_type) %>%
    rename(age = user_age) %>%
    rename(gender = user_gender)
    #filter(incomplete == 'FALSE', !raw_scores == "")
    return(batteries_cleaned)
}