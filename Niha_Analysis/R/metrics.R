# metrics <- function(bucket_device, test_metric){
#   a <- c(nrow(bucket_device), mean(bucket_device[[test_metric]]),
#          sd(bucket_device[[test_metric]]))
#   return(a)
# }
# 
# device_age_bucket <- function(device, age_bucket, col_name) {
#   bucket <- device %>% filter(age %in% age_bucket)
#   metrics <- metrics(bucket, col_name)
#   return(metrics)
# }
# 
# metrics_matrices <- function(device, col_name) {
#   
#   m <- c(device_age_bucket(device, "10-13", col_name),
#                       device_age_bucket(device, "14:18", col_name), 
#                       device_age_bucket(device,  "19:35", col_name),
#                       device_age_bucket(device,  "36:50", col_name),
#                       device_age_bucket(device,  "51:65", col_name),
#                       device_age_bucket(device,  "66:120", col_name))
#   
#   A= matrix(m, nrow = 6, ncol = 3, byrow = TRUE)
#   dimnames(A) = list( c("10-13", "14-18", "19-35", "36-50", "51-65", "66+"), c("N", "Mean", "SD"))
# return(A)



device_metrics <- function(df){
  m <- c()
}
