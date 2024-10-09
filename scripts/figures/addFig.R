nameFig <- function(titulo, suffix = "", step = T) {
  
  nFig <<- nFig + step  # Incrementa el contador
  nomFig <- paste0("Figura ", nFig, suffix ,": ", titulo)  # Genera el nombre

  return(nomFig)  # Devuelve la lista actualizada
}
