# Parameters
N_population <- 1000  # total population
N_initial_sick <- 2  # initial number of sick people
N_contacts <- 20  # maximum number of contacts per day
N_days <- 100  # number of days to simulate
mortality_rate <- 0.002  # probability of dying per day
infection_rate <- 0.3  # probability of getting infected per contact
immunity_coefficient <- 0.1  # partial immunity coefficient

# Initialize population
population <- rep(0, N_population)  # 0 = healthy, 1 = sick, 2 = dead
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
  
  # Generate contacts for all individuals
  contacts <- sample(N_population, N_population * N_contacts, replace = TRUE)
  
  # Find contacts of sick people
  sick_indices <- which(population == 1)
  contact_indices <- matrix(contacts, nrow = N_population, byrow = TRUE)[sick_indices, ]
  
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
  new_infections[day] <- length(infected_contacts) # Count new infections
  
  # Check if sick people get healthy
  immune_indices <- sick_indices[runif(length(sick_indices)) < 0.1]
  population[immune_indices] <- 3
  population[population == 1] <- 0
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
