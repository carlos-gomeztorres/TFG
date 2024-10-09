library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
ATT_PATH <- here('./data/scraped/Attendance.xlsx')

attendance_info <- function(row) {
  
  tryCatch({
    team_id <- trimws(row['TRANSFERMARKT_ID'])
    team_handle <- trimws(row['TRANSFERMARKT_HANDLE'])
    
    #https://www.transfermarkt.com/real-madrid/besucherzahlenentwicklung/verein/418
    url <- paste0('https://www.transfermarkt.com/', 
                  team_handle,
                  '/besucherzahlenentwicklung/verein/',
                  team_id,
                  sep='')
    
    stadium <- read_html(url)
    
    att <- stadium %>%
      html_element('div.grid-view table') %>%
      html_elements('tr td:last-child') %>%
      html_text2() %>%
      gsub(',','',.) %>%
      as.numeric()
    
    season <- stadium %>%
      html_element('div.grid-view table') %>%
      html_elements('tr td:first-child') %>%
      html_text2()
    
    df <- data.frame(TRANSFERMARKT_HANDLE = team_handle, SEASON = season, ATTENDANCE = att)
    
    return(df)
  
  },
  
  error = function(e) {
    # Handle the error
    message("Error en attendance_info: ", e$message)
    message("Row: ", row)
    return(NULL)
  })
  
}

if (file.exists(ATT_PATH)) {
  Attendance <- read_xlsx(ATT_PATH)
} else {
  Attendance <- data.frame(
    TRANSFERMARKT_HANDLE = character(),
    SEASON = character(),
    ATTENDANCE = numeric()
  )
}

Teams <- import(here('./data/aux/Teams.xlsx'))

df <- Teams %>%
  anti_join(Attendance, by = "TRANSFERMARKT_HANDLE")

num_cores <- detectCores() - 1

attendance_info(df[1,])

df_list <- mclapply(1:nrow(df), 
                    function(i) attendance_info(df[i, ]), 
                    mc.cores = num_cores)

newrows <- do.call(rbind, df_list) %>% filter(!is.na(TRANSFERMARKT_HANDLE))

Attendance <- rbind(Attendance, newrows)
export(Attendance, ATT_PATH, rowNames = F)