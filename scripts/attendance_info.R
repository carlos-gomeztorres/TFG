library(pbapply)
library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
ATT_PATH <- here('./data/processed/Attendance.xlsx')

attendance_info <- function(row) {
  
  #' Esta función sirve para extraer la cifra media de ocupación del estadio de un 
  #' equipo a lo largo de todos los años disponibles en Transfermarkt.
  #' 
  #' Toma 2 inputs, que se usan para construir una url:
  #' - handle: es el "nombre" o id textual del equipo en Transfermarkt
  #' - id: es el id numérico del equipo en Transfermarkt
  #' 
  #' Como resultado, devuelve un dataframe con las cifras de asistencia media
  #' del estadio por temporada.
  
  tryCatch({
    id <- trimws(row['Transfermarkt ID'])
    handle <- trimws(row['Transfermarkt Handle'])
    
    #https://www.transfermarkt.com/real-madrid/besucherzahlenentwicklung/verein/418
    url <- paste0('https://www.transfermarkt.com/', 
                  handle,
                  '/besucherzahlenentwicklung/verein/',
                  id,
                  sep='')
    
    estadio <- read_html(url)
    
    att <- estadio %>%
      html_element('div.grid-view table') %>%
      html_elements('tr td:last-child') %>%
      html_text2() %>%
      gsub(',','',.) %>%
      as.numeric()
    
    season <- estadio %>%
      html_element('div.grid-view table') %>%
      html_elements('tr td:first-child') %>%
      html_text2()
    
    df <- data.frame(Handle = handle, Temporada = season, Asistencia = att)
    
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
    Handle = character(),
    Temporada = character(),
    Asistencia = numeric()
  )
}

Equipos <- import(here('./data/aux/Equipos.xlsx'))

df <- Equipos %>%
  anti_join(Attendance, by = c("Transfermarkt Handle" = "Handle"))

num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(df), 
                    function(i) attendance_info(df[i, ]), 
                    mc.cores = num_cores)

newrows <- do.call(rbind, df_list) %>% filter(!is.na(Handle))

Attendance <- rbind(Attendance, newrows)
export(Attendance, ATT_PATH, rowNames = F)