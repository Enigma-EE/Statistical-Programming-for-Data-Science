# Exercises for dplyr  - SOLUTIONS ---------------------------------------------
# Vectorisation, apply() function, data manipulations


# Solutions are provided as an example only. 
# There are multiple solutions possible and if your code delivers the same 
# result, then it is [probably] correct too.


# clean up global environment
rm(list = ls())

# load the library
library(dplyr)

### Task 1 ---------------------------------------------------------------------

# Load data set "admissions" from the package "dslabs" (you might need to
# install the package first). Check the data set, check the help file for the 
# data. Use apply function to get type of data for each variable.
# Provide your comment about the data.

df.admissions <- dslabs::admissions

head(df.admissions)

dim(df.admissions)

sapply(df.admissions, class)

# This is a small data set with 12 observations only and 4 variables.
# Two variables (major and gender) are characters and two variables (admitted
# and applicants) are numerics.



### Task 2 ---------------------------------------------------------------------

# Use apply functions and "dplyr" package functionality to get average values
# for a number of applicants and percent of students admitted.
# Provide 3-4 different versions of the code.

sapply(df.admissions, mean)  # two NAs in the result is not a mistake
                             # however it is a poor style


apply(df.admissions[ , -c(1,2)], 2, mean)


summarise(df.admissions, admitted = mean(admitted), applicants = mean(applicants))


df.admissions %>% select(admitted, applicants) %>% summarise_all(mean)





### Task 3 ---------------------------------------------------------------------

# Use "base" and "dplyr" functionality to get average values for a number of 
# applicants and percent of students admitted for "men" only.
# Provide 3-4 different versions of the code.

sapply(df.admissions[df.admissions$gender == "men", c(3,4)], mean)


df.men <- subset(df.admissions, df.admissions$gender == "men", 
                 c("admitted", "applicants"))
apply(df.men, 2, mean)


summarise(filter(df.admissions, gender == "men"), 
          admitted = mean(admitted), applicants = mean(applicants))

summarise(df.admissions %>% filter(gender == "men"), 
          admitted = mean(admitted), applicants = mean(applicants))

df.admissions %>% 
  filter(gender == "men") %>%
  select(admitted, applicants) %>% 
  summarise_all(mean)




### Task 4 ---------------------------------------------------------------------

# Create two data frames based on the original one. First data set is to have
# columns "major", "gender" and "admitted". Second data set is to have columns
# "major", "gender" and "applicants". 

# Use "base" and "dplyr" functionality to combine these two data sets together.
# Provide 3-4 different versions of the code for combining data.

# Check if you get the same result as the original data set.

df.1 <- df.admissions %>% select(-applicants)
df.2 <- df.admissions %>% select(-admitted)

merge(df.1, df.2, by = c("major", "gender"))

merge(df.1, df.2, by = c("gender", "major"))

inner_join(df.1, df.2, by = c("gender", "major"))

df.1 %>% left_join(df.2) # both data sets have the same set of rows, so
                         # inner join and left join results are identical

# Resulted data frames might have a different order of rows and columns
# but they are the same data frames content-wise. The order does not matter.









