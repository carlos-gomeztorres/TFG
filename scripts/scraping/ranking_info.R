library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
library(stringr)
RNK_PATH <- here('./data/scraped/Ranking.xlsx')
source(here('./scripts/calculate_rank.R'))

ranking_info <- function(row) {
  
  id <- trimws(row[['TRANSFERMARKT_ID']])
  handle <- trimws(row[['TRANSFERMARKT_HANDLE']])
  from <- row[['FROM']]
  to <- row[['TO']]
  div <- row[['DIVISION']]
  country <- row[['COUNTRY']]
  
  ranking <- data.frame(
    POS = numeric(),
    TRANSFERMARKT_HANDLE = character(),
    G = numeric(),
    E = numeric(),
    P = numeric(),
    NET_GLS = numeric(),
    PTS = numeric(),
    DIVISION = numeric(),
    YEAR = numeric(),
    PAIS = numeric()
  )
  
  for (year in from:to) {
    
    url <- paste0('https://www.transfermarkt.com/',
                  handle,
                  '/tabelle/wettbewerb/',
                  id,
                  '/saison_id/',
                  year,
                  sep = '')
    
    wp <- read_html(url)
    
    table <- wp %>%
      html_element('div.responsive-table') %>%
      html_table()
    
    team_handles <- wp %>%
      html_element('div.responsive-table') %>%
      html_elements('td.no-border-links a:first-child') %>%
      html_attr("href") %>%
      str_extract("(?<=/)[^/]+")
    
    table[,c(2,4,8)] <- NULL
    
    names(table) <- c("POS","TEAM","W","D","L","NET_GLS","PTS")
    
    table$TRANSFERMARKT_HANDLE <- team_handles
    
    print(names(table))
    
    table <- table %>%
      mutate(DIVISION = div,
             YEAR = year,
             COUNTRY = country)

    
    ranking <- rbind(ranking, table)
    
  }
  
  return(ranking)
}

leagues <- import(here('./data/aux/Leagues.xlsx'))

num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(leagues), 
                    function(i) ranking_info(leagues[i,]), 
                    mc.cores = num_cores)

Ranking <- do.call(rbind, df_list)

Ranking <- Ranking %>%
  mutate(RANKNAC = calculate_rank(POS,DIVISION,COUNTRY,YEAR))
  
export(Ranking, RNK_PATH,rowNames = F)

