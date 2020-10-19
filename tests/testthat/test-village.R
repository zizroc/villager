# Unit tests for the village

test_that("propagate doesn't copy the initial state on year 1", {

})


test_that("propagate creates a new state from a copied previous state", {

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
