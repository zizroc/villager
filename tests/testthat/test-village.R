# Unit tests for the village

test_that("propagate doesn't copy the initial state on year 1", {
  # Check that the initial state is passed into the user's model on the first year
  # This makes sure that models can set initial states inside their code

  test_model <- function(currentState, previousState, modelData, population_manager) {
    if(currentState$year == 1)
      currentState$carryingCapacity <- 999

  }
  new_state <- VillageState$new()
  new_village <- BaseVillage$new(initialState=new_state, models=test_model)
  simulator <- Simulation$new(length = 2, villages = list(new_village))
  simulator$run_model()

  # Check that the initial state is 999
  testthat::expect_equal(simulator$villages[[1]]$StateRecords[[1]]$carryingCapacity, 999)
  # Check that it was copied to the second day's state
  testthat::expect_equal(simulator$villages[[1]]$StateRecords[[1]]$carryingCapacity, 999)
})

test_that("propagate runs a custom model", {
  random_crop_stock_model <- function(currentState, previousState, modelData, population_manager) {
    currentState$cropStock <- 11
  }

  new_state <- VillageState$new()
  new_village <- BaseVillage$new(initialState=new_state, models=random_crop_stock_model)
  simulator <- Simulation$new(length = 2, villages = list(new_village))
  simulator$run_model()
  testthat::expect_equal(simulator$villages[[1]]$StateRecords[[2]]$cropStock, 11)
})

test_that("propagate runs multiple custom models", {
  random_crop_stock_model <- function(currentState, previousState, modelData, population_manager) {
    currentState$cropStock <- 11
  }

  random_fish_stock_model <- function(currentState, previousState, modelData, population_manager) {
    currentState$fishStock <- 3
  }
  new_state <- VillageState$new()
  new_village <- BaseVillage$new(initialState=new_state, models=list(random_crop_stock_model, random_fish_stock_model))

  simulator <- Simulation$new(length = 2, villages = list(new_village))
  simulator$run_model()
  testthat::expect_length(simulator$villages, 1)
  testthat::expect_equal(new_village$StateRecords[[2]]$cropStock, 11)
  testthat::expect_equal(new_village$StateRecords[[2]]$fishStock, 3)
})
