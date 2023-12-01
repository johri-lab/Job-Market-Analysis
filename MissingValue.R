library(tidyverse)

folder_path <- "C:\\Users\\A-Team\\Documents\\MSDS\\EDAV\\Assignments\\final project\\final data"

csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

for (file in csv_files) {
  data <- read.csv(file)

  csv_file_name <- strsplit(file, "/")[[1]][2]

  missing_summary <- data %>%
    summarise_all(~ mean(is.na(.)) * 100) %>%
    gather(key = "variable", value = "missing_percentage") %>%
    arrange(desc(missing_percentage))

  print(csv_file_name)
  print(missing_summary)

  missing_value_graph <- ggplot(missing_summary, aes(x = reorder(variable, -missing_percentage), y = missing_percentage)) +
    geom_bar(stat = "identity", fill = "skyblue") +
    geom_text(data = subset(missing_summary, missing_percentage != 0),
              aes(label = round(missing_percentage, 1)), vjust = -0.5, size = 3) +
    labs(title = paste("Missing Value Summary (", csv_file_name,")"),
         x = "Variables",
         y = "missing Values (%)")+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

  print(missing_value_graph )
}
