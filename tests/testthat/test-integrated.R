# Integrated unit tests

test_that("models can add winiks each day", {
  # Create a model that creates a new winik each day
  population_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    new_winik <- winik$new()
    population_manager$add_winik(new_winik)
  }

  initial_condition <- function(currentState, modelData, population_manager, resource_mgr){
    # Do nothing
  }
  # Create a default village
  plains_village  <- BaseVillage$new("Test village", initial_condition, models=population_model)
  # Run for 5 days
  new_siumulator <- Simulation$new(start_date="100-01-01", end_date = "100-01-05", villages = list(plains_village))
  new_siumulator$run_model()
  testthat::expect_length(new_siumulator$villages[[1]]$population_manager$winiks, 4)
  ending_population <- new_siumulator$villages[[1]]$population_manager$get_living_population()
  testthat::expect_equal(ending_population, 4)
})

test_that("models can add and change resource quantities", {
  # Create a model that creates a stock of corn
  # At the end of three days, make sure that there are 6 corn stocks

  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
    crop_resource <- resource$new(name="corn", quantity=0)
    resource_mgr$add_resource(crop_resource)
  }

  deterministic_crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    corn <- resource_mgr$get_resource("corn")
    corn$quantity <-corn$quantity + 3
  }

  # Create a default village
  plains_village  <- BaseVillage$new("Test village", initial_condition,models=deterministic_crop_stock_model)
  new_siumulator <- Simulation$new(start_date="100-01-01", end_date = "100-01-04", villages = list(plains_village))
  new_siumulator$run_model()
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]
  corn <- dplyr::filter(last_record$resource_states, name=="corn")
  testthat::expect_equal(corn$quantity, 9)
})

test_that("models can change resoources based on information from the winik_manager", {
  # The village starts with 20 crops and is decreased each day by 2*population
  # For this unit test, the population is constant.
  # If things are working properly, there should be 8 crops left after 3 days

  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
    # Create an initial stock of crops and add 2 winiks
    crop_resource <- resource$new(name="crops", quantity=20)
    resource_mgr$add_resource(crop_resource)
    population_manager$add_winik(winik$new())
    population_manager$add_winik(winik$new())
  }

  crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    crops <- resource_mgr$get_resource("crops")
    # Each villager eats 2 crops each day
    crops$quantity <- crops$quantity - 2 * population_manager$get_living_population()
  }

  # Create a default village
  plains_village  <- BaseVillage$new("Test village", initial_condition, models=crop_stock_model)
  new_siumulator <- Simulation$new(start_date="-100-01-01", end_date = "-100-01-04", villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]
  crops <- dplyr::filter(last_record$resource_states, name=="crops")
  testthat::expect_equal(crops$quantity, 8)
})

test_that("models can have dynamics based on winik behavior", {

  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
    # Create an initial stock of crops and add 2 winiks
    crop_resource <- resource$new(name="crops", quantity=20)
    resource_mgr$add_resource(crop_resource)

    population_manager$add_winik(winik$new())
    population_manager$add_winik(winik$new())
  }

  # Create a model where winiks are added if there is extra food available
  crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
      crops <- resource_mgr$get_resource("crops")
      crops$quantity <- crops$quantity + 1
      if(crops$quantity-population_manager$get_living_population() > 0) {
        population_manager$add_winik(winik$new())
      }
  }

  # Create a default village
  plains_village  <- BaseVillage$new("Test village", initial_condition, models=crop_stock_model)
  new_siumulator <- Simulation$new(start_date="-100-01-01", end_date = "-100-01-04", villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]

  testthat::expect_equal(plains_village$population_manager$get_living_population(), 5)
})

test_that("winiks and resources can have properties changed in models", {

  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
    # Create an initial state of 4 winiks, all alive and marine resources
    resource_mgr$add_resource(resource$new(name = "marine", quantity = 100))
    dead_winik_id <- "dead_winik_1"
    dead_winik2_id <- "dead_winik_2"

    population_manager$add_winik(winik$new(identifier = dead_winik_id, alive=FALSE))
    population_manager$add_winik(winik$new(identifier = dead_winik2_id, alive=FALSE))
    population_manager$add_winik(winik$new(alive=TRUE))
    population_manager$add_winik(winik$new(alive=TRUE))
  }

  # Create a model where winiks are set to alive/dead
  crop_stock_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    # If it's not the first year, then set two winiks to the dead state
    winik_1 <- population_manager$get_winik("dead_winik_1")
    winik_2 <- population_manager$get_winik("dead_winik_2")
    winik_1$alive <- FALSE
    winik_2$alive <- FALSE
    marine_resource <- resource_mgr$get_resource("marine")
    marine_resource$quantity <- 50
  }

  # Create a default village
  plains_village  <- BaseVillage$new("Test Village", initial_condition, models=crop_stock_model)
  new_siumulator <- Simulation$new(start_date="-100-01-01", end_date = "-100-01-05", villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see if the correct number are left
  record_length <- length(new_siumulator$villages[[1]]$StateRecords)
  last_record <- new_siumulator$villages[[1]]$StateRecords[[record_length]]
  testthat::expect_equal(plains_village$resource_mgr$get_resource("marine")$quantity, 50)
  testthat::expect_equal(plains_village$population_manager$get_living_population(), 2)
  testthat::expect_equal(plains_village$population_manager$get_living_population(), 2)
})


