library(here)
library(rio)
library(parallel)
library(rvest)
library(dplyr)
EST_PATH <- here('./data/scraped/Stadiums.xlsx')

stadium_info <- function(row) {
    
  tryCatch({
    team_id <- trimws(row['TRANSFERMARKT_ID'])
    handle <- trimws(row['TRANSFERMARKT_HANDLE'])
    
    url <- paste0('https://www.transfermarkt.com/', 
                  handle,
                  '/stadion/verein/',
                  team_id)
    
    stadium <- read_html(url)
    
    # Revisamos lista de Stadiums disponibles para un equipo
    opts <- stadium %>% html_element("table.auflistung")
    
    # Si no hay lista, significa que hay una sola opción -> un solo Stadium, y 
    # nos encontramos ya en la página con su información
    if(is.na(opts)) {
      
      total_capacity <- stadium %>%
        html_elements('tr') %>%
        .[grep("Total capacity",.)] %>%
        html_element('td') %>%
        html_text2() %>%
        gsub("\\.", "",.) %>% 
        as.numeric() 
      
      stadium_construction <- stadium %>%
        html_elements('tr') %>%
        .[grep("Built",.)] %>%
        html_element('td') %>%
        html_text2() %>%
        as.numeric()
      
      df <- data.frame(TRANSFERMARKT_HANDLE = handle,
                       CONSTRUCTED = stadium_construction,
                       CAPACITY = total_capacity,
                       END = NA)
      
      return(df)
    
    # Si existe una lista de opciones, entonces hay info de más de un Stadium
    } else {
      
      df <- data.frame(TRANSFERMARKT_HANDLE = character(),
                       CONSTRUCTED = numeric(), 
                       CAPACITY = numeric(),
                       END = numeric())
      
      # Extraemos la lista de los ids de los Stadiums, que nos permite 
      # construir la url a su info en concreto.
      ids <- stadium %>%
        html_element("table.auflistung") %>%
        html_elements("option") %>%
        html_attr("value")
      
      # Iteramos por la lista de Stadiums.
      for (stadium_id in ids) {
        
        url <- paste0('https://www.transfermarkt.com/', 
                      handle,
                      '/stadion/verein/',
                      team_id,
                      '/stadion_id/',
                      stadium_id)
        
        stadium <- read_html(url)
        
        total_capacity <- stadium %>%
          html_elements('tr') %>%
          .[grep("Total capacity",.)] %>%
          html_element('td') %>%
          html_text2() %>%
          gsub("\\.", "",.) %>% 
          as.numeric() 
        
        stadium_construction <- stadium %>%
          html_elements('tr') %>%
          .[grep("Built",.)] %>%
          html_element('td') %>%
          html_text2() %>%
          as.numeric()
        
        # Guardamos únicamente de Stadiums que disponen de información del año de 
        # construcción y capacidad total.
        if (length(c(stadium_construction,total_capacity)) == 2) {
          X <- data.frame(TRANSFERMARKT_HANDLE = handle, 
                          CONSTRUCTED = stadium_construction,
                          CAPACITY = total_capacity,
                          END = NA)
          
          df <- rbind(df, X)
        }
      }
      
      return(df)
    }
  },
  
  error = function(e) {
    # Handle the error
    message("Error en stadium_info: ", e$message)
    message("Row: ", row)
    return(NULL)
  })
}

if (file.exists(EST_PATH)) {
  
  Stadiums <- import(EST_PATH)
  
} else {
  
  Stadiums <- data.frame(
    TRANSFERMARKT_HANDLE = character(),
    CONSTRUCTED = numeric(),
    CAPACITY = numeric(),
    END = numeric()
  )
  
}

Teams <- import(here('./data/aux/Teams.xlsx'))

df <- Teams %>%
  anti_join(Stadiums, by = "TRANSFERMARKT_HANDLE")

num_cores <- detectCores() - 1

df_list <- mclapply(1:nrow(df), 
                    function(i) stadium_info(df[i, ]), 
                    mc.cores = num_cores)

newrows <- do.call(rbind, df_list) %>% filter(!is.na(TRANSFERMARKT_HANDLE))
Stadiums <- rbind(Stadiums, newrows) %>% 
  filter(!is.na(TRANSFERMARKT_HANDLE))

stadiums_post_2009 <- Stadiums %>%
  filter(CONSTRUCTED >= 2009) %>%
  group_by(TRANSFERMARKT_HANDLE) %>%
  filter(CAPACITY == max(CAPACITY)) %>%
  mutate(END = 2024)

stadiums_pre_2009 <- Stadiums %>%
  select(-c(END)) %>%
  filter(CONSTRUCTED < 2009) %>%
  group_by(TRANSFERMARKT_HANDLE) %>%
  filter(CAPACITY == max(CAPACITY)) %>%
  left_join(stadiums_post_2009 %>% select(TRANSFERMARKT_HANDLE, END = CONSTRUCTED), by ="TRANSFERMARKT_HANDLE") %>%
  mutate(END = ifelse(is.na(END), 2024, END))

Stadiums <- rbind(stadiums_pre_2009, stadiums_post_2009) %>%
  mutate(CAPACITY = as.numeric(gsub("\\.", "",CAPACITY)))

export(Stadiums, EST_PATH,rowNames = F)