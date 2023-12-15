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


# missing value analysis
library(redav)
industry_df <- read.csv('./data/industry.csv')
plot_missing(industry_df)





# plot analysis


suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyverse)
  library(gridExtra)
  library(plotly)
  library(janitor)
})

# Specify the folder path
folder_path <- "./data/"

folder_path_other <- './data_other/'


# Read CSV files with full path
hires <- read.csv(paste0(folder_path, "Hires.csv"))
layoffs_discharges <- read.csv(paste0(folder_path, "LayoffsDischarges.csv"))
industry <- read.csv(paste0(folder_path, "industry.csv"))
unemployed_per_job_opening_ratio <- read.csv(paste0(folder_path, "UnemployedPerJobOpeningRatio.csv"))
total_separations <- read.csv(paste0(folder_path, "TotalSeperations.csv"))
quits <- read.csv(paste0(folder_path, "Quits.csv"))
job_openings <- read.csv(paste0(folder_path, "JobOpenings.csv"))
series <- read.csv(paste0(folder_path, "series.csv"))

all_item <- read.csv(paste0(folder_path_other, "AllItems.csv"))
dataelement <- read.csv(paste0(folder_path_other, "dataelement.csv"))
sizeclass <- read.csv(paste0(folder_path_other, "sizeclass.csv"))
state <- read.csv(paste0(folder_path_other, "state.csv"))


all_item <- all_item %>%
  mutate(
    value = as.numeric(value),
    series_id = str_trim(series_id),
    date = as.Date(paste(substr(period,2,3),"01",year,sep="/"),"%m/%d/%Y")
  )

series<-series %>%
  clean_names %>%
  mutate_all(str_trim)

dataelement<-dataelement %>%
  clean_names %>%
  mutate_all(str_trim)

sizeclass<-sizeclass %>%
  clean_names %>%
  mutate_all(str_trim)

industry<-industry %>%
  clean_names %>%
  mutate_all(str_trim)

state<-state %>%
  clean_names %>%
  mutate_all(str_trim)

jolts <- all_item %>%
  inner_join(series, by = c("series_id")) %>%
  inner_join(dataelement, by = c("dataelement_code"),suffix = c(".series", ".data_element")) %>%
  inner_join(industry, by = c("industry_code"),suffix = c(".x", ".industry_code")) %>%
  inner_join(sizeclass, by = "sizeclass_code") %>%
  inner_join(state, by="state_code")

# write.csv(jolts, "combined_jolts.csv", row.names = FALSE)

# a <- jolts %>%
#   filter(period != "M13", seasonal == "S", ratelevel_code == "L") %>%
#   filter(display_level.industry_code == 2) %>%
#   filter(dataelement_text %in% c("Job openings", "Hires")) %>%
#   group_by(industry_text, dataelement_text, year = lubridate::year(date)) %>%
#   summarise(mean_value = mean(value, na.rm = TRUE)) %>%
#   pivot_wider(names_from = dataelement_text, values_from = mean_value)
#
#
# write.csv(a, "hires_openings_jolts.csv", row.names = FALSE)


jolts <- jolts %>%
  mutate(
    industry_text = case_when(
      industry_text == "Professional and business services" ~ "Business services",
      industry_text == "Education and health services" ~ "Education & health",
      industry_text == "Leisure and hospitality" ~ "Leisure & hospitality",
      TRUE ~ industry_text
    )
  )



a <- jolts %>%
  filter(period != "M13", seasonal == "S", ratelevel_code == "L") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text %in% c("Job openings", "Hires")) %>%
  group_by(industry_text, dataelement_text, year = lubridate::year(date)) %>%
  summarise(mean_value = mean(value, na.rm = TRUE)) %>%
  pivot_wider(names_from = dataelement_text, values_from = mean_value)jolts %>% filter(period != "M13", seasonal == "S", ratelevel_code == "L") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text != "Layoffs and discharges", dataelement_text != "Other separations") %>%
  filter(date == max(date)) %>%
  ggplot(aes(industry_text, value)) + geom_bar(stat="identity") + facet_wrap(~ dataelement_text) +
  coord_flip()

