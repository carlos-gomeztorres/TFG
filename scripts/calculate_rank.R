calculate_rank <- function(pdiv, div, pais, año, console = F) {
  
  
  alpha <- Ranking %>%
    filter(DIV == 1, AÑO == año, PAIS == pais) %>%
    summarise(alpha = max(POSIC)) %>%
    pull(alpha)
  
  beta <- Ranking %>%
    filter(DIV == 2, AÑO == año, PAIS == pais) %>%
    summarise(beta = max(POSIC)) %>%
    pull(beta)
  
  gamma <- Ranking %>%
    filter(DIV == 3, AÑO == año, PAIS == pais) %>%
    summarise(gamma = max(POSIC)) %>%
    pull(gamma)
  
  pglob <- pdiv + (div %in% c(2,3))* alpha + (div==3)*beta
  
  if(console) {
    print(paste(pais,"-",año))
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
