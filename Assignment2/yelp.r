# this is a R script for yelp reviews analysis
# but the original report is in Rmd format and just copy the code here
# I tested the code in r and it works
# but there are quite a few packages are for r markdown visualization
# and the coding process is based on r markdown
# so if you run into error, please email me (or install the packages) 
# here is my email: huahy057@mymail.unisa.edu.au
# I will reply as soon as possible
# Thank you for your understanding, cheers!

# clear all variables, functions, etc
# clean up memory
rm(list=ls())
# clean up memory
gc()

# load packages
pacman::p_load(tidyverse, gglm)
pacman::p_load(knitr,dplyr,AICcmodavg)
pacman::p_load(inspectdf,tidyr,stringr, stringi,DT)
pacman::p_load(caret,modelr)
pacman::p_load(mlbench,mplot)
pacman::p_load(tidymodels,glmx)
pacman::p_load(skimr,vip,yardstick,ranger,kknn,funModeling,Hmisc)
pacman::p_load(ggplot2,ggpubr,ggthemes,gridExtra,scales)
knitr::opts_chunk$set(message = FALSE)

# Read the data into a data frame
yelp_reviews <- read_csv("yelp_reviews.csv")

# View the data
yelp_reviews <- as.data.frame(yelp_reviews)
# select variables of interest
yelp_eda <- as.data.frame(yelp_reviews[,c("stars", "review_length","pos_words","neg_words", "net_sentiment")])

# Change variable names
colnames(yelp_eda) <- c("Rating", "Review_Length", "Positive_Words", "Negative_Words", "Net_Sentiment")

# summary statistics for selected variables
skim(yelp_eda) %>%
  dplyr::select(skim_type, skim_variable, n_missing, numeric.mean, numeric.sd, numeric.p0,  numeric.p50, numeric.p100) %>%
  mutate_at(vars(starts_with("numeric.")), ~sprintf("%.2f", .)) %>%
  kable(caption = "Summary Statistics for Selected Variables in Yelp Reviews Dataset")


# Calculate bin width
bin_width <- diff(range(yelp_eda$Rating)) / 12

# Histogram of Rating
ggplot(yelp_eda, aes(x = Rating)) +
  geom_histogram(fill = "steelblue", binwidth = bin_width) +
  theme_minimal() +
  labs(title = "Distribution of Rating", x = "Rating", y = "Frequency") +
  scale_y_continuous(labels = scales::comma)

# Create a new variable with desired levels as a factor
yelp_eda <- yelp_eda %>%
  mutate(Rating_Group = factor(Rating, levels = 1:5))
# Violin plot of Rating_Group vs. Review_Length
# Calculate statistics for each Rating_Group
stat_summary_data <- yelp_eda %>%
  group_by(Rating_Group) %>%
  summarise(
    Mean = mean(Review_Length),
    Median = median(Review_Length),
    Q1 = quantile(Review_Length, 0.25),
    Q3 = quantile(Review_Length, 0.75)
  )
# Violin plot with statistics. Set trim = 0 to exclude outliers
ggplot(yelp_eda, aes(x = Rating_Group, y = Review_Length, fill = Rating_Group)) +
  geom_violin(alpha = 0.7, trim = 0) + 
  stat_summary(fun = mean, geom = "point", shape = 23, size = 2, fill = "black") +
  stat_summary(fun = median, geom = "point", shape = 21, size = 2, fill = "white") +
  stat_summary(fun.data = median_hilow, geom = "errorbar", width = 0.2) +
  labs(title = "Rating and Review Length",
       x = "Rating", y = "Review Length") +
  theme_minimal() + scale_fill_brewer()

# summary statistics for positive and negative words
yelp_eda %>%
  count(Positive_Words) %>%
  tidy() %>%
  mutate_at(vars(mean, sd, trimmed, skew, kurtosis, se), ~sprintf("%.2f", .)) %>%
  kable(caption = "Summary Statistics for Positive Words in the Yelp Reviews Dataset")

yelp_eda %>%
  count(Negative_Words) %>%
  tidy() %>%
  mutate_at(vars(mean, sd, trimmed, skew, kurtosis, se), ~sprintf("%.2f", .)) %>%
  kable(caption = "Summary Statistics for Negative Words in the Yelp Reviews Dataset")

# Create table of counts of positive words per review
positive_words_table <- yelp_eda %>%
  count(Positive_Words)

# Create table of counts of negative words per review
negative_words_table <- yelp_eda %>%
  count(Negative_Words)

# View the first 20 entries of each table
kable(head(positive_words_table, 20), caption = "The first 20 entries of the table of counts of positive words per review") 

kable(head(negative_words_table, 20), caption = "The first 20 entries of the table of counts of negative words per review")

