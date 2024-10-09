library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)

TRANSF_PATH <- here('./data/scraped/Transfers.xlsx')

transfers_info <- function(row) {
  
  tryCatch({
    id <- trimws(row['TRANSFERMARKT_ID'])
    handle <- trimws(row['TRANSFERMARKT_HANDLE'])
    year <- trimws(row['YEAR'])
    
    url <- paste0('https://www.transfermarkt.com/', 
                  handle,
                  '/startseite/verein/',
                  id,
                  '/saison_id/',
                  year,
                  sep='')
    
    wp_team <- read_html(url)
    
    # Valor de mercado plantilla
    market_value <- wp_team %>%
      html_element('table.items') %>%
      html_elements('tr td.rechts') %>%
      html_text2() %>%
      gsub('€','',.) %>%
      gsub("k", "e3",.) %>%
      gsub("m", "e6",.) %>%
      as.numeric() %>%
      sum(.,na.rm = T)/1e6
    
    # Ingresos de transferencias
    transfers_in <- wp_team %>%
      html_element('div.transfer-record table tbody') %>%
      html_element('tr.transfer-record__revenue td.transfer-record__total') %>%
      html_text2() %>%
      gsub('€','',.) %>%
      gsub("k", "e3",.) %>%
      gsub("m", "e6",.) %>%
      as.numeric() %>%
      sum(.,na.rm = T)/1e6
    
    # Gastos de transferencias
    transfers_out <- wp_team %>%
      html_element('div.transfer-record table tbody') %>%
      html_element('tr.transfer-record__expenses td.transfer-record__total') %>%
      html_text2() %>%
      gsub('€','',.) %>%
      gsub("k", "e3",.) %>%
      gsub("m", "e6",.) %>%
      as.numeric() %>%
      sum(.,na.rm = T)/1e6
    
    # Resultado neto
    transfers_net <- transfers_in - transfers_out
    
    df <- data.frame(TRANSFERMARKT_HANDLE = handle,
                     YEAR = year,
                     MV = market_value,
                     DEPARTURES = transfers_in,
                     SIGNED = transfers_out,
                     NET_TRANSFERS = transfers_net)
    
    return(df)
  },
  
  error = function(e) {
    # Handle the error
    message("Error en transfers_info: ", e$message)
    message("Row: ", row)
    return(NULL)
  })
  
}

if (file.exists(TRANSF_PATH)) {
  Transfers <- import(TRANSF_PATH)
} else {
  Transfers <- data.frame(
    TRANSFERMARKT_HANDLE = character(),
    YEAR = numeric(),
    MV = numeric(),
    DEPARTURES = numeric(),
    SIGNED = numeric(),
    NET_TRANSFERS = numeric()
  )
}

Teams <- import(here('./data/aux/Teams.xlsx'))
YRS_SEASONS <- data.frame(YEAR = 2009:2023,
                          SEASON = c("09/10","10/11","11/12",
                                     "12/13","13/14","14/15","15/16",
                                     "16/17","17/18","18/19","19/20",
                                     "20/21","21/22","22/23","23/24"))

df <- merge(Teams, YRS_SEASONS) %>%
  anti_join(Transfers, by = c("TRANSFERMARKT_HANDLE","YEAR"))


num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(df), 
                    function(i) transfers_info(df[i, ]), 
                    mc.cores = num_cores)

newrows <- do.call(rbind, df_list) %>% filter(!is.na(TRANSFERMARKT_HANDLE))
Transfers <- rbind(Transfers, newrows)

Transfers$YEAR <- as.numeric(Transfers$YEAR)
export(Transfers, TRANSF_PATH, rowNames = F)
