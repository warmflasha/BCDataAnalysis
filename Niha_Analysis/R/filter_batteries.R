  filter_batteries <- function(bat){
    bat <- bat %>% clean_names()
       
      
      #rename(battery_id = battery, user_id = user, battery_type_id = battery_type, age = user_age, gender = user_gender) %>%
      #filter(incomplete == 'false', !raw_scores == "", baseline == "true")
       return(bat)
  }
  
  filter_users <- function(users) {
     users <- users %>% clean_names() %>%
      select(id, created_at, gender, date_of_birth) %>%
      rename(user_id = id) %>%
      mutate(date_of_birth = ymd(date_of_birth)) %>%
      ############
      mutate(age = year(as.period(interval(ymd(users$date_of_birth), now()))))
    return(users)
  }
  
  join_batteries_users <- function(batteries, users) {
    dat <- users %>% left_join(batteries) %>%
      filter(!raw_scores == "", baseline == 't')
  }