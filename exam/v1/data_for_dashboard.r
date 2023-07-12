


# clear all variables, functions, etc
# clean up memory
rm(list=ls())
# clean up memory
gc()


pacman::p_load(tidyverse, gglm)
pacman::p_load(knitr,dplyr,AICcmodavg)
pacman::p_load(inspectdf,tidyr,stringr, stringi,DT)
pacman::p_load(tidymodels,glmx)


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

# clean up the 'state' field to remove extra city names
seek_ds$state <- gsub(".*\\s", "", seek_ds$state)

# View the converted dates
# head(seek_ds)
tail(seek_ds)
# check how many rows and columns in the dataset
dim(seek_ds)
str(seek_ds)

# save the seek_ds dataframe as csv file
write.csv(seek_ds, "seek_ds.csv", row.names = FALSE)
# print the first 10 rows of the csv file
head(read.csv("seek_ds.csv"))
