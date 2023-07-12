# Exercise 1 - SOLUTIONS -------------------------------------------------------
# Data types and data structures, indexing


# Solutions are provided as a example only. 
# There are multiple solutions possible and if your code delivers the same 
# result, then it is [probably] correct too.


# clean up global environment
rm(list = ls()) 



### Task 1 ---------------------------------------------------------------------

# Create a character vector. 
# Use three different methods to get the character vector of length 4.

character(4)

rep("a", 4)

c("a", "b", "c", "d")

as.character(1:4)




### Task 2 ---------------------------------------------------------------------

# Create a sequence of 8 numbers, then apply a mathematical
# operation that should result in the following output:
# [1]    8   16   32   64  128  256  512 1024


my.seq <- 3:10

2^my.seq




### Task 3 ---------------------------------------------------------------------

# Create a data frame as below 
#   x y z
# 1 a 1 5
# 2 b 2 6
# 3 c 3 7

df <- data.frame(x = c("a", "b", "c"), y = 1:3, z = 5:7)

# Use different methods of indexing to extract values "a" and "c" together.
# You should get at least 4 different options.

df$x[c(1,3)]

df[["x"]][c(1,3)]

df[c(1,3), 1]

df[c(1,3), "x"]

df[df$x != "b", 1]

df[c(1,3), ]$x


### Task 4 ---------------------------------------------------------------------


# Run the code below to load data set about passengers of Titanic.

data(Titanic)
Titanic

# Check the help file with data description

help(Titanic)

# Use indexing to extract the number of crew member of both genders 
# survived and died - to get the total count of crew members on Titanic


Titanic[4, , 2, ]

sum(Titanic[4, , 2, ])    # total count of crew members



# as there were no children crew members, the selection might be simpler
# array looks a bit too complex but the result is the same

Titanic[4, , , ]

sum(Titanic[4, , , ])    # total count of crew members




### Task 5 ---------------------------------------------------------------------



# Run the code below to load data set about car performance.

data(mtcars)
mtcars

# Check the help file with data description

help(mtcars)

# Variable "vs" do not look as truly numerical, it has a meaning
# (V-shape or Straight) but not a numerical value. Hence, it should be 
# converted to factor. Create a new variable in the data set "vs.f" 
# with corresponding factor values - V-shape or Straight.

# Hint: check examples for function "factor()"
help(factor)



mtcars$vs.f <- factor(mtcars$vs, labels = c("V-shape", "Straight"))

head(mtcars)






