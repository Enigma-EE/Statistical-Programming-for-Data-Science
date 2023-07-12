# Exercise 2 - SOLUTIONS -------------------------------------------------------
# Control flow operators, Functions, Packages


# Solutions are provided as a example only. 
# There are multiple solutions possible and if your code delivers the same 
# result, then it is [probably] correct too.


# clean up global environment
rm(list = ls()) 



### Task 1 ---------------------------------------------------------------------

# Air temperature above 30 degrees might be considered as "too hot". 
# Temperature below 5 degrees is "too cold". Anything in between is "good".
# Use conditions to take a value of air temperature "Temp" and print
# the corresponding condition: "good" or "too hot" or "too cold".

Temp <- 25    # Try different values to test your code

if(Temp > 30){
  print("too hot")
} else if(Temp < 5){
  print("too cold")
} else {
  print("good")
}



### Task 2 ---------------------------------------------------------------------

# Use the code from Task 1 and convert it into a custom function that takes 
# as an input air temperature "Temp" and outputs the corresponding condition.
# Then use a loop with a function to get conditions for the following values
# of the air temperature and store them as a vector "conditions"

Temp <- c(0, 15, 35, 20, -10, 44)

temperature_condition <- function(Temp){
  if(Temp > 30){
    return("too hot")
  } else if(Temp < 5){
    return("too cold")
  } else {
    return("good")
  }
}

conditions <- vector(mode = "character")
for(t in Temp){
  conditions <- c(conditions, temperature_condition(t))
}
print(conditions)



### Task 3 ---------------------------------------------------------------------

# Make a code to re-create a sequence of first 30 Fibonacci numbers
# https://en.wikipedia.org/wiki/Fibonacci_number
# Every next Fibonacci number equals to the sum of two previous numbers
# 1, 1, 2, 3, 5, 8, ...

fibo <- c(1,1)
for(i in seq(3, 30)){
  fibo[i] <- fibo[i-1] + fibo[i-2]
}
print(fibo)



### Task 4 ---------------------------------------------------------------------

# Do a Google search and find ready-made package and function to output
# Fibonacci numbers. Get first 30 numbers and compare them to your own result.

install.packages("numbers")

fibo2 <- numbers::fibonacci(30, sequence = TRUE)
print(fibo2)

# to compare we can take a difference
fibo - fibo2      # obviously, there is no difference



### Task 5 ---------------------------------------------------------------------

# Take a sequence of normally distributed random numbers as below and 
# count how many times the value in sequence is greater than 2 or less than -2.
# Make 4 versions of the code by using: 
# (1) for loop; (2) while loop; (3) repeat loop; (4) no loop

X <- rnorm(1000)

## 1 for loop

cnt <- 0
for(i in X){
  if(i > 2 | i < -2){
    cnt <- cnt + 1
  }
}
print(cnt)


## 2 while loop

cnt <- 0
i <- 1
while(i <= length(X)){
  if(abs(X[i]) > 2){
    cnt <- cnt + 1
  }
  i <- i + 1
}
print(cnt)


## 3 repeat 
# This is a very inefficient code as it checks the length of X on every iteration

cnt <- 0
i <- 0
repeat{
  i <- i + 1
  cnt <- cnt +(abs(X[i]) > 2)
  if(i == length(X)){
    break
  }
}
print(cnt)


## 4 no loop - the best approach to the problem

cnt <- sum(abs(X) > 2)
print(cnt)








