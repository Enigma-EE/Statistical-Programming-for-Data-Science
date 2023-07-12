library(rvest)
library(dplyr)
library(stringr)
library(purrr)


scrape_data <- function(term) {
  # Initialize an empty dataframe
  job_data <- data.frame(
    job_title = character(),
    job_link = character(),
    state = character(),
    industry = character(),
    date_posted = character(),
    salary_range = character(),
    search_term = character(),
    salary = character(),  # New column for storing salary
    stringsAsFactors = FALSE
  )
  
  # Initialize an empty vector to store visited job URLs
  visited_urls <- c()
  
  # Iterate over pages
  for (page_num in 1:100) {
    url <- paste0('https://www.seek.com.au/', term, '-jobs/in-All-Australia?page=', page_num)
    
    page <- tryCatch(
      read_html(url),
      error = function(e) return(NULL)
    )
    
    # If page couldn't be read, break the loop
    if (is.null(page)) {
      break
    }
    
    # Each job is contained within an article tag, find all such tags
    job_articles <- page %>% html_nodes("article")
    
    # List of state abbreviations
    states <- c("NSW", "QLD", "SA", "ACT", "VIC", "WA", "TAS", "NT")
    
    # Then for each job, extract the relevant info
    job_data_page <- job_articles %>% map_df(~{
      job_title <- .x %>% html_node("a[data-automation='jobTitle']") %>% html_text(trim = TRUE)
      job_link <- .x %>% html_node("a[data-automation='jobTitle']") %>% html_attr("href")
      
      # Check if the job URL has been visited before
      if (job_link %in% visited_urls) {
        return(NULL)  # Skip duplicate job
      }
      
      visited_urls <<- c(visited_urls, job_link)  # Add visited job URL
      
      # Get all locations
      locations <- .x %>% html_nodes("a[data-automation='jobLocation']") %>% html_text(trim = TRUE)
      
      # Find the location that contains a state abbreviation
      state <- locations[sapply(strsplit(locations, " "), function(x) any(x %in% states))]
      
      # If no location contains a state abbreviation, use the first location
      if (length(state) == 0) {
        state <- locations[1]
      }
      
      industry <- .x %>% html_node("a[data-automation='jobClassification']") %>% html_text(trim = TRUE)
      
      # Get date posted
      date_posted <- .x %>% html_node("span[data-automation='jobListingDate']") %>% html_text(trim = TRUE)
      
      # Get salary
      salary <- .x %>% html_node("div[title]") %>% html_text(trim = TRUE)
      
      data.frame(
        job_title = job_title,
        job_link = job_link,
        state = state,
        industry = industry,
        date_posted = date_posted,
        salary_range = "",  # Empty string for missing salary range
        search_term = term,
        salary = salary,  # Store salary value
        stringsAsFactors = FALSE
      )
    })
    
    # Append the data from this page to the total data
    job_data <- rbind(job_data, job_data_page)
  }
  
  return(job_data)
}


# Scrape data for the term "data-scientist"
all_data <- scrape_data("data-scientist")

# Save data as .rds file
saveRDS(all_data, file = "ds_24062023.rds")
