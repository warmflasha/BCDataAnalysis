
load_csv <- function(path){
  mydf <- read.csv(path, stringsAsFactors = FALSE)
  return(mydf)
}

