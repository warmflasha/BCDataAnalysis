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