# Integrated unit tests

test_that("models can add agents each day", {
  # Create a model that creates a new agent each day
  population_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    new_agent <- agent$new()
    agent_mgr$add_agent(new_agent)
  }

  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
      # Do nothing
    }
  # Create a default village
  plains_village  <- village$new("Test_Village", initial_condition, models = population_model)
  # Run for 5 days
  new_siumulator <- simulation$new(6, villages = list(plains_village))
  new_siumulator$run_model()
  test_villages <- new_siumulator$village_mgr$get_villages()
  testthat::expect_equal(length(test_villages), 1)
  testthat::expect_length(test_villages[[1]]$agent_mgr$agents, 6)
  ending_population <- test_villages[[1]]$agent_mgr$get_living_population()
  testthat::expect_equal(ending_population, 6)
})

test_that("models can add and change resource quantities", {
  # Create a model that creates a stock of corn
  # At the end of three days, make sure that there are 6 corn stocks
  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
    print("123")
    crop_resource <- resource$new(name = "corn", quantity = 0)
    resource_mgr$add_resource(crop_resource)
  }

  deterministic_crop_stock_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    corn <- resource_mgr$get_resource("corn")
    corn$quantity <- corn$quantity + 3
  }

  # Create a default village
  plains_village  <- village$new("Test_Village", initial_condition, models = deterministic_crop_stock_model)
  new_siumulator <- simulation$new(3, villages = list(plains_village))
  new_siumulator$run_model()
  last_record <- new_siumulator$village_mgr$get_villages()[[1]]$current_state
  print(last_record$resource_states)
  corn <- last_record$resource_states %>% dplyr::filter(name == "corn")
  testthat::expect_equal(corn$quantity, 9)
})

test_that("models can change resoources based on information from the agent_manager", {
  # The village starts with 20 crops and is decreased each day by 2*population
  # For this unit test, the population is constant.
  # If things are working properly, there should be 8 crops left after 3 days

  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
    # Create an initial stock of crops and add 2 agents
    crop_resource <- resource$new(name = "crops", quantity = 20)
    resource_mgr$add_resource(crop_resource)
    agent_mgr$add_agent(agent$new())
    agent_mgr$add_agent(agent$new())
  }

  crop_stock_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    crops <- resource_mgr$get_resource("crops")
    # Each villager eats 2 crops each day
    crops$quantity <- crops$quantity - 2 * agent_mgr$get_living_population()
  }

  # Create a default village
  plains_village  <- village$new("Test_Village", initial_condition, models = crop_stock_model)
  new_siumulator <- simulation$new(3, villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$village_mgr$get_villages()[[1]]$StateRecords)
  last_record <- new_siumulator$village_mgr$get_villages()[[1]]$current_state
  crops <- last_record$resource_states %>% dplyr::filter(name == "crops")
  testthat::expect_equal(crops$quantity, 8)
})

test_that("models can have dynamics based on agent behavior", {
  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
    # Create an initial stock of crops and add 2 agents
    crop_resource <- resource$new(name = "crops", quantity = 20)
    resource_mgr$add_resource(crop_resource)

    agent_mgr$add_agent(agent$new())
    agent_mgr$add_agent(agent$new())
  }

  # Create a model where agents are added if there is extra food available
  crop_stock_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    crops <- resource_mgr$get_resource("crops")
    crops$quantity <- crops$quantity + 1
    if (crops$quantity - agent_mgr$get_living_population() > 0) {
      agent_mgr$add_agent(agent$new())
    }
  }

  # Create a default village
  plains_village  <- village$new("Test_Village", initial_condition, models = crop_stock_model)
  new_siumulator <- simulation$new(3, villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$village_mgr$get_villages()[[1]]$StateRecords)
  last_record <- new_siumulator$village_mgr$get_villages()[[1]]$StateRecords[[record_length]]
  testthat::expect_equal(plains_village$agent_mgr$get_living_population(), 5)
})

