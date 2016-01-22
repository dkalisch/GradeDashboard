library(xlsx) # For reading Excel files
library(dplyr) # For data handling
library(ggplot2) # For data visualization
library(reshape2)
library(grid)

data.source <- list.files(path = "data",
                          pattern = "^[a-z]+",
                          full.names = TRUE,
                          recursive = FALSE,
                          ignore.case = TRUE)

courses <- c("",gsub(".xlsx", "", gsub("^data/", "", data.source)))