test_that("winiks profession can change based on age", {

  initial_condition <- function(currentState, modelData, winik_manager, resource_mgr) {
    # 40 years old male
    winik_manager$add_winik(winik$new(identifier = "male1", age=14610, alive=TRUE, gender="Male"))
    # 20 year old male
    winik_manager$add_winik(winik$new(identifier = "male2", age=7305, alive=TRUE, gender="Male"))
    # 13 year old female
    winik_manager$add_winik(winik$new(identifier = "female1", age=4748, alive=TRUE, gender="Female"))
    # 8 year old female
    winik_manager$add_winik(winik$new(identifier = "female2", age=2292, alive=TRUE, gender="Female"))
  }

  winik_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    # Get the new list of living winiks and assign professions
    for (living_winik in winik_mgr$get_living_winiks()) {
      if (living_winik$age >= 14610) {
        living_winik$profession <- "Forager"
      } else if (living_winik$age >= 3287 && living_winik$age < 14610 && living_winik$gender == "Male") {
        living_winik$profession <- "Fisher"
      } else if (living_winik$age >= 5113 && living_winik$age <= 14610 && living_winik$gender == "Female") {
        living_winik$profession <- "Farmer"
      } else if (living_winik$age >= 5113 && living_winik$age <= 5113 && living_winik$gender == "Female") {
        living_winik$profession <- "Fisher"
      } else if (living_winik$age < 3287) {
        living_winik$profession <- "Child"
      }
    }
  }

  # Create a default village
  plains_village  <- BaseVillage$new("Test Village", initial_condition, models=winik_model)
  # Run the simulationn for a year so that the winiks get assigned new professionns
  new_siumulator <- Simulation$new(start_date="-100-01-01", end_date = "-99-01-01", villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see that the professions are correct
  village_winik_mgr <- new_siumulator$villages[[1]]$population_manager
  testthat::expect_equal(village_winik_mgr$get_winik("male1")$profession, "Forager")
  testthat::expect_equal(village_winik_mgr$get_winik("male2")$profession, "Fisher")
  testthat::expect_equal(village_winik_mgr$get_winik("female1")$profession, "Farmer")
  testthat::expect_equal(village_winik_mgr$get_winik("female2")$profession, "Child")

})

test_that("winiks can be killed after a particular age", {

  initial_condition <- function(currentState, modelData, winik_manager, resource_mgr) {
    # 40 years old male
    winik_manager$add_winik(winik$new(identifier = "male1", age=15705, alive=TRUE, gender="Male"))
    # 20 year old male
    winik_manager$add_winik(winik$new(identifier = "male2", age=15705, alive=TRUE, gender="Male"))
  }

  # Create a model where winiks are set to alive/dead
  winik_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    # Loop over each winik that is alive and check if they should expire
    for (living_winik in winik_mgr$get_living_winiks()) {
      if (living_winik$age >= 16436) {
        living_winik$alive <- FALSE
      }
    }
  }

  # Create a default village
  plains_village  <- BaseVillage$new("Test Village", initial_condition, models=winik_model)
  # Run the simulationn for two years to age the winiks to 45
  new_siumulator <- Simulation$new(start_date="-100-01-01", end_date = "-98-01-02", villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see that the professions are correct
  village_winik_mgr <- new_siumulator$villages[[1]]$population_manager
  testthat::expect_equal(village_winik_mgr$get_winik("male1")$alive, FALSE)
  testthat::expect_equal(village_winik_mgr$get_winik("male2")$alive, FALSE)

  testthat::expect_length(village_winik_mgr$get_living_winiks(), 0)
  testthat::expect_equal(village_winik_mgr$get_living_population(), 0)

})
