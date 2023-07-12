# Parameters
N_population <- 1000  # total population
N_initial_sick <- 2  # initial number of sick people
N_days <- 100  # number of days to simulate
mortality_rate <- 0.002  # probability of dying per day
infection_rate <- 0.3  # probability of getting infected per contact
immunity_coefficient <- 0.1  # partial immunity coefficient

# Initialize population
population <- rep(0, N_population)  # 0 = healthy, 1 = sick, 2 = dead
population[sample(N_population, N_initial_sick)] <- 1

# Initialize counters
simulation_results <- data.frame(Day = 1:N_days,
                                 Sick_Count = 0,
                                 Dead_Count = 0,
                                 New_Infections = 0,
                                 R0 = 0)

# Simulation loop
for (day in 1:N_days) {
  # Count sick people
  sick_count <- sum(population == 1)
  
  # Count dead people
  dead_count <- sum(population == 2)
  
  # Count new infections
  new_infections <- 0
  
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
  
  # Check if sick people get healthy
  immune_indices <- sick_indices[runif(length(sick_indices)) < 0.1]
  population[immune_indices] <- 3
  population[population == 1] <- 0
  
  # Calculate R0 (basic reproduction number)
  R0 <- ifelse(sick_count > 0, new_infections / sick_count, 0)
  
  # Store results in the data frame
  simulation_results[day, "Sick_Count"] <- sick_count
  simulation_results[day, "Dead_Count"] <- dead_count
  simulation_results[day, "New_Infections"] <- new_infections
  simulation_results[day, "R0"] <- R0
}

# Plot results
plot(simulation_results$Day, simulation_results$Sick_Count, type = "l",
     xlab = "Day", ylab = "Number of sick people",
     main = "Simulation Results")

lines(simulation_results$Day, simulation_results$Dead_Count, col = "red")
lines(simulation_results$Day, simulation_results$New_Infections, col = "blue")

legend("topright", legend = c("Sick", "Dead", "New infections"),
       col = c("black", "red", "blue"), lty = 1)

print(simulation_results)

# Print summary
cat("Total sick people:", sum(simulation_results$Sick_Count), "\n")
cat("Total dead people:", sum(simulation_results$Dead_Count), "\n")
cat("Total new infections:", sum(simulation_results$New_Infections), "\n")

# Calculate average R0
average_R0 <- mean(simulation_results$R0)
cat("Average R0:", average_R0, "\n")
