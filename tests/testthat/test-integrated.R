# Integrated unit tests

test_that("models can add winiks each day", {
  # Create a model that creates a new winik each day
  population_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    new_winik <- winik$new()
    population_manager$add_winik(new_winik)
  }

  # Create a default village
  new_state <- VillageState$new()
  plains_village  <- BaseVillage$new(initialState=new_state, models=population_model)
  # Run for 5 days
  days_to_run <- 5
  new_siumulator <- Simulation$new(length = days_to_run, villages = list(plains_village))
  new_siumulator$run_model()
  testthat::expect_length(new_siumulator$villages[[1]]$population_manager$winiks, 5)
  ending_population <- new_siumulator$villages[[1]]$population_manager$get_living_population()
  # Since it ran for 3 days, there should be a population of 'days_to_run'
  testthat::expect_equal(ending_population, days_to_run)
})

test_that("models can add and change resource quantities", {
  # Create a model that creates a stock of corn
  # At the end of three days, make sure that there are 6 corn stocks

  deterministic_crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if (currentState$year == 1) {
      crop_resource <- resource$new(name="corn", quantity=0)
      resource_mgr$add_resource(crop_resource)
      return()
    }
    corn <- resource_mgr$get_resource("corn")
    corn$quantity <-corn$quantity + 3
  }

  # Create a default village
  new_state <- VillageState$new()
  plains_village  <- BaseVillage$new(initialState=new_state, models=deterministic_crop_stock_model)
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]
  print(last_record)
  testthat::expect_equal(last_record$cropStock, 6)
})

test_that("models can change resoources based on information from the winik_manager", {
  # The village starts with 20 crops and is decreased each day by 2*population
  # For this unit test, the population is constant.
  # If things are working properly, there should be 8 crops left after 3 days

  crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if (currentState$year == 1) {
      # Create an initial stock of crops and add 2 winiks
      crop_resource <- resource$new(name="crops", quantity=20)
      resource_mgr$add_resource(crop_resource)
      population_manager$add_winik(winik$new())
      population_manager$add_winik(winik$new())
    }

    crops <- resource_mgr$get_resource("crops")
    # Each villager eats 2 crops each day
    crops$quantity <- crops$quantity - 2 * population_manager$get_living_population()
  }

  # Create a default village
  new_state <- VillageState$new()
  plains_village  <- BaseVillage$new(initialState=new_state, models=crop_stock_model)
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]
  print(last_record)
  testthat::expect_equal(last_record$cropStock, 8)
})

test_that("models can have dynamics based on winik behavior", {
  # Create a model where winiks are added if there is extra food available

  crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if (currentState$year == 1) {
      # Create an initial stock of crops and add 2 winiks
      crop_resource <- resource$new(name="crops", quantity=20)
      resource_mgr$add_resource(crop_resource)

      population_manager$add_winik(winik$new())
      population_manager$add_winik(winik$new())
    } else {
      crops <- resource_mgr$get_resource("crops")
      crops$quantity <- crops$quantity + 1
      if(crops$quantity-population_manager$get_living_population() > 0) {
        population_manager$add_winik(winik$new())
      }
    }
  }

  # Create a default village
  new_state <- VillageState$new()
  plains_village  <- BaseVillage$new(initialState=new_state, models=crop_stock_model)
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]
  testthat::expect_equal(plains_village$population_manager$get_living_population(), 4)
})
