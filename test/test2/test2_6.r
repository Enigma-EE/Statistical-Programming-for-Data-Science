# Parameters
N_population <- 10000  # total population
N_initial_sick <- 2  # initial number of sick people
N_days <- 100  # number of days to simulate
mortality_rate <- 0.002  # probability of dying per day
infection_rate <- 0.3  # probability of getting infected per contact
immunity_coefficient <- 0.1  # partial immunity coefficient
sickness_period <- 14  # number of days an individual remains sick


# Initialize population
population <- rep(0, N_population)  # 0 = healthy, 1 = sick, 2 = dead, 3 = immune
population[sample(N_population, N_initial_sick)] <- 1
new_infections <- 0

# Initialize counters and data frame
simulation_results <- data.frame(Day = 2:N_days,
                                 Sick_Count = 0,
                                 Dead_Count = 0,
                                 New_Infections = 0,
                                 R0 = 0,
                                 Contacts_Of_Sick = NA)

# Simulation loop
for (day in 1:N_days) {
  # Count sick people
  sick_count <- sum(population == 1)
  
  # Count dead people
  dead_count <- sum(population == 2)
  
  
  # Generate random number of contacts for each individual
  N_contacts <- sample(0:20, N_population, replace = TRUE)
  
  # Find contacts of sick people
  sick_indices <- which(population == 1)
  contact_indices <- lapply(sick_indices, function(i) sample(setdiff(1:N_population, i), N_contacts[i], replace = FALSE))
  contact_indices <- unlist(contact_indices)
  
  # Check if people die
  die <- runif(length(sick_indices)) < mortality_rate
  population[sick_indices[die]] <- 2
  
  # Find healthy contacts
  healthy_contacts <- contact_indices[population[contact_indices] == 0]
  
  # Check if contacts get infected
  infection_prob <- infection_rate
  immune_indices <- sick_indices[population[sick_indices] == 3]
  if (length(immune_indices) > 0) {
    infection_prob <- infection_rate * immunity_coefficient
  }
  infected_contacts <- sample(healthy_contacts, sum(runif(length(healthy_contacts)) < infection_prob))
  population[infected_contacts] <- 1
  new_infections <- length(infected_contacts)
  
  # Check if sick people recover
  recover <- runif(length(sick_indices)) < (1 / sickness_period)
  population[sick_indices[recover]] <- 3
  
  # Calculate R0 (basic reproduction number)
  R0 <- ifelse(sick_count > 0, new_infections / sick_count, 0)
  
  # Store results in the data frame
  simulation_results[day, "Sick_Count"] <- sick_count
  simulation_results[day, "Dead_Count"] <- dead_count
  simulation_results[day, "New_Infections"] <- new_infections
  simulation_results[day, "R0"] <- R0
  simulation_results[day, "Contacts_Of_Sick"] <- length(contact_indices)
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

# Print summary
cat("Total sick people:", sum(simulation_results$Sick_Count), "\n")
cat("Total dead people:", sum(simulation_results$Dead_Count), "\n")
cat("Total new infections:", sum(simulation_results$New_Infections), "\n")
cat("Total contacts of sick people:", sum(simulation_results$Contacts_Of_Sick), "\n")

# Calculate average R0 (basic reproduction number)
average_R0 <- mean(simulation_results$R0)
cat("Average R0:", average_R0, "\n")

# basic parameters of the model and the results
# Parameters
# N_population <- 10000  # total population
# N_initial_sick <- 2  # initial number of sick people
# N_days <- 100  # number of days to simulate
# mortality_rate <- 0.002  # probability of dying per day
# infection_rate <- 0.3  # probability of getting infected per contact
# immunity_coefficient <- 0.1  # partial immunity coefficient
# sickness_period <- 14  # number of days an individual remains sick