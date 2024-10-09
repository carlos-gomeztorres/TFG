winsorize <- function(x, prob = 0.01) {
  lower_bound <- quantile(x, prob, na.rm = TRUE)
  upper_bound <- quantile(x, 1 - prob, na.rm = TRUE)
  x <- ifelse(x < lower_bound, lower_bound, x)
  x <- ifelse(x > upper_bound, upper_bound, x)
  return(x)
}
