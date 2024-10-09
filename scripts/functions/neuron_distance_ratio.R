neuron_distance_ratio <- function(neuron, cluster) {
  
  d <- distance_matrix[neuron, Deals$neuron[Deals$cluster == cluster]]
  
  w <- 1 / (d + 1e-6)
  
  r <- Deals$RATIO[Deals$cluster == cluster]
  
  ratio <- sum(w * r)/sum(w)
  
  return(ratio)
  
}
