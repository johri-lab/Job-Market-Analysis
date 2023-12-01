library(tidyverse)

folder_path <- "./data"

csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

for (file in csv_files) {
  data <- read.csv(file)

  csv_file_name <- strsplit(file, "/")[[1]][3]
  # print(csv_file_name)

  missing_summary <- data %>%
    summarise_all(~ mean(is.na(.)) * 100) %>%
    gather(key = "variable", value = "missing_percentage") %>%
    arrange(desc(missing_percentage))

  missing_value_graph <- ggplot(missing_summary, aes(x = reorder(variable, -missing_percentage), y = missing_percentage)) +
    geom_bar(stat = "identity", fill = "skyblue", width=0.5) +
    geom_text(data = subset(missing_summary, missing_percentage != 0),
              aes(label = round(missing_percentage, 1)), vjust = -0.5, size = 3) +
    labs(title = paste("Missing Value Summary (", csv_file_name,")"),
         x = "Variables",
         y = "missing Values (%)")+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))+
    expand_limits(x = 0, y = 110)+
    scale_y_continuous(expand =c(0,0))

  print(missing_value_graph )
}
