nameTab <- function(titulo, suffix = "", step = T) {
  
  nTab <<- nTab + step  # Incrementa el contador
  nomTab <- paste0("Tabla ", nTab, suffix ,": ", titulo)  # Genera el nombre
  
  return(nomTab)  # Devuelve la lista actualizada
}
