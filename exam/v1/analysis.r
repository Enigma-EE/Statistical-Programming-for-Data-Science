


# clear all variables, functions, etc
# clean up memory
rm(list=ls())
# clean up memory
gc()




pacman::p_load(tidyverse, gglm)
pacman::p_load(knitr,dplyr,AICcmodavg)
pacman::p_load(inspectdf,tidyr,stringr, stringi,DT)
pacman::p_load(caret,modelr)
pacman::p_load(mlbench,mplot)
pacman::p_load(tidymodels,glmx)
pacman::p_load(skimr,vip,yardstick,ranger,kknn,funModeling,Hmisc)
pacman::p_load(ggplot2,ggpubr,ggthemes,gridExtra,scales)
pacman::p_load(viridis,hrbrthemes)
knitr::opts_chunk$set(message = FALSE)

# clean the data


# load the rds file as dataframe
seek_ds <- readRDS("ds_24062023.rds")
# check how many rows and columns in the dataset
dim(seek_ds)
# check duplicates
sum(duplicated(seek_ds))
# check data
tail(seek_ds)



# check how many unique values are in each column
sapply(seek_ds, function(x) length(unique(x)))
# drop the salary_range column
seek_ds <- seek_ds %>% select(-salary_range)

# what are the unique values in column 'state' and 'date_posted'
unique(seek_ds$state)
unique(seek_ds$date_posted)
unique(seek_ds$salary)

# Rename the 'state' column to 'area'
names(seek_ds)[names(seek_ds) == 'state'] <- 'area'

# Function to extract state abbreviations
extract_state <- function(location) {
  # List of state abbreviations
  states <- c("NSW", "QLD", "SA", "ACT", "VIC", "WA", "TAS", "NT")
  
  # Split the location into words
  words <- unlist(strsplit(location, " "))
  
  # Find the state abbreviation in the list of words, if it exists
  state <- intersect(states, words)
  
  # If a state abbreviation was found, return it. Otherwise, return NA.
  if (length(state) > 0) {
    return(state)
  } else {
    return(NA)
  }
}

# Apply the function to the 'area' column to create a new 'state' column
seek_ds$state <- sapply(seek_ds$area, extract_state)

# Check the unique values in the 'state' column
unique(seek_ds$state)


# Extract salary using regular expression. Pattern matches any digit or comma after a $ sign
seek_ds$salary_annual <- str_extract(seek_ds$salary, "\\$[\\d,]+")

# Remove the $ sign and commas from the salary_annual column and convert it to numeric
seek_ds$salary_annual <- as.numeric(gsub("[$,]", "", seek_ds$salary_annual))




# Load necessary libraries
library(lubridate)

# Convert collection date into POSIXct
collection_date <- ymd_hm("2023-06-24 19:35")

# Extract numeric part and time unit (days or hours)
seek_ds <- seek_ds %>%
  mutate(time_num = as.numeric(str_extract(date_posted, "\\d+")),
         time_unit = ifelse(str_detect(date_posted, "d"), "days", "hours"))

# Convert date_posted to actual date
seek_ds <- seek_ds %>%
  mutate(date_posted = ifelse(time_unit == "days", 
                              collection_date - days(time_num), 
                              collection_date - hours(time_num)))

# Remove temporary columns
seek_ds <- seek_ds %>%
  select(-time_num, -time_unit)



# Convert Unix time to date-time format
seek_ds$date_posted <- as.POSIXct(seek_ds$date_posted, origin="1970-01-01", tz = "UTC")


# Create a new column 'weekday' representing the day of the week
seek_ds$weekday <- weekdays(seek_ds$date_posted)
# what are the data types of each column
str(seek_ds)

# View the converted dates
# head(seek_ds)
tail(seek_ds)
# check how many rows and columns in the dataset
dim(seek_ds)


# Check the number of missing values in each column
summary_df <- seek_ds %>%
  summarise(salary_median = median(salary_annual, na.rm = TRUE),
            salary_sd = sd(salary_annual, na.rm = TRUE),
            salary_max = max(salary_annual, na.rm = TRUE),
            n_missing = sum(is.na(salary_annual))) %>%
  mutate_at(vars(starts_with("salary_")), ~sprintf("%.2f", .))

kable(summary_df, caption = "Summary Statistics for Annual Salary in Seek Data Scientist Dataset")


# Create a table with the number of unique values for each feature
unique_counts <- sapply(seek_ds[c("job_title", "area", "industry", "state")], function(x) length(unique(x)))

# Convert to a data frame
unique_df <- data.frame(
  Unique_Counts = unique_counts
)

# Create table with knitr's kable()
kable(unique_df, caption = "Number of unique values for each feature")


# Set the base theme for all plots
theme_set(theme_ipsum())

# Filter out salaries under 50000
seek_ds_filtered <- seek_ds %>% filter(salary_annual >= 50000)




# Create a histogram of the salary_annual column
ggplot(seek_ds_filtered, aes(x = salary_annual)) +
  geom_histogram(binwidth = 5000, fill = "#4e4e87") +
  geom_vline(aes(xintercept = median(salary_annual, na.rm = TRUE)), color = "#483bcf", linetype = "dashed", size = 1) +
  geom_text(aes(x = median(salary_annual, na.rm = TRUE), y = 16, label = "Median"), color = "#28262b") +
  labs(x = "Annual Salary", y = "Count", title = "Salary Distribution") +
  theme_minimal()


# Create a histogram of the salary_annual column

# clean up the 'state' field to remove extra city names
seek_ds$state <- gsub(".*\\s", "", seek_ds$state)