a <- jolts %>% filter(period != "M13", seasonal == "S", ratelevel_code == "R") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text == "Quits" | dataelement_text == "Job openings") %>%
  filter(year == 2019 | year == 2022) %>%
  pivot_wider(id_cols = c("date","industry_text"), names_from = dataelement_text, values_from = value) %>%
  mutate(year = factor(year(date)))

ggplot(a, aes(Quits, `Job openings`, color = year)) + geom_point() + theme_classic() + facet_wrap(~ industry_text)




a <- jolts %>%
  filter(period != "M13", seasonal == "S", ratelevel_code == "L") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text == "Job openings") %>%
  group_by(industry_text, year = lubridate::year(date)) %>%
  summarise(mean_job_openings = mean(value, na.rm = TRUE))

plot2 <- ggplot(a, aes(x = year, y = mean_job_openings)) +
  geom_line() +
  geom_point() +
  facet_wrap(~ industry_text) +
  labs(title = "Mean Job Openings per Year", x = "Year", y = "Mean Job Openings")

plot2


# Mean Job Openings and Hires per Year
a <- jolts %>%
  filter(period != "M13", seasonal == "S", ratelevel_code == "L") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text %in% c("Job openings", "Hires")) %>%
  group_by(industry_text, dataelement_text, year = lubridate::year(date)) %>%
  summarise(mean_value = mean(value, na.rm = TRUE)) %>%
  pivot_wider(names_from = dataelement_text, values_from = mean_value)

plot2 <- ggplot(a, aes(x = year)) +
  geom_line(aes(y = `Job openings`, color = "Job Openings")) +
  geom_point(aes(y = `Job openings`, color = "Job Openings")) +
  geom_line(aes(y = Hires, color = "Hires")) +
  geom_point(aes(y = Hires, color = "Hires")) +
  facet_wrap(~ industry_text) +
  labs(title = "Mean Job Openings and Hires per Year", x = "Year", y = "Mean Value", color = "Metric")

plotly1 <- ggplotly(plot2)
plotly1





# Overall current market analysis
jolts_filtered <- jolts %>%
  filter(period != "M13", seasonal == "S", ratelevel_code == "L") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text != "Layoffs and discharges", dataelement_text != "Other separations") %>%
  filter(date == max(date))

plot1 <- jolts_filtered %>%
  ggplot(aes(industry_text, value)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  facet_wrap(~ dataelement_text) +
  labs(title = "Industry Data (Current 2023 Market)", x = "Industry", y = "Value")

plotly1 <- ggplotly(plot1)
plotly1











# Job openings vs Hires

a <- jolts %>%
  filter(period != "M13", seasonal == "S", ratelevel_code == "R") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text == "Hires" | dataelement_text == "Job openings") %>%
  filter(year> 2021) %>%
  pivot_wider(id_cols = c("date","industry_text"), names_from = dataelement_text, values_from = value) %>%
  mutate(year = factor(year(date)))

plot2 <- ggplot(a, aes(Hires, `Job openings`, color = year)) +
  geom_point() +
  theme_classic() +
  facet_wrap(~ industry_text) +
  labs(title = "Job Openings vs Hires", x = "Hires", y = "Job Openings")

plotly2 <- ggplotly(plot2)
plotly2



# Reasons for leaving
a <- jolts %>%
  filter(period != "M13", seasonal == "S", ratelevel_code == "R") %>%
  filter(display_level.industry_code == 2) %>%
  filter(dataelement_text == "Quits" | dataelement_text == "Layoffs and discharges") %>%
  filter(year == 2019 | year == 2022) %>%
  pivot_wider(id_cols = c("date","industry_text"), names_from = dataelement_text, values_from = value) %>%
  mutate(year = factor(year(date)))

plot2 <- ggplot(a, aes(Quits, `Layoffs and discharges`, color = year)) +
  geom_point() +
  theme_classic() +
  facet_wrap(~ industry_text) +
  labs(title = "Layoffs and discharges vs Quits", x = "Quits", y = "Layoffs and discharges")

plotly2 <- ggplotly(plot2)
plotly2



