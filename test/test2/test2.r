# Parameters
N_population <- 1000 # total population
N_initial_sick <- 2 # initial number of sick people
N_contacts <- 20 # maximum number of contacts per day
N_days <- 300 # number of days to simulate
mortality_rate <- 0.002 # probability of dying per day
infection_rate <- 0.3 # probability of getting infected per contact
immunity_coefficient <- 0.1 # partial immunity coefficient

# Initialize population
population <- rep(0, N_population) # 0 = healthy, 1 = sick, 2 = dead
population[sample(N_population, N_initial_sick)] <- 1

# Initialize counters
sick_count <- rep(0, N_days)
dead_count <- rep(0, N_days)
new_infections <- rep(0, N_days)

# Simulation loop
for (day in 1:N_days) {
  # Count sick people
  sick_count[day] <- sum(population == 1)
  
  # Count dead people
  dead_count[day] <- sum(population == 2)
  
  # Count new infections
  new_infections[day] <- 0
  
  # Loop over sick people
  for (i in which(population == 1)) {
    # Check if person dies
    if (runif(1) < mortality_rate) {
      population[i] <- 2 # person dies
    } else {
      # Loop over contacts
      for (j in sample(N_population, N_contacts)) {
        # Check if contact is healthy
        if (population[j] == 0) {
          # Check if contact gets infected
          if (runif(1) < infection_rate) {
            # Check if contact becomes immune
            if (population[i] == 3) {
              if (runif(1) < infection_rate * immunity_coefficient) {
                population[j] <- 1 # contact gets infected
                new_infections[day] <- new_infections[day] + 1
              }
            } else {
              population[j] <- 1 # contact gets infected
              new_infections[day] <- new_infections[day] + 1
            }
          }
        }
      }
      
      # Check if person gets healthy
      if (population[i] == 1 && runif(1) < 0.1) {
        population[i] <- 3 # person gets immune
      } else if (population[i] == 1) {
        population[i] <- 0 # person gets healthy
      }
    }
  }
}

# Plot results
plot(1:N_days, sick_count, type = "l", xlab = "Day", ylab = "Number of sick people")
lines(1:N_days, dead_count, col = "red")
lines(1:N_days, new_infections, col = "blue")
legend("topright", legend = c("Sick", "Dead", "New infections"), col = c("black", "red", "blue"), lty = 1)

# Print summary
cat("Total sick people:", sum(sick_count), "\n")
cat("Total dead people:", sum(dead_count), "\n")
cat("Total new infections:", sum(new_infections), "\n")