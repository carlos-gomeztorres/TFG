library(pbapply)
library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
library(stringr)
RNK_PATH <- here('./data/raw/Ranking.xlsx')
ranking_info <- function(row) {
  
  id <- trimws(row[['id']])
  handle <- trimws(row[['handle']])
  inicio <- row[['Inicio']]
  fin <- row[['Fin']]
  div <- row[['División']]
  pais <- row[['País']]
  
  ranking <- data.frame(
    POSICION = numeric(),
    TRANSFERMARKT_HANDLE = character(),
    G = numeric(),
    E = numeric(),
    P = numeric(),
    NET_GLS = numeric(),
    PTS = numeric(),
    DIV = numeric(),
    AÑO = numeric(),
    PAIS = numeric()
  )
  
  for (año in inicio:fin) {
    
    url <- paste0('https://www.transfermarkt.com/',
                  handle,
                  '/tabelle/wettbewerb/',
                  id,
                  '/saison_id/',
                  año,
                  sep = '')
    
    wp <- read_html(url)
    
    table <- wp %>%
      html_element('div.responsive-table') %>%
      html_table()
    
    handles_equipos <- wp %>%
      html_element('div.responsive-table') %>%
      html_elements('td.no-border-links a:first-child') %>%
      html_attr("href") %>%
      str_extract("(?<=/)[^/]+")
    
    table[,c(2,4,8)] <- NULL
    
    names(table) <- c("Posicion","Equipo","G","E","P","neto_goles","pts")
    
    table$TRANSFERMARKT_HANDLE <- handles_equipos
    
    table <- table %>%
      mutate(DIV = div,
             AÑO = año,
             PAIS = pais) %>%
      rename(POSIC = Posicion,
             PTS = pts,
             NET_GLS = neto_goles)
    
    ranking <- rbind(ranking, table)
    
  }
  
  return(ranking)
}

competencias <- import(here('./data/aux/Competencias.xlsx'))

num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(competencias), 
                    function(i) ranking_info(competencias[i,]), 
                    mc.cores = num_cores)

Ranking <- do.call(rbind, df_list) 

export(Ranking, RNK_PATH,rowNames = F)
