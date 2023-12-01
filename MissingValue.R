suppressPackageStartupMessages({
  library(tidyverse)
})

folder_path <- "./data"

csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

all_missing_summary <- list()

for (file in csv_files) {
  data <- read.csv(file)

  csv_file_name <- strsplit(file, "/")[[1]][3]

  missing_summary <- data %>%
    summarise_all(~ mean(is.na(.)) * 100) %>%
    gather(key = "variable", value = "missing_percentage") %>%
    arrange(desc(missing_percentage))

  all_missing_summary[[csv_file_name]] <- missing_summary
}

combined_missing_summary <- bind_rows(all_missing_summary, .id = "csv_file_name")

missing_value_graph <- ggplot(combined_missing_summary, aes(x = reorder(variable, -missing_percentage), y = missing_percentage)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(data = subset(combined_missing_summary, missing_percentage != 0),
            aes(label = round(missing_percentage, 1)), vjust = -0.3, size = 3) +
  labs(title = "Missing Value Summary",
       x = "Variables",
       y = "missing Values (%)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), plot.title=element_text(hjust=0.5)) +
  expand_limits(x = 0, y = 110) +
  scale_y_continuous(expand = c(0, 0)) +
  facet_wrap(~csv_file_name, scales = "free", ncol=2)

print(missing_value_graph)
