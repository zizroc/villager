# Unit tests for the village

test_that("the initial models can properly set village states", {

  # Create the function that sets the initial state
  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
    # Set some initial conditions for resource stocks
    resource_mgr$add_resource(resource$new(name="corn", quantity=5))
    resource_mgr$add_resource(resource$new(name="salmon", quantity=6))
  }

  new_village <- village$new("Test village", initial_condition=initial_condition, models=list())
  simulator <- simulation$new(start_date="100-01-01", end_date = "100-01-02", villages = list(new_village))
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

test_that("the initial condition is properly set", {
  # Check that the initial state is passed into the user's model on the first year
  # This makes sure that models can set initial states inside their code


  initial_condition <- function(currentState, modelData, population_manager, resource_mgr) {
    resource_mgr$add_resource(resource$new(name="corn", quantity=5))
    resource_mgr$add_resource(resource$new(name="salmon", quantity=6))
  }

  new_village <- village$new("Test village", initial_condition)
  simulator <- simulation$new(start_date="100-01-01", end_date = "100-01-02", villages = list(new_village))
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
  initial_condition <- function(currentState, modelData, winik_mgr, resource_mgr) {
    resource_mgr$add_resource(resource$new(name="corn", quantity=5))
  }

  corn_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
      if(gregorian::diff_days(currentState$date, gregorian::as_gregorian("100-01-04")) == 0) {
        # On the third day add 5 corn
        corn_resource <- resource_mgr$get_resource("corn")
        corn_resource$quantity <- corn_resource$quantity + 5
      }
  }

  new_village <- village$new("Test village", initial_condition, models=corn_model)
  simulator <- simulation$new(start_date="100-01-01", end_date = "100-01-04", villages = list(new_village))
  simulator$run_model()

  last_record <- simulator$villages[[1]]$StateRecords[[4]]$resource_states

  corn_row <- match("corn", last_record$name)
  corn_row<- last_record[corn_row,]
  testthat::expect_equal(corn_row$quantity, 10)
})

test_that("propagate runs multiple custom models", {
  initial_conditions <-function(currentState, modelData, winik_mgr, resource_mgr) {
    resource_mgr$add_resource(resource$new(name="corn", quantity=5))
    resource_mgr$add_resource(resource$new(name="salmon", quantity=1))
  }

  corn_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    corn <- resource_mgr$get_resource("corn")
    corn$quantity <-corn$quantity + 1
  }

  salmon_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    salmon <- resource_mgr$get_resource("salmon")
    salmon$quantity <-salmon$quantity + 1
  }

  new_village <- village$new("Test village", initial_conditions, models=list(corn_model, salmon_model))

  simulator <- simulation$new(start_date="100-01-01", end_date = "100-01-03", villages = list(new_village))
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
