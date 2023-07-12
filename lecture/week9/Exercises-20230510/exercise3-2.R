# Exercises for dplyr  ---------------------------------------------------------
# Group and Aggregate. More data manipulation


# Please try to complete tasks listed below. Type your code and results 
# interpretations in each section.


# clean up global environment
rm(list = ls())

library(tidyverse)


### Task 1 ---------------------------------------------------------------------

# Load data set "admissions" from the package "dslabs".
# Calculate an average percentage of admitted students separately for 
# men and women. Is there an gender-based bias?






### Task 2 ---------------------------------------------------------------------

# We know the total number of applicants and percent of students admitted for 
# each department and gender. Calculate how many students were admitted in for 
# each departments separately for men and women, then calculate total number of
#  men and women admitted and finally a percent of men and women admitted to 
# the university. Is there an gender-based bias?






### Task 3 ---------------------------------------------------------------------

# Load data set "movielens" from the package "dslabs". Check data description.
# There is a hypothesis that in the past there were more movies and they were
# of a better quality. Count how many movies per in the data set and what is 
# an average rating for all movies in each year.

# Think very carefully about average rating per year. It is not an average of 
# all ratings per year but average of all movies per year.







### Task 4 ---------------------------------------------------------------------

# Keep working with "movielens" data set. There are 671 users provided ratings.
# Some users rated a lot of movies, other users rated not so many movies.
# (1) Select top 10 users by the number of movies they rated.
# (2) For these top users - count how many times they rated movies from each genre.
# (3) For the reporting, create a table with rows being genres, 
# columns being usedId for top 10 users and values being counts of ratings 
# per each genre.

# Hint: to select only some users from the list of many users you can use
# matching value function - check help file: help("%in%", package = "base").
# Alternatively joining function would do the same trick for you.





