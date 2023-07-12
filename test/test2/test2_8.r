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
  mean_contacts <- rpois(N_population, 20)  # Changed mean contacts range to 0-20

  # Calculate R0
  R0 <- sick_count * mean(mean_contacts) * infection_rate / N_population

  # Calculate new infections
  if (sick_count > 0) {
    contact_indices <- unlist(lapply(1:sick_count, function(i) {
      contacts <- sample(1:N_population, size = mean_contacts[i])
      contacts[runif(length(contacts)) < infection_rate * (1 - immunity_coefficient) & !sick_people[contacts]]
    }))
    new_infections <- length(contact_indices)
    sick_people[contact_indices] <- TRUE
    sick_days[contact_indices] <- day
  } else {
    new_infections <- 0  # Updated to reflect no new infections if no sick people
  }

  # Update sick and dead counts
  sick_count <- sum(sick_people)
  dead_count <- dead_count + sum(runif(sick_count) < mortality_rate)  # Corrected calculation

  # Update simulation results
  simulation_results[day, "Sick_Count"] <- sick_count
  simulation_results[day, "Dead_Count"] <- dead_count
  simulation_results[day, "New_Infections"] <- new_infections
  simulation_results[day, "R0"] <- R0
  simulation_results[day, "Contacts_Of_Sick"] <- ifelse(sick_count > 0, sum(mean_contacts), 0)

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

# Print summary
cat("Total sick people:", sum(simulation_results$Sick_Count), "\n")
cat("Total dead people:", sum(simulation_results$Dead_Count), "\n")
cat("Total new infections:", sum(simulation_results$New_Infections), "\n")
cat("Total contacts of sick people:", sum(simulation_results$Contacts_Of_Sick), "\n")

# Calculate average R0 (basic reproduction number)
average_R0 <- mean(simulation_results$R0)
cat("Average R0:", average_R0, "\n")

