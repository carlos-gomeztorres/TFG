neuron_distance_ratio <- function(neuron, cluster) {
  
  d <- distance_matrix[neuron, ratios$neuron[ratios$cluster == cluster]]
  
  w <- 1 / (d + 1e-6)
  
  r <- ratios$RATIO[ratios$cluster == cluster]
  
  ratio <- sum(w * r)/sum(w)
  
  return(ratio)
  
}
