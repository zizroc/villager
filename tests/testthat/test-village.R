# Unit tests for the village

test_that("propagate doesn't copy the initial state on year 1", {
  # Check that the initial state is passed into the user's model on the first year
  # This makes sure that models can set initial states inside their code

  test_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if(currentState$year == 1)
      resource_mgr$add_resource(resource$new(name="corn", quantity=5))
      resource_mgr$add_resource(resource$new(name="salmon", quantity=6))

  }
  new_state <- VillageState$new()
  new_village <- BaseVillage$new(initialState=new_state, models=test_model)
  simulator <- Simulation$new(length = 2, villages = list(new_village))
  simulator$run_model()

  last_record <- simulator$villages[[1]]$StateRecords[[1]]$resource_states
  # Check that the initial state of corn is 5
  corn_row <- match("corn", last_record$name)
  corn_row<- last_record[corn_row,]

  testthat::expect_equal(corn_row$quantity, 5)
  # Check that it was copied to the second day's state
  salmon_row <-match("salmon", last_record$name)
  salmon_row<- last_record[salmon_row,]
  testthat::expect_equal(salmon_row$quantity, 6)
})

test_that("propagate runs a custom model", {
  corn_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if(currentState$year == 1) {
      resource_mgr$add_resource(resource$new(name="corn", quantity=5))
    }
    else {
      if (currentState$year == 3) {
        # On the third year add 5 corn
        corn_resource <- resource_mgr$get_resource("corn")
        corn_resource$quantity <- corn_resource$quantity + 5
      }
    }
  }

  new_state <- VillageState$new()
  new_village <- BaseVillage$new(initialState=new_state, models=corn_model)
  simulator <- Simulation$new(length = 3, villages = list(new_village))
  simulator$run_model()

  last_record <- simulator$villages[[1]]$StateRecords[[3]]$resource_states

  corn_row <- match("corn", last_record$name)
  corn_row<- last_record[corn_row,]
  testthat::expect_equal(corn_row$quantity, 10)
})

test_that("propagate runs multiple custom models", {
  corn_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if(currentState$year == 1) {
      resource_mgr$add_resource(resource$new(name="corn", quantity=5))
    }
    else {
      corn <- resource_mgr$get_resource("corn")
      corn$quantity <-corn$quantity + 1
    }
  }

  salmon_model <- function(currentState, previousState, modelData, population_manager, resource_mgr) {
    if(currentState$year == 1) {
      resource_mgr$add_resource(resource$new(name="salmon", quantity=1))
    }
    else {
      salmon <- resource_mgr$get_resource("salmon")
      salmon$quantity <-salmon$quantity + 1
    }
  }
  new_state <- VillageState$new()
  new_village <- BaseVillage$new(initialState=new_state, models=list(corn_model, salmon_model))

  simulator <- Simulation$new(length = 2, villages = list(new_village))
  simulator$run_model()
  testthat::expect_length(simulator$villages, 1)

  last_record <- simulator$villages[[1]]$StateRecords[[2]]$resource_states
  corn_row <- match("corn", last_record$name)
  corn_row<- last_record[corn_row,]
  salmon_row <- match("salmon", last_record$name)
  salmon_row<- last_record[salmon_row,]
  testthat::expect_equal(corn_row$quantity, 6)
  testthat::expect_equal(salmon_row$quantity, 2)
})
