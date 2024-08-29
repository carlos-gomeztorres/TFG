calculate_rank <- function(pais, div, pdiv, año) {
  
  delta <- ifelse(pais == "Alemania", 18, 20)
  alpha <- ifelse(div == 1, 0, 1)
  
  if (pais == "España") {
    gamma <- delta + 22
  } else if (pais == "Inglaterra") {
    gamma <- delta + 24
  } else if (pais == "Alemania") {
    gamma <- delta + 18
  } else if (pais == "Francia") {
    gamma <- delta + 20
  } else if (pais == "Italia") {
    gamma <- delta + ifelse(año < 2018, 22, 20)
  }
  
  pglob <- pdiv + alpha * delta
  RANKNAC <- (1 - (pglob - 1)/(gamma - 1))*100
  
  return(RANKNAC)
  
}
