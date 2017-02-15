clean_user_scores <- function(user_scores) {
  user_scores %>% gsub("\\{", "", .) %>%
    gsub('")"', '', .) %>%
    gsub("\\}", "", .) %>% 
    gsub('\\"', '', .) %>%
    trimws()
  
} 