# Exercises for dplyr  - SOLUTIONS ---------------------------------------------
# Group and Aggregate. More data manipulation


# Solutions are provided as an example only. 
# There are multiple solutions possible and if your code delivers the same 
# result, then it is [probably] correct too.


# clean up global environment
rm(list = ls())

library(tidyverse)


### Task 1 ---------------------------------------------------------------------

# Load data set "admissions" from the package "dslabs".
# Calculate an average percentage of admitted students separately for 
# men and women. Is there an gender-based bias?


df.admissions <- dslabs::admissions

df.admissions

df.admissions %>% 
  group_by(gender) %>%
  summarise(mean.admitted = mean(admitted))

# Data shows that in average women have a higher rate of admission than men.
# Through all six departments there were admitted in average 41.7% women 
# and 38.2% men applicants.
# Also, we can see that four departments (A, B, D, F) out of six had higher 
# admission rates for women. 



### Task 2 ---------------------------------------------------------------------

# We know the total number of applicants and percent of students admitted for 
# each department and gender. Calculate how many students were admitted in for 
# each departments separately for men and women, then calculate total number of
#  men and women admitted and finally a percent of men and women admitted to 
# the university. Is there an gender-based bias?

df.admissions %>%
  mutate(adm.appl = applicants * admitted / 100) %>%
  group_by(gender) %>%
  summarise(total.appl = sum(applicants), adm.appl = sum(adm.appl)) %>%
  mutate(adm.rate = adm.appl / total.appl)

# In total there were 2691 male applicants and 1198 were admitted. Than makes
# 44.5% admission rate. Then there were 1835 female applicant and 557 of them
# were admitted. This is a rate of 30.3%. There is a bias towards men admission.


# Note: We got two different conclusions for the same data.
# This is an example of the famous Simpson's paradox. You can read about it in
# Wikipedia: https://en.wikipedia.org/wiki/Simpson's_paradox




### Task 3 ---------------------------------------------------------------------

# Load data set "movielens" from the package "dslabs". Check data description.
# There is a hypothesis that in the past there were more movies and they were
# of a better quality. Count how many movies per in the data set and what is 
# an average rating for all movies in each year.

# Think very carefully about average rating per year. It is not an average of 
# all ratings per year but average of all movies per year.

movies <- dslabs::movielens

?dslabs::movielens

# count movies and average ratings for each year
result <- movies %>% group_by(movieId, title, year) %>%
  summarise(movie.avereage.rating = mean(rating)) %>%
  group_by(year) %>%
  summarise(number.movies = n(), avereage.rating = mean(movie.avereage.rating))


# highest number of movies
result %>% arrange(desc(number.movies)) %>% head(10)

# The highest number of movies was released in 1996 with the second place shared 
# between 1998, 2000 and 2002.

# highest rating
result %>% arrange(desc(avereage.rating)) %>% head(10)

# The highest average rating is for movies from 1921 and 1924. However the
# number of movies is really small, so these results are not really trustworthy.




### Task 3 ---------------------------------------------------------------------

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

# get top 10 users
users10 <- movies %>% group_by(userId) %>% 
  summarise(num.ratings = n()) %>%
  arrange(desc(num.ratings)) %>%
  slice_head(n = 10)

# get long table with counts per user per genre
long.df <- movies %>% right_join(users10 %>% select(userId)) %>%
  group_by(userId, genres) %>%
  summarise(num.movies = n())

# alternative approach
long.df <- movies %>% filter(userId %in% users10$userId) %>%
  group_by(userId, genres) %>%
  summarise(num.movies = n())

# convert to wide table
wide.df <- long.df %>% pivot_wider(id_cols = genres, 
                                   names_from = userId,
                                   values_from = num.movies,
                                   values_fill = 0)

head(wide.df, 10)

# "Wide" table happens to be quite long, however technically this is 
# a wide table. Later you will learn how to split genres and make the same 
# analysis more meaningful.





