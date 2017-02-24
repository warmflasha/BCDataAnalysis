  filter_users <- function(users) {
     users <- users %>% clean_names() %>%
      select(id, created_at, gender, date_of_birth) %>%
      rename(user_id = id) %>%
      mutate(date_of_birth = ymd(date_of_birth)) %>%

      mutate(age = year(as.period(interval(ymd(users$date_of_birth), users$created_at))))
    return(users)
  }
  