test_that("agents and resources can have properties changed in models", {
  initial_condition <- function(current_state, model_data, agent_mgr, resource_mgr) {
    # Create an initial state of 4 agents, all alive and marine resources
    resource_mgr$add_resource(resource$new(name = "marine", quantity = 100))
    dead_agent_id <- "dead_agent_1"
    dead_agent2_id <- "dead_agent_2"

    agent_mgr$add_agent(agent$new(identifier = dead_agent_id, alive = FALSE))
    agent_mgr$add_agent(agent$new(identifier = dead_agent2_id, alive = FALSE))
    agent_mgr$add_agent(agent$new(alive = TRUE))
    agent_mgr$add_agent(agent$new(alive = TRUE))
  }

  # Create a model where agents are set to alive/dead
  crop_stock_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    # If it's not the first year, then set two agents to the dead state
    agent_1 <- agent_mgr$get_agent("dead_agent_1")
    agent_2 <- agent_mgr$get_agent("dead_agent_2")
    agent_1$alive <- FALSE
    agent_2$alive <- FALSE
    marine_resource <- resource_mgr$get_resource("marine")
    marine_resource$quantity <- 50
  }

  # Create a default village
  plains_village  <- village$new("Test_Village", initial_condition, models = crop_stock_model)
  new_siumulator <- simulation$new(4, villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  last_record <- new_siumulator$village_mgr$get_villages()[[1]]$current_state
  testthat::expect_equal(plains_village$resource_mgr$get_resource("marine")$quantity,
                         50)
  testthat::expect_equal(plains_village$agent_mgr$get_living_population(), 2)
  testthat::expect_equal(plains_village$agent_mgr$get_living_population(), 2)
})


test_that("agents profession can change based on age", {
  initial_condition <- function(current_state, model_data, agent_manager, resource_mgr) {
    # 40 years old male
    agent_manager$add_agent(agent$new(identifier = "male1", age = 14610, alive = TRUE, gender = "Male"))
    # 20 year old male
    agent_manager$add_agent(agent$new(identifier = "male2", age = 7305, alive = TRUE, gender = "Male"))
    # 13 year old female
    agent_manager$add_agent(agent$new(identifier = "female1", age = 4748, alive = TRUE, gender = "Female"))
    # 8 year old female
    agent_manager$add_agent(agent$new(identifier = "female2", age = 2292, alive = TRUE, gender = "Female"))
  }

  agent_model <- function(current_state, previous_state, model_data, agent_mgr, resource_mgr, village_mgr) {
    # Get the new list of living agents and assign professions
    for (living_agent in agent_mgr$get_living_agents()) {
      if (living_agent$age >= 14610) {
        living_agent$profession <- "Forager"
      } else if (living_agent$age >= 3287 && living_agent$age < 14610 && living_agent$gender == "Male") {
        living_agent$profession <- "Fisher"
      } else if (living_agent$age >= 5113 && living_agent$age <= 14610 && living_agent$gender == "Female") {
        living_agent$profession <- "Farmer"
        } else if (living_agent$age >= 5113 && living_agent$age <= 5113 && living_agent$gender == "Female") {
          living_agent$profession <- "Fisher"
        } else if (living_agent$age < 5000 && living_agent$age > 3288) {
          living_agent$profession <- "Farmer"
        } else if (living_agent$age < 3287) {
          living_agent$profession <- "Child"
        }
      }
    }

  # Create a default village
  plains_village  <- village$new("Test_Village", initial_condition, models = agent_model)
  # Run the simulationn for a year so that the agents get assigned new professions
  new_siumulator <- simulation$new(364, villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see that the professions are correct
  village_agent_mgr <- new_siumulator$village_mgr$get_villages()[[1]]$agent_mgr
  testthat::expect_equal(village_agent_mgr$get_agent("male1")$profession, "Forager")
  testthat::expect_equal(village_agent_mgr$get_agent("male2")$profession, "Fisher")
  testthat::expect_equal(village_agent_mgr$get_agent("female1")$profession, "Farmer")
  testthat::expect_equal(village_agent_mgr$get_agent("female2")$profession, "Child")
})
