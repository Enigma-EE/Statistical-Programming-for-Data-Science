# Exercises for week 3 - SOLUTIONS ---------------------------------------------
# Data loading, data visualisation, descriptive statistics


# Solutions are provided as a example only. 
# There are multiple solutions possible and if your code delivers the same 
# result, then it is [probably] correct too.


# clean up global environment
rm(list = ls())



### Task 1 ---------------------------------------------------------------------

# Check your working directory (and/or adjust your working directory) to ensure
# that data file "week03_data_oxygen.csv" is placed in the working directory.
# Then load the data contained in the "week03_data_oxygen.csv" file.
# Provide comments about the data set.

# Data information: The oxygen distribution gives important information 
# on the general biochemistry of marine life. The data measures the oxygen 
# saturation (mg/L^10) at 22 marine parks in Australia. 


# check the working directory
getwd()      


# below command is optional - you can check for the file manually
"week03_data_oxygen.csv" %in% dir()


# load data
df.oxygen <- read.csv("week03_data_oxygen.csv")

head(df.oxygen)

dim(df.oxygen)

# The data set has 22 observation and one numerical variable representing
# an oxygen saturation level at 22 marine parks in Australia.



### Task 2 ---------------------------------------------------------------------

# Visualise data distribution by histogram and boxplot
# Take care about a clear and informative titles and axis labels for all 
# your visualisations.
# Provide your comments about the shape of the distribution as a comment.


# Histogram "wants" a numeric vector
hist(df.oxygen$Oxygen, main = "Oxygen saturation distribution", 
     xlab = "Oxygen saturation, mg/L^10")

# Boxplot can work with a data frame
boxplot(df.oxygen, main = "Oxygen saturation distribution", 
        ylab = "Oxygen saturation, mg/L^10")

# The data look to be non-symmetrical. There is one outlier with unusually high
# oxygen saturation.
# Middle 50% area on the box plot looks to be relatively narrow compared to the
# full distribution range.


### Task 3 ---------------------------------------------------------------------

# Calculate descriptive statistics for the data. 
# Get both options for centrality and dispersion measures. 
# Comment what measures are more appropriate for these data, provide 
# an interpretation for these measures.

# combined measures
summary(df.oxygen)
psych::describe(df.oxygen)    # beware of a package to install

# "manual" calculations
mean(df.oxygen$Oxygen)
median(df.oxygen$Oxygen)

sd(df.oxygen$Oxygen)
IQR(df.oxygen$Oxygen)

# As data look to be non-symmetrical and there is a potential outlier, then 
# median and IQR are more appropriate measures of centrality and dispersion. 

# An average level of oxygen saturation is 8.950 mg/L^10 as measured by the 
# median. IQR is 1.575 mg/L^10 which means that 50% of all observations are 
# within this relatively narrow range between 8.575 and 10.150 mg/L^10.
# At the same time, there are observation with very low oxygen saturation
# of 7.7 mg/L^10 and extremely high of 13.3 mg/L^10. The last figure might be 
# an outlier and requires and an extra check if it represents a correct 
# measurement.


