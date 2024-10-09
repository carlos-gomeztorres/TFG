calculate_rank <- function(pdiv, div, country, year, console = F) {
  
  
  alpha <- Ranking %>%
    filter(DIVISION == 1, YEAR == year, COUNTRY == country) %>%
    summarise(alpha = max(POS)) %>%
    pull(alpha)
  
  beta <- Ranking %>%
    filter(DIVISION == 2, YEAR == year, COUNTRY == country) %>%
    summarise(beta = max(POS)) %>%
    pull(beta)
  
  gamma <- Ranking %>%
    filter(DIVISION == 3, YEAR == year, COUNTRY == country) %>%
    summarise(gamma = max(POS)) %>%
    pull(gamma)
  
  pglob <- pdiv + (div %in% c(2,3))* alpha + (div==3)*beta
  
  if(console) {
    print(paste(country,"-",year))
    print(paste("Nº de equipos 1ª división:", alpha))
    print(paste("Nº de equipos 2ª división:", beta))
    print(paste("Nº de equipos 3ª división:", gamma))
    print("")
    print(paste("División del equipo:",div))
    print(paste("Posición del equipo en su división:", pdiv))
    print(paste("Posición global del equipo:", pglob))
  }
  
  RANKNAC <- (1 - (pglob - 1)/(alpha+beta+gamma - 1))*100
  
  return(RANKNAC)
  
}
