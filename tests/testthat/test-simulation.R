# Unit tests for the simulation engine

test_that("the consrtructor works", {
  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
  }
  village = BaseVillage$new(name="Random Population Village", initial_condition=initial_condition)

  start_date = "100-01-01"
  end_date = "100-01-04"
  mayanSimulation <- Simulation$new(start_date=start_date, end_date = end_date, villages=c(village))
  testthat::expect_length(mayanSimulation$villages, 1)
  testthat::expect_length(mayanSimulation$villages, 1)
  testthat::expect_length(mayanSimulation$villages, 1)
})

test_that("the number of villages added is correct", {
  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
  }
  coastal_village <- BaseVillage$new("Test village", initial_condition)
  start_date = "100-01-01"
  end_date = "100-01-04"

  simulator <- Simulation$new(start_date=start_date, end_date=end_date, villages = list(coastal_village))
  testthat::expect_length(simulator$villages, 1)

  # Check with a second village
  plains_village  <- BaseVillage$new("Test plains village", initial_condition)
  valley_village  <- BaseVillage$new("Test valley village", initial_condition)
  new_siumulator <- Simulation$new(start_date=start_date, end_date = end_date,
                                   villages = list(valley_village, plains_village))
  testthat::expect_length(new_siumulator$villages, 2)
})
