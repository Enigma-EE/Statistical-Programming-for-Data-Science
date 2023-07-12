# Exercises for week 7 - SOLUTIONS ---------------------------------------------
# Advanced data visualisation


# Solutions are provided as an example only. 
# There are multiple solutions possible and if your code delivers the same 
# result, then it is [probably] correct too.


# clean up global environment
rm(list = ls())

library(tidyverse)

### Task 1 ---------------------------------------------------------------------

# Load data set "movielens" from the package "dslabs". Check data description.
# extract only ratings for my favorite movies listed below and make a graph
# of boxplots with ratings distribution. Comment on the distribution.

best.movies <- c("Back to the Future", 
                 "Back to the Future Part II",                                                
                 "Back to the Future Part III")

#

movies <- dslabs::movielens

movies %>% filter(title %in% best.movies) %>%
  ggplot(aes(y = title, x = rating)) + 
  geom_boxplot() +
  ggtitle("Back to the Future ratings distribution") +
  ylab("") + xlab("Movie rating") +
  # to change the order of title on y axis
  scale_y_discrete(limits=c(c("Back to the Future Part III", 
                              "Back to the Future Part II",                                                
                              "Back to the Future")))


# The first movie "Back to the Future" got a higher number of ratings 4 and 
# higher than any other movie. As a result, the average rating will be higher
# for Part I movie. At the same time, median values are the same for
# Part I and Part II movies.



### Task 2 ---------------------------------------------------------------------

# Count how many times a rating of each value was awarded to each of my 
# favourite movies and build percent stacked barchart. 
# It is a graph of bars corresponding to rating values (from 0.5 to 5 with 
# 0.5 step). Each bar has the same height as it represents 100% and coloured 
# areas inside the bar show proportions of ratings for each of three movies.


movies %>% filter(title %in% best.movies) %>% 
  group_by(title, rating) %>% summarise(n = n()) %>%
  ggplot(aes(x = rating, y = n, fill = title)) +
  geom_bar(stat="identity", position="fill") +
  ggtitle("Ratings distribution for three movies") +
  xlab("Movie rating") + ylab("Proportion")

# Visualisation interpretation is the same as before and the picture even 
# more clear now: original movie "Back to the Future" got way more higher
# ratings (4 and higher) than follow up movies.



### Task 3 ---------------------------------------------------------------------

# Adjust the graph in task 2 to get proportional stacked area chart. That is,
# not bars but lines, however stacked and stretched to 100% as above.


# correction is absolutely minor - geom_area() instead of geom_bar()
movies %>% filter(title %in% best.movies) %>% 
  group_by(title, rating) %>% summarise(n = n()) %>%
  ggplot(aes(x = rating, y = n, fill = title)) +
  geom_area(stat="identity", position="fill") +
  ggtitle("Ratings distribution for three movies") +
  xlab("Movie rating") + ylab("Proportion")


# the same code but with top-left corner fixed
# you have to add zeros to some ratings
movies %>% filter(title %in% best.movies) %>% 
  group_by(title, rating) %>% summarise(n = n()) %>%
  pivot_wider(id_cols = title, names_from = rating, values_from = n, values_fill = 0) %>%
  pivot_longer(cols = -title, names_to = "rating", values_to = "n") %>%
  mutate(rating = as.numeric(rating)) %>%
  ggplot(aes(x = rating, y = n, fill = title)) +
  geom_area(stat="identity", position="fill") +
  ggtitle("Ratings distribution for three movies") +
  xlab("Movie rating") + ylab("Proportion")



### Task 4 ---------------------------------------------------------------------

# For the "movielens" data set creates a line chart showing the history of
# how many movies were released per year. Add a vertical line to identify
# a year with maximal number of movies.

movies %>% group_by(year) %>% summarise(n = n_distinct(title)) %>%
  ggplot(aes(x = year, y = n)) +
  geom_line() +
  geom_vline(aes(xintercept = year[which.max(n)]), colour = "red") +
  ggtitle("History of movie releases per year") +
  xlab("Year") + ylab("Number of movies") +
  # to have more frequent tick marks on the x axis and hide 2016
  scale_x_continuous(breaks=seq(1900, 2015, 5), limits = c(1900, 2015))


# Another way to count number of movies released per year
# based on the student's suggestion during the class
# This approach is not so elegant for this problem as we had a ready function
# but it can be generalised for some other problems where you do multiple grouping.

df %>% group_by(year, movieId) %>% 
  summarise(n = 1) %>%  # this is a counter for a unique movie per year
  group_by(year) %>% 
  summarise(n = sum(n))

# Result is the same and it can be used for plotting



### Task 5 ---------------------------------------------------------------------

# Check Ggplot2 gallery - https://www.r-graph-gallery.com/index.html
# and try to create as many different graphs as possible.



  

