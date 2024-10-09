nameAnx <- function(titulo, suffix = "", step = T) {
  
  nAnx <<- nAnx + step  # Incrementa el contador
  nomAnx <- paste0("Anexo ", as.roman(nAnx), suffix ,": ", titulo)  # Genera el nombre
  
  return(nomAnx)  # Devuelve la lista actualizada
}
