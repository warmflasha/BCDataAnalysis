trails_plot <- function(bucket, title) {
  trails <- bucket %>%
    group_by(trails_b_duration_mean) %>%
    summarise(n = n()) 
  
  s <- ggplot(trails, aes(x = trails_b_duration_mean))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .15)   + theme_classic() 
  return(s)
}

stroop_plot <- function(bucket, title) {
  stroop <- bucket %>%
    group_by(stroop_reaction_time_incongruent_median) %>%
    summarise(n = n()) 
  
  s <- ggplot(stroop, aes(x = stroop_reaction_time_incongruent_median))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .1)   + theme_classic() 
  return(s)
}

immediate_recall_plot <- function(bucket, title) {
  immediate_recall <- bucket %>%
    group_by(immediate_recall_correct) %>%
    summarise(n = n()) 
  
  s <- ggplot(immediate_recall, aes(x = immediate_recall_correct))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .15)   + theme_classic() 
  return(s)
}

flanker_plot <- function(bucket, title) {
  flanker <- bucket %>%
    group_by(flanker_reaction_time_correct_median) %>%
    summarise(n = n()) 
  
  s <- ggplot(flanker, aes(x = flanker_reaction_time_correct_median))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .15)   + theme_classic() 
  return(s)
}

digit_symbol_plot <- function(bucket, title) {
  digit_symbol <- bucket %>%
    group_by(digit_symbol_duration_median) %>%
    summarise(n = n()) 
  
  s <- ggplot(digit_symbol, aes(x = digit_symbol_duration_median))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .15)   + theme_classic() 
  return(s)
}
 
delayed_recall_plot <- function(bucket, title) {
  delayed_recall <- bucket %>%
    group_by(delayed_recall_correct) %>%
    summarise(n = n()) 
  
  s <- ggplot(delayed_recall, aes(x = delayed_recall_correct))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .2)   + theme_classic() 
  return(s)
}

balance_plot <- function(bucket, title) {
  balance <- bucket %>%
    group_by(balance_mean_distance_from_center) %>%
    summarise(n = n()) 
  
  s <- ggplot(balance, aes(x = balance_mean_distance_from_center))
  s<- s + ylab("Frequency") +  ggtitle(title) + geom_histogram(colour = "black", fill = "#FF9999", binwidth = .5)   + theme_classic() 
  return(s)
}