# Plot the first 20 entries of each table
plot_positive_words <- ggplot(positive_words_table[1:20, ], aes(x = Positive_Words, y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Counts of Positive Words per Review", x = "Positive Words", y = "Count") +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma)

plot_negative_words <- ggplot(negative_words_table[1:20, ], aes(x = Negative_Words, y = n)) +
  geom_bar(stat = "identity", fill = "#8f1c03e9") +
  labs(title = "Counts of Negative Words per Review", x = "Negative Words", y = "Count") +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma)


# Subset the first 20 entries from positive_words_table
top_20_positive_words <- head(positive_words_table, 20)

# Subset the first 20 entries from negative_words_table
top_20_negative_words <- head(negative_words_table, 20)

# Combine the two tables into a new table
combined_top_20 <- data.frame(
  Positive_Words = top_20_positive_words$Positive_Words,
  Positive_Count = top_20_positive_words$n,
  Negative_Words = top_20_negative_words$Negative_Words,
  Negative_Count = top_20_negative_words$n
)

# the top 20 positive and negative words
top_20_sca <- ggplot(combined_top_20) +
  geom_point(aes(Positive_Words, Positive_Count), size = 2, color = "steelblue") +
  geom_point(aes(Negative_Words, Negative_Count), size = 2, color = "#8f1c03e9") +
  labs(title = "Both positive and negative", x = "Words", y = "Count") +
  theme_minimal() +
  scale_y_continuous(labels = scales::comma)

# Combine the positive and negative word tables into one data frame
combined_word <- rbind(
  data.frame(Word_Type = "Positive", Count = positive_words_table$Positive_Words, Frequency = positive_words_table$n),
  data.frame(Word_Type = "Negative", Count = negative_words_table$Negative_Words, Frequency = negative_words_table$n)
)

# Adjust x-axis range and add breaks for better visibility
words_plot <- ggplot(combined_word, aes(x = Count, y = Frequency, fill = Word_Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "All words counts per review",x = "Word Count", y = "Frequency", fill = "Word Type") +
  scale_fill_manual(values = c("Positive" = "steelblue", "Negative" = "#8f1c03e9")) +
  theme_minimal() +
  scale_y_continuous(limits = c(0, 350000), labels = function(x) format(x, scientific = FALSE)) +
  scale_x_continuous(limits = c(0, 35), breaks = seq(0, 100, by = 10))


# Display the plots
grid.arrange(plot_positive_words, plot_negative_words, top_20_sca, words_plot, ncol = 2)

# Create table of counts of positive words per review
Net_Sentiment_table <- yelp_eda %>%
  count(Net_Sentiment)

# summary statistics for net sentiment
yelp_eda %>%
  count(Net_Sentiment) %>%
  tidy() %>%
  mutate_at(vars(mean, sd, trimmed, skew, kurtosis, se), ~sprintf("%.2f", .)) %>%
  kable(caption = "Summary Statistics for Net Sentiment in the the Yelp reviews dataset")

# Define the bin boundaries
bins <- c(-Inf, -20, -10, 10, 20, 40, Inf)

# Create a new variable for the bin labels
yelp_eda <- yelp_eda %>%
  mutate(Sentiment_Bin = cut(Net_Sentiment, breaks = bins, labels = c("< -20", "-20 to -10", "-10 to 10", "10 to 20", "20 to 40", "> 40"), include.lowest = TRUE))

# Summarize the counts within each bin
Net_Sentiment_summary <- yelp_eda %>%
  count(Sentiment_Bin) %>%
  arrange(match(Sentiment_Bin, c("< -20", "-20 to -10", "-10 to 10", "10 to 20", "20 to 40", "> 40")))

# Print the summarized table
kable(Net_Sentiment_summary)

# Define the new bin boundaries with increased number of bins
bins <- c(-Inf, -40, -30, -20, -10, 0, 10, 20, 30, 40, Inf)

# Create a new variable for the bin labels
yelp_eda <- yelp_eda %>%
  mutate(Sentiment_Bin = cut(Net_Sentiment, breaks = bins, labels = c("< -40", "-40 to -30", "-30 to -20", "-20 to -10", "-10 to 0", "0 to 10", "10 to 20", "20 to 30", "30 to 40", "> 40"), include.lowest = TRUE))

# Summarize the counts within each bin
Net_Sentiment_summary <- yelp_eda %>%
  count(Sentiment_Bin) %>%
  arrange(match(Sentiment_Bin, c("< -40", "-40 to -30", "-30 to -20", "-20 to -10", "-10 to 0", "0 to 10", "10 to 20", "20 to 30", "30 to 40", "> 40")))

# Print the updated summarized table
kable(Net_Sentiment_summary)

net_sentiment_plot <- ggplot(yelp_eda, aes(x = Net_Sentiment)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Net Sentiment Scores Distribution", x = "Net Sentiment", y = "Frequency") +
  theme_minimal() +
  scale_x_continuous(limits = c(-20, 50), breaks = seq(-20, 50, by = 10))

net_sentiment_plot

# Box Plot with Adjusted Y-Axis Range
ggplot(yelp_eda, aes(x = as.factor(Rating), y = as.numeric(Review_Length))) +
  geom_boxplot(fill = "steelblue", outlier.shape = NA) +
  coord_cartesian(ylim = c(0, quantile(yelp_eda$Review_Length, 0.95))) +
  labs(title = "Distribution of Review Length by Star Category",
       x = "Star Category", y = "Review Length") +
  theme_minimal()
# Bar Plot
ggplot(yelp_eda, aes(x = as.factor(Rating), y = Review_Length, fill = as.factor(Rating))) +
  stat_summary(fun = "mean", geom = "bar") +
  labs(title = "Average Review Length by Star Category",
       x = "Star Category", y = "Average Review Length") +
  theme_minimal() + scale_fill_brewer()

# Calculate average review length by star category with base R function
average_lengths <- aggregate(Review_Length ~ Rating, yelp_eda, mean)

# Rename the Rating column for better readability
levels(average_lengths$Rating) <- c("⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐")

# Rename the columns
names(average_lengths) <- c("Star Category", "Average Review Length")

# Print the table
# print(average_lengths)

# Add columns to yelp_eda
yelp_eda$user_id <- yelp_reviews$user_id
yelp_eda$business_id <- yelp_reviews$business_id
yelp_eda$votes_useful <- yelp_reviews$votes_useful
yelp_eda$date <- yelp_reviews$date

# Rename the dataframe to yelp
yelp <- yelp_eda
# head(yelp)

# Calculate the average usefulness of reviews by star rating
avg_usefulness <- aggregate(votes_useful ~ Rating, data = yelp, FUN = mean)

# Bar Plot
ggplot(avg_usefulness, aes(x = Rating, y = votes_useful)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Average Usefulness of Reviews by Star Rating",
       x = "Star Rating", y = "Average Usefulness") +
  theme_minimal()

# Correlation Analysis
cor_rating_useful <- cor(yelp$Rating, yelp$votes_useful)
cor_length_useful <- cor(yelp$Review_Length, yelp$votes_useful)

# cat("Correlation between Rating and Votes Useful:", cor_rating_useful, "\n")
# cat("Correlation between Review Length and Votes Useful:", cor_length_useful, "\n")

# ANOVA Test
anova_u_r <- aov(votes_useful ~ Rating, data = yelp)
# cat("ANOVA Results for votes useful by Rating:\n")
# print(summary(anova_u_r))

# Kruskal-Wallis Test
kruskal_u_r <- kruskal.test(votes_useful ~ Rating, data = yelp)
# cat("Kruskal-Wallis Test Results for votes useful by Rating:\n")
# print(kruskal_u_r)

# ANOVA Test
anova_u_l <- aov(votes_useful ~ Review_Length, data = yelp)
# cat("ANOVA Results for votes_useful by Review Length:\n")
# print(summary(anova_u_l))

# Kruskal-Wallis Test
kruskal_u_l <- kruskal.test(votes_useful ~ Review_Length, data = yelp)
# cat("Kruskal-Wallis Test Results for votes_useful by Review Length:\n")
# print(anova_u_l)

# Add a new column for Review Length Category
yelp$Review_Length_Category <- cut(yelp$Review_Length, breaks = seq(0, max(yelp$Review_Length, na.rm = TRUE), by = 100), include.lowest = TRUE)

# Calculate the average usefulness of reviews by review length category
avg_usefulness_length <- aggregate(votes_useful ~ Review_Length_Category, data = yelp, FUN = mean)


# Lollipop Plot
ggplot(avg_usefulness_length, aes(x = Review_Length_Category, y = votes_useful)) +
  geom_segment(aes(y = 0, yend = votes_useful, xend = Review_Length_Category), color = "steelblue") +
  geom_point(color = "steelblue",size=5, alpha=0.6) +
  labs(title = "Average Usefulness of Reviews by Review Length",
       x = "Review Length", y = "Average Usefulness") +
  theme_minimal()

# Check data type of 'date' column
date_type <- class(yelp$date)
# cat("Data type of 'date' column: ", date_type, "\n")

# Load the lubridate package
library(lubridate)

# Convert the 'date' column to Date class in case it's not
yelp$date <- as.Date(yelp$date, format = "%d/%m/%Y")

# Count the number of reviews each day
reviews_per_day <- yelp %>%
  group_by(date) %>%
  summarise(count = n())

# Create the first plot with raw data
time_d <- ggplot(reviews_per_day, aes(x = date, y = count)) +
  geom_line() +
  labs(x = "Date", y = "Number of Reviews", 
       title = "Number of Reviews per Day Over Time")

# Create the second plot with 7-day moving average
reviews_per_day <- reviews_per_day %>%
  arrange(date) %>%
  mutate(moving_average_7d = zoo::rollmean(count, 7, fill = NA))
# plot the second plot
time_w <- ggplot(reviews_per_day, aes(x = date)) +
  geom_line(aes(y = count), color = "gray") +
  geom_line(aes(y = moving_average_7d), color = "steelblue") +
  labs(x = "Date", y = "Number of Reviews", 
       title = "Number of Reviews and 7-day Moving Average Over Time")

# Arrange the plots side by side
grid.arrange(time_d, time_w, nrow = 2)

# Create a new columns
yelp$useful <- yelp_reviews$votes_useful
yelp$funny <- yelp_reviews$votes_funny
yelp$cool <- yelp_reviews$votes_cool
# head(yelp)

# find the best user by useful votes
best_user <- yelp %>%
  group_by(user_id) %>%
  summarise(total_votes_useful = sum(votes_useful)) %>%
  arrange(desc(total_votes_useful))

kable(head(best_user), caption = "Best User by Useful Votes")

# Weights for each factor
weights <- c(useful = 0.5, funny = 0.3, cool = 0.2)
# find the best user by weighted score
best_user_advanced <- yelp %>%
  group_by(user_id) %>%
  summarise(
    total_votes_useful = sum(useful),
    total_votes_funny = sum(funny),
    total_votes_cool = sum(cool)
  ) %>%
  mutate(
    value_score = weights['useful']*total_votes_useful + 
                  weights['funny']*total_votes_funny + 
                  weights['cool']*total_votes_cool
  ) %>%
  arrange(desc(value_score))
kable(head(best_user_advanced), caption = "Best User by Weighted Score")

# find the best business by average star rating and total reviews
best_business <- yelp %>%
  group_by(business_id) %>%
  summarise(
    avg_star_rating = mean(Rating),
    total_reviews = n()
  ) %>%
  filter(total_reviews > 50) %>%
  arrange(desc(avg_star_rating), desc(total_reviews))

best_business$avg_star_rating <- round(best_business$avg_star_rating, 2)
kable(head(best_business), caption = "Best Business by Average Star Rating and Total Reviews")

# find the best business by Improvement Over Time
# Calculate average star rating for each business over time
business_rating_over_time <- yelp %>%
  mutate(year = lubridate::year(date)) %>%
  group_by(business_id, year) %>%
  summarise(avg_star_rating = mean(Rating)) %>%
  arrange(business_id, year)

# Calculate the improvement in rating over time
business_rating_over_time <- business_rating_over_time %>%
  group_by(business_id) %>%
  mutate(improvement = avg_star_rating - lag(avg_star_rating)) %>%
  summarise(total_improvement = sum(improvement, na.rm = TRUE))

# Join this information with the original best business data frame
best_business_advanced <- best_business %>%
  left_join(business_rating_over_time, by = "business_id") %>%
  arrange(desc(total_improvement))
best_business_advanced$avg_star_rating <- round(best_business_advanced$avg_star_rating, 2)
kable(head(best_business_advanced), caption = "Best Business by Improvement Over Time")

# Plotting 'best_user'
best_user_plot <- ggplot(head(best_user, 20), aes(x = reorder(user_id, -total_votes_useful), y = total_votes_useful)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Total 'Useful' Votes by User (Top 20)", x = "User ID", y = "Total 'Useful' Votes") +
  theme_minimal()

# Plotting 'best_user_advanced'
best_user_advanced_plot <- ggplot(head(best_user_advanced, 20), aes(x = reorder(user_id, -value_score), y = value_score)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Weighted Score by User (Top 20)", x = "User ID", y = "Weighted Score") +
  theme_minimal()

# Display the plots
grid.arrange(best_user_plot, best_user_advanced_plot, nrow = 2)


# Plotting 'best_business'
best_business_plot <- ggplot(head(best_business, 20), aes(x = reorder(business_id, -avg_star_rating), y = avg_star_rating)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Average Star Rating by Business (Top 20)", x = "Business ID", y = "Average Star Rating") +
  theme_minimal()

# Plotting 'best_business_advanced'
best_business_advanced <- ggplot(head(best_business_advanced, 20), aes(x = reorder(business_id, -total_improvement), y = total_improvement)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Total Improvement in Star Rating by Business (Top 20)", x = "Business ID", y = "Total Improvement") +
  theme_minimal()

# Display the plots
grid.arrange(best_business_plot, best_business_advanced, nrow= 2)

