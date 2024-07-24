library(pbapply)
library(here)
library(rio)
TRANSF_PATH <- here('./data/processed/Transfers.xlsx')

transfers_info <- function(row) {
  
  #' Esta función sirve para extraer el resultado de la actividad de un equipo
  #' tras finalizar la temporada según Transfermarkt.
  #' 
  #' Toma 3 inputs, que se usan para construir una url:
  #' - handle: es el "nombre" o id textual del equipo en Transfermarkt
  #' - id: es el id numérico del equipo en Transfermarkt
  #' - año: es el año de inicio la temporada que queremos revisar
  #' 
  #' De la url resultante, extrae la siguiente información:
  #' - Valor de mercado de plantilla
  #' - Ingreso por venta de jugadores 
  #' - Gastos por compra de jugadores
  #' - Resultado neto -> Ingresos - Gastos
  #' 
  #' Esta información se devuelve en forma de un dataframe de una sola fila
  
  tryCatch({
    id <- trimws(row['Transfermarkt ID'])
    handle <- trimws(row['Transfermarkt Handle'])
    año <- trimws(row['Año'])
    
    url <- paste0('https://www.transfermarkt.com/', 
                  handle,
                  '/startseite/verein/',
                  id,
                  '/saison_id/',
                  año,
                  sep='')
    
    wp_equipo <- read_html(url)
    
    # Valor de mercado plantilla
    market_value <- wp_equipo %>%
      html_element('table.items') %>%
      html_elements('tr td.rechts') %>%
      html_text2() %>%
      gsub('€','',.) %>%
      gsub("k", "e3",.) %>%
      gsub("m", "e6",.) %>%
      as.numeric() %>%
      sum(.,na.rm = T)/1e6
    
    # Ingresos de transferencias
    transfers_in <- wp_equipo %>%
      html_element('div.transfer-record table tbody') %>%
      html_element('tr.transfer-record__revenue td.transfer-record__total') %>%
      html_text2() %>%
      gsub('€','',.) %>%
      gsub("k", "e3",.) %>%
      gsub("m", "e6",.) %>%
      as.numeric() %>%
      sum(.,na.rm = T)/1e6
    
    # Gastos de transferencias
    transfers_out <- wp_equipo %>%
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
    
    df <- data.frame(Handle = handle,
                     Año = año,
                     MV = market_value,
                     Ventas = transfers_in,
                     Fichajes = transfers_out,
                     Neto = transfers_net)
    
    return(df)
  },
  
  error = function(e) {
    # Handle the error
    message("Error en estadio_info: ", e$message)
    message("Row: ", row)
    return(NULL)
  })
  
}

if (file.exists(TRANSF_PATH)) {
  Transfers <- import(TRANSF_PATH)
} else {
  Transfers <- data.frame(
    Handle = character(),
    Año = numeric(),
    MV = numeric(),
    Ventas = numeric(),
    Fichajes = numeric(),
    Neto = numeric()
  )
}

Equipos <- import(here('./data/aux/Equipos.xlsx'))
temporadas_años <- data.frame(Año = 2009:2022,
                              Temporada = c("09/10","10/11","11/12",
                                            "12/13","13/14","14/15","15/16",
                                            "16/17","17/18","18/19","19/20",
                                            "20/21","21/22","22/23"))

df <- merge(Equipos, temporadas_años) %>%
  anti_join(Transfers, by = c("Transfermarkt Handle" = "Handle","Año" = "Año"))

df_list <- pblapply(1:nrow(df), function(i) transfers_info(df[i, ]))
newrows <- do.call(rbind, df_list) %>% filter(!is.na(Handle))
Transfers <- rbind(Transfers, newrows)
export(Transfers, TRANSF_PATH, row.names = F)