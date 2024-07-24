library(pbapply)
library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
EST_PATH <- here('./data/processed/Estadio.xlsx')

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
    id <- trimws(row['Transfermarkt ID'])
    handle <- trimws(row['Transfermarkt Handle'])
    
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
      
      df <- data.frame(Handle = handle,
                       Construccion = construccion_estadio,
                       Capacidad = capacidad_total,
                       Fin = NA)
      
      return(df)
    
    # Si existe una lista de opciones, entonces hay info de más de un estadio
    } else {
      
      df <- data.frame(Handle = character(),
                       Construccion = numeric(), 
                       Capacidad = numeric(),
                       Fin = numeric())
      
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
          X <- data.frame(Handle = handle, 
                          Construccion = construccion_estadio,
                          Capacidad = capacidad_total,
                          Fin = NA)
          
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
    Handle = character(),
    Construccion = numeric(),
    Capacidad = numeric(),
    Fin = numeric()
  )
}

Equipos <- import(here('./data/aux/Equipos.xlsx'))

df <- Equipos %>%
  anti_join(Estadio, by = c("Transfermarkt Handle" = "Handle"))

num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(df), 
                    function(i) estadio_info(df[i, ]), 
                    mc.cores = num_cores)

newrows <- do.call(rbind, df_list) %>% filter(!is.na(Handle))
Estadio <- rbind(Estadio, newrows) %>% 
  filter(!is.na(Handle))

estadios_post_2009 <- Estadio %>%
  filter(Construccion >= 2009) %>%
  group_by(Handle) %>%
  filter(Capacidad == max(Capacidad)) %>%
  mutate(Fin = 2024)

estadios_pre_2009 <- Estadio %>%
  select(-c(Fin)) %>%
  filter(Construccion < 2009) %>%
  group_by(Handle) %>%
  filter(Construccion == max(Construccion), 
         Capacidad == max(Capacidad)) %>%
  left_join(estadios_post_2009 %>% select(Handle, Fin = Construccion), by ="Handle") %>%
  mutate(Fin = ifelse(is.na(Fin), 2024, Fin))

Estadio <- rbind(estadios_pre_2009, estadios_post_2009) %>%
  mutate(Capacidad = as.numeric(gsub("\\.", "",Capacidad)))

export(Estadio, EST_PATH,rowNames = F)