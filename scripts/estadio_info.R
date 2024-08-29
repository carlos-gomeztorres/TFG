library(pbapply)
library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
EST_PATH <- here('./data/raw/Estadio.xlsx')

estadio_info <- function(row) {
  
  #' Esta función sirve para extraer la cifra de capacidad máxima y año de construcción
  #' del estadio - o estadios, si han cambiado en el tiempo - de un equipo a lo largo de
  #' todos los años disponibles en Transfermarkt.
  #' 
  #' Toma 2 inputs, que se usan para construir una url:
  #' - handle: es el "nombre" o id textual del equipo en Transfermarkt
  #' - id: es el id numérico del equipo en Transfermarkt
  #' 
  #' Como resultado, devuelve un dataframe con las cifras de capacidad máxima del 
  #' estadio por temporada.
    
  tryCatch({
    id <- trimws(row['TRANSFERMARKT_ID'])
    handle <- trimws(row['TRANSFERMARKT_HANDLE'])
    
    url <- paste0('https://www.transfermarkt.com/', 
                  handle,
                  '/stadion/verein/',
                  id)
    
    estadio <- read_html(url)
    
    # Revisamos lista de estadios disponibles para un equipo
    opts <- estadio %>% html_element("table.auflistung")
    
    # Si no hay lista, significa que hay una sola opción -> un solo estadio, y 
    # nos encontramos ya en la página con su información
    if(is.na(opts)) {
      
      capacidad_total <- estadio %>%
        html_elements('tr') %>%
        .[grep("Total capacity",.)] %>%
        html_element('td') %>%
        html_text2() %>%
        gsub("\\.", "",.) %>% 
        as.numeric() 
      
      construccion_estadio <- estadio %>%
        html_elements('tr') %>%
        .[grep("Built",.)] %>%
        html_element('td') %>%
        html_text2() %>%
        as.numeric()
      
      df <- data.frame(TRANSFERMARKT_HANDLE = handle,
                       CONSTREST = construccion_estadio,
                       CAPACIDAD = capacidad_total,
                       FIN = NA)
      
      return(df)
    
    # Si existe una lista de opciones, entonces hay info de más de un estadio
    } else {
      
      df <- data.frame(TRANSFERMARKT_HANDLE = character(),
                       CONSTREST = numeric(), 
                       CAPACIDAD = numeric(),
                       FIN = numeric())
      
      # Extraemos la lista de los ids de los estadios, que nos permite 
      # construir la url a su info en concreto.
      id_estadio <- estadio %>%
        html_element("table.auflistung") %>%
        html_elements("option") %>%
        html_attr("value")
      
      # Iteramos por la lista de estadios.
      for (ide in id_estadio) {
        
        url <- paste0('https://www.transfermarkt.com/', 
                      handle,
                      '/stadion/verein/',
                      id,
                      '/stadion_id/',
                      ide)
        
        estadio <- read_html(url)
        
        capacidad_total <- estadio %>%
          html_elements('tr') %>%
          .[grep("Total capacity",.)] %>%
          html_element('td') %>%
          html_text2() %>%
          gsub("\\.", "",.) %>% 
          as.numeric() 
        
        construccion_estadio <- estadio %>%
          html_elements('tr') %>%
          .[grep("Built",.)] %>%
          html_element('td') %>%
          html_text2() %>%
          as.numeric()
        
        # Guardamos únicamente de estadios que disponen de información del año de 
        # construcción y capacidad total.
        if (length(c(construccion_estadio,capacidad_total)) == 2) {
          X <- data.frame(TRANSFERMARKT_HANDLE = handle, 
                          CONSTREST = construccion_estadio,
                          CAPACIDAD = capacidad_total,
                          FIN = NA)
          
          df <- rbind(df, X)
        }
      }
      
      return(df)
    }
  },
  
  error = function(e) {
    # Handle the error
    message("Error en estadio_info: ", e$message)
    message("Row: ", row)
    return(NULL)
  })
}

if (file.exists(EST_PATH)) {
  Estadio <- import(EST_PATH)
} else {
  Estadio <- data.frame(
    TRANSFERMARKT_HANDLE = character(),
    CONSTREST = numeric(),
    CAPACIDAD = numeric(),
    FIN = numeric()
  )
}

Equipos <- import(here('./data/aux/Equipos.xlsx'))

df <- Equipos %>%
  anti_join(Estadio, by = "TRANSFERMARKT_HANDLE")

num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(df), 
                    function(i) estadio_info(df[i, ]), 
                    mc.cores = num_cores)

newrows <- do.call(rbind, df_list) %>% filter(!is.na(TRANSFERMARKT_HANDLE))
Estadio <- rbind(Estadio, newrows) %>% 
  filter(!is.na(TRANSFERMARKT_HANDLE))

estadios_post_2009 <- Estadio %>%
  filter(CONSTREST >= 2009) %>%
  group_by(TRANSFERMARKT_HANDLE) %>%
  filter(CAPACIDAD == max(CAPACIDAD)) %>%
  mutate(FIN = 2024)

estadios_pre_2009 <- Estadio %>%
  select(-c(FIN)) %>%
  filter(CONSTREST < 2009) %>%
  group_by(TRANSFERMARKT_HANDLE) %>%
  filter(CAPACIDAD == max(CAPACIDAD)) %>%
  left_join(estadios_post_2009 %>% select(TRANSFERMARKT_HANDLE, FIN = CONSTREST), by ="TRANSFERMARKT_HANDLE") %>%
  mutate(FIN = ifelse(is.na(FIN), 2024, FIN))

Estadio <- rbind(estadios_pre_2009, estadios_post_2009) %>%
  mutate(CAPACIDAD = as.numeric(gsub("\\.", "",CAPACIDAD)))

export(Estadio, EST_PATH,rowNames = F)
