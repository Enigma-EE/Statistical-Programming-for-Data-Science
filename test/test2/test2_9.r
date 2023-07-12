
# Parameters
N_population <- 10000  # total population
N_initial_sick <- 2  # initial number of sick people
N_days <- 100  # number of days to simulate
mortality_rate <- 0.002  # probability of dying per day
infection_rate <- 0.3  # probability of getting infected per contact
immunity_coefficient <- 0.1  # partial immunity coefficient
sickness_period <- 10  # number of days an individual remains sick (updated)

# Initialize variables
sick_count <- N_initial_sick
dead_count <- 0
new_infections <- 0
R0 <- 0
contacts_of_sick <- 0
sick_people <- rep(FALSE, N_population) 
sick_days <- rep(0, N_population)

# Initialize simulation results
simulation_results <- data.frame(Day = 1:N_days, Sick_Count = rep(0, N_days),
                                 Dead_Count = rep(0, N_days), New_Infections = rep(0, N_days),
                                 R0 = rep(0, N_days), Contacts_Of_Sick = rep(0, N_days))


simulation_results[1, "Sick_Count"] <- sick_count

# Run simulation
for (day in 2:N_days) {
  # Generate random number of contacts for each individual
  mean_contacts <- sample(0:20, size = N_population, replace = TRUE)


  # Calculate R0
  R0 <- sick_count * mean(mean_contacts) * infection_rate / N_population

  # Calculate new infections
  if (sick_count > 0) {
    contact_indices <- unlist(lapply(1:sick_count, function(i) {
      contacts <- sample(1:N_population, size = mean_contacts[i])
      contacts[runif(length(contacts)) < infection_rate * ifelse(sick_days[i] == 0, immunity_coefficient, 1) & !sick_people[contacts]]
    }))
    new_infections <- length(contact_indices)
    sick_people[contact_indices] <- TRUE
    sick_days[contact_indices] <- day
  } else {
    new_infections <- 0  # Updated to reflect no new infections if no sick people
  }

  # Update sick and dead counts
  sick_count <- sum(sick_people)
  dead_count <- dead_count + sum(runif(sick_count) < mortality_rate)


  # Update simulation results
  simulation_results[day, "Sick_Count"] <- sick_count
  simulation_results[day, "Dead_Count"] <- dead_count
  simulation_results[day, "New_Infections"] <- new_infections
  simulation_results[day, "R0"] <- R0
  simulation_results[day, "Contacts_Of_Sick"] <- ifelse(sick_count > 0, sum(mean_contacts[sick_people]), 0)


  # Remove recovered individuals from sick_people
  recovered_indices <- which((day - sick_days) >= sickness_period)
  sick_people[recovered_indices] <- FALSE
  sick_days[recovered_indices] <- 0
}

# Plot results
plot(simulation_results$Day, simulation_results$Sick_Count, type = "l",
     xlab = "Day", ylab = "Number of sick people",
     main = "Simulation Results")

lines(simulation_results$Day, simulation_results$Dead_Count, col = "red")
lines(simulation_results$Day, simulation_results$New_Infections, col = "navy")

legend("topright", legend = c("Sick", "Dead", "New infections"),
       col = c("black", "red", "navy"), lty = 1)

print(simulation_results)

# Print the number of sick people, dead people, new infections, and contacts of sick people in the last day of the simulation
cat('The number of sick people in the last day of the simulation is', simulation_results[N_days, "Sick_Count"], "\n")
cat('The number of dead people in the last day of the simulation is', simulation_results[N_days, "Dead_Count"], "\n")
# cat('The number of new infections in the last day of the simulation is', simulation_results[N_days, "New_Infections"], "\n")
mean_new_infections <- mean(simulation_results$New_Infections)
cat('The mean of new infections in the simulation is', mean_new_infections, "\n")


# Calculate average R0 (basic reproduction number)
average_R0 <- mean(simulation_results$R0)
cat("Average R0:", average_R0, "\n")


# Increasing the mortality rate to 0.003 (3%) resulted in a higher number of deaths in the simulation. This indicates that a more dangerous virus with a higher mortality rate can lead to more severe consequences.

# Decreasing the infection rate by 0.05 (from 0.3 to 0.25) resulted in a lower number of sick people and a reduced mean of new infections in the simulation. This suggests that implementing measures like wearing masks and practicing social distancing can effectively reduce the spread of the virus.


# Reducing the number of possible contacts for all citizens to a range between 0 and 2 (lockdown scenario) had a significant impact on reducing the spread of the virus. With a limited number of contacts, the number of sick people and the mean of new infections decreased significantly. This highlights the effectiveness of implementing strict measures like lockdowns to control the spread of the virus.

# Overall, reducing the infection rate and implementing measures like wearing masks, social distancing, and reducing contacts through lockdowns had the strongest effects in reducing the infection growth in the simulation.


# limitation of the model
# The simulation assumes a homogeneous population with uniform contact rates and infection probabilities, but in reality, individuals have different contact patterns and susceptibility to the virus. It uses fixed values for parameters such as infection rate, mortality rate, and sickness period, and does not account for the effects of vaccination or other control measures. It also does not account for behavioral changes that individuals might adopt in response to the pandemic, a simplified immunity model, limited output analysis, and validation against real-world data. It is important to continuously refine and improve the model based on new data, insights, and research findings.


# results of the simulation and the impact of the changes on the results

# the initial trail of the model
# Parameters
# N_population <- 10000  
# N_initial_sick <- 2  
# N_days <- 100  
# mortality_rate <- 0.002  
# infection_rate <- 0.3  
# immunity_coefficient <- 0.1  
# sickness_period <- 10
# The number of sick people in the last day of the simulation is 9959
# The number of dead people in the last day of the simulation is 1360
# The mean of new infections in the simulation is 1786.88
# Average R0: 2.0846


# more dangerous virus scenario – SARS and MERC had 3% mortality
# mortality_rate <- 0.003
# The number of sick people in the last day of the simulation is 9975
# The number of dead people in the last day of the simulation is 2149
# The mean of new infections in the simulation is 1786.28
# Average R0: 2.093913

# decrease infection rate ( 5% – wearing masks and social distance scenario)
# infection_rate <- 0.3 - 0.05
# The number of sick people in the last day of the simulation is 9964
# The number of dead people in the last day of the simulation is 1258
# The mean of new infections in the simulation is 1360.88
# Average R0: 1.568855

# increase the length of sickness period
# sickness_period <- 10+1+1
# The number of sick people in the last day of the simulation is 9922
# The number of dead people in the last day of the simulation is 1273
# The mean of new infections in the simulation is 1313.67
# Average R0: 1.918762

# reduce the number of possible contacts for all citizens to a range between 0 and 2 (lockdown scenario)
# mean_contacts <- sample(0:8, size = N_population, replace = TRUE)
# The number of sick people in the last day of the simulation is 251
# The number of dead people in the last day of the simulation is 11
# The mean of new infections in the simulation is 6.62
# Average R0: 0.006774995

# mean_contacts <- sample(0:6, size = N_population, replace = TRUE)
# The number of sick people in the last day of the simulation is 0
# The number of dead people in the last day of the simulation is 0
# The mean of new infections in the simulation is 0.12
# Average R0: 0.0001206301

# how to run the code in R studio
# 1. open the file in R studio
# 2. click on the source button on the top right corner of the script window or press ctrl+shift+s

# Enna

