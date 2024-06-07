test_that("the first example properly sets the profession of the agents", {
  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
    # Create the initial villagers
    mother <- agent$new(first_name="Kirsten", last_name="Taylor", age=9125)
    father <- agent$new(first_name="Joshua", last_name="Thompson", age=7300)
    daughter <- agent$new(first_name="Mariylyyn", last_name="Thompson", age=10220)
    daughter$mother_id <- mother$identifier
    daughter$father_id <- father$identifier

    # Add the agents to the manager
    agent_mgr$connect_agents(mother, father)
    agent_mgr$add_agent(mother, father, daughter)

    # Create the resources
    corn_resource <- resource$new(name="corn", quantity = 10)
    fish_resource <- resource$new(name="fish", quantity = 15)

    # Add the resources to the manager
    resource_mgr$add_resource(corn_resource, fish_resource)
  }

  test_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    print(paste("Step:", current_state$step))
    for (agent in agent_mgr$get_living_agents()) {
      agent$age <- agent$age+1
      if (agent$age >= 4383) {
        agent$profession <- "Farmer"
      }
    }
  }

  small_village <- village$new("Test Model", initial_condition, test_model)
  simulator <- simulation$new(4, list(small_village))
  simulator$run_model()

  for (agent in simulator$village_mgr$get_villages()[[1]]$agent_mgr$get_living_agents()) {
    testthat::expect_equal(agent$profession, "Farmer")
  }
})

test_that("the second example", {
  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
    for (i in 1:10) {
      name <- runif(1, 0.0, 100)
      new_agent <- agent$new(first_name <- name, last_name <- "Smith")
      agent_mgr$add_agent(new_agent)
    }
  }

  model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    current_day <- current_state$step
    if((current_day%%2) == 0) {
      # Then it's an even day
      # Create two new agents whose first names are random numbers
      for (i in 1:2) {
        name <- runif(1, 0.0, 100)
        new_agent <- agent$new(first_name <- name, last_name <- "Smith")
        agent_mgr$add_agent(new_agent)
      }
    } else {
      # It's an odd day
      living_agents <- agent_mgr$get_living_agents()
      # Kill the first one
      living_agents[[1]]$alive <- FALSE
    }
  }
  coastal_village <- village$new("Test village", initial_condition, model)
  simulator <- simulation$new(4, villages = list(coastal_village))
  simulator$run_model()
  mgr <- simulator$village_mgr$get_villages()[[1]]$agent_mgr
  # Test that there are 14 agents
  testthat::expect_equal(14, length(mgr$agents))
  # Test that 8 are alive
  testthat::expect_equal(12, length(mgr$get_living_agents()))
})
