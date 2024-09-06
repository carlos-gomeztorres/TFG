anova_tests <- function(df, variable, factor = "cluster", pct = F) {
  
  formula <- as.formula(paste(variable, "~", factor))
  anova_result <- aov(formula, data = df)
  
  tukey_result <- TukeyHSD(anova_result, ordered = TRUE)
  
  scheffe_result <- scheffe.test(anova_result, factor)$groups
  
  if (pct == T) {
    scheffe_result[,1] <- scheffe_result[,1] * 100
  }
  
  scheffe_result[,1] <- as.character(round(scheffe_result[,1],2))
  scheffe_result[,1] <- sub(".",
                            ",",
                            fixed = T,
                            scheffe_result[,1])
  
  scheffe_result <- as.data.frame(scheffe_result) %>%
    mutate(CLUSTER = rownames(.)) %>%
    rename(GRUPO = groups)
  
  rownames(scheffe_result) <- NULL
  
  return(list(ANOVA = summary(anova_result),
              TukeyHSD = tukey_result,
              Scheffe = scheffe_result))
}