# Group data by 'state' and calculate the number of positions for each state
state_positions <- seek_ds %>%
  group_by(state) %>%
  summarise(n = n(), .groups = 'drop')

# Print the number of positions per state
# print(state_positions)
# Create table with knitr's kable()
# kable(state_positions, caption = "the number of positions per state")



# Create a bar plot for the number of positions per state
ggplot(state_positions, aes(x = reorder(state, n), y = n)) +
  geom_bar(stat="identity", fill = '#4e4e87') +
  coord_flip() +
  labs(x = 'State', y = 'Number of positions', title = 'Number of positions per state') +
  theme_minimal()


# Boxplot for salary_annual by state
ggplot(seek_ds_filtered, aes(x = state, y = salary_annual)) +
  geom_boxplot(fill = "#4e4e87", outlier.shape = NA) +
  labs(x = "State", y = "Annual Salary", title = "Salary Distribution by State") +
  theme_minimal()



# Group data by 'state' and calculate the median salary for each state
state_salaries <- seek_ds_filtered %>%
  group_by(state) %>%
  summarise(median_salary = median(salary_annual, na.rm = TRUE), .groups = 'drop')

# Print the median salary per state
# kable(state_salaries, caption = "Median Salary per State")




# Join the state_positions and state_salaries dataframes
state_summary <- inner_join(state_positions, state_salaries, by = "state")

# Print the summary dataframe
kable(state_summary, caption = "the number of positions per state and median salary per state")



## Job Titles and Industries


# Find the 10 most common job titles
common_titles <- seek_ds %>%
  count(job_title, sort = TRUE) %>%
  top_n(10)

# Create a bar plot for the common job titles
ggplot(common_titles, aes(x = reorder(job_title, n), y = n)) +
  geom_bar(stat = "identity", fill = '#4e4e87') +
  coord_flip() +
  labs(x = 'Job Title', y = 'Frequency', title = '10 Most Common Job Titles')+
  theme_minimal()



# Find the 10 most common industries
common_industries <- seek_ds %>%
  count(industry, sort = TRUE) %>%
  top_n(10)

# Create a bar plot for the common industries
ggplot(common_industries, aes(x = reorder(industry, n), y = n)) +
  geom_bar(stat = "identity", fill = '#4e4e87') +
  coord_flip() +
  labs(x = 'Industry', y = 'Frequency', title = '10 Most Common Industries') +
  theme_minimal()


# Group data by 'industry' and calculate the median salary for each industry
industry_salaries <- seek_ds_filtered %>%
  group_by(industry) %>%
  summarise(median_salary = median(salary_annual, na.rm = TRUE), .groups = 'drop')

# Filter for the 10 most common industries
industry_salaries <- industry_salaries %>%
  filter(industry %in% common_industries$industry)

# Adjust salary to thousands
industry_salaries$median_salary <- industry_salaries$median_salary / 1000

# Create a bar plot for median salaries by industry
ggplot(industry_salaries, aes(x = reorder(industry, -median_salary), y = median_salary)) +
  geom_bar(stat = "identity", fill = '#4e4e87') +
  coord_flip() +
  scale_y_continuous(labels = scales::comma) +
  labs(x = 'Industry', y = 'Median Salary (in thousands)', title = 'Median Salaries by Industry') +
  theme_minimal()


# Table for 10 Most Common Job Titles
kable(common_titles, caption = '10 Most Common Job Titles')


# Table for 10 Most Common Industries
kable(common_industries, caption = '10 Most Common Industries')



# Adjust median_salary to two decimal places
industry_salaries$median_salary <- sprintf("%.2f", industry_salaries$median_salary)

# Display the table again with the adjusted salary
kable(industry_salaries, caption = 'Median Salaries by Industry')



## Time-Based Analysis of Job Postings


# Count job postings per day per state
jobs_by_date_state <- seek_ds %>%
  count(date_posted, state)

# Create a new column 'week_start' that indicates the start of the week
jobs_by_date_state$week_start <- floor_date(jobs_by_date_state$date_posted, "week")

# Create a line plot for job postings over time, stacked by state
ggplot(jobs_by_date_state, aes(x = date_posted, y = n, fill = state)) +
  geom_area(alpha=0.8 , size=.5, colour="white") +
  scale_fill_viridis(discrete = TRUE) +
  theme_ipsum() + 
  labs(x = 'Date', y = 'Number of Job Postings', fill = 'State', title = 'Job Postings Over Time by State') +
  geom_vline(data=jobs_by_date_state, aes(xintercept = as.numeric(week_start)), linetype="dashed", color = "#3a2c5f", size=0.5) +
  theme_minimal()

# Count job postings per weekday
jobs_by_weekday <- seek_ds %>%
  count(weekday) %>%
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))


# Count job postings per weekday per state
jobs_by_weekday_state <- seek_ds %>%
  count(weekday, state) %>%
  mutate(weekday = factor(weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")))

# Create a bar plot for job postings per weekday, stacked by state
ggplot(jobs_by_weekday_state, aes(x = weekday, y = n, fill = state)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis(discrete = TRUE) +
  labs(x = 'Weekday', y = 'Number of Job Postings', fill = 'State', title = 'Job Postings by Day of the Week') +
  theme_ipsum() +
  theme_minimal()




# Table for Job Postings by Day of the Week
kable(jobs_by_weekday, caption = 'Job Postings by Day of the Week')


# order the dataset by date_posted to see the earliest date
seek_ds <- seek_ds %>% arrange(date_posted)
# head(seek_ds)
head(seek_ds)