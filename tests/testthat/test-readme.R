test_that("initial conditions with winiks work", {

  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    for (i in 0:3) {
      new_winik <- winik$new(first_name <- i, last_name <- "smith")
      winik_mgr$add_winik(new_winik)
    }
  }

  coastal_village <- village$new("Test village", initial_condition)
  start_date = "100-01-01"
  end_date = "100-01-04"
  simulator <- simulation$new(start_date=start_date, end_date=end_date, villages = list(coastal_village))

  new_siumulator <- simulation$new(start_date=start_date, end_date = end_date,
                                   villages = list(coastal_village))
  new_siumulator$run_model()
  testthat::expect_equal(coastal_village$winik_mgr$get_living_population(), 4)
})

test_that("initial conditions with resources work", {

  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    for (i in 0:3) {
      new_resource <- resource$new(name="corn", quantity = 10)
      resource_mgr$add_resource(new_resource)
    }
  }

  coastal_village <- village$new("Test village", initial_condition)
  start_date = "100-01-01"
  end_date = "100-01-04"
  simulator <- simulation$new(start_date=start_date, end_date=end_date, villages = list(coastal_village))

  new_siumulator <- simulation$new(start_date=start_date, end_date = end_date,
                                   villages = list(coastal_village))
  new_siumulator$run_model()

  testthat::expect_equal(coastal_village$resource_mgr$get_resource("corn")$quantity, 10)
})

test_that("the basic population model works", {

  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    # Add a single winik. This is the equivalent to saying the model starts with a single villager.
    new_winik <- winik$new(first_name <- "Sally", last_name <- "Smith")
    winik_mgr$add_winik(new_winik)
  }

  model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
    # Create a new winik whose first name is a random number
    name <- runif(1, 0.0, 100)
    new_winik <- winik$new(first_name <- name, last_name <- "Smith")
    winik_mgr$add_winik(new_winik)
  }

  coastal_village <- village$new("Test village", initial_condition, model)
  simulator <- simulation$new("-100-01-01", "-100-01-04", villages = list(coastal_village))
  simulator$run_model()

  testthat::expect_equal(coastal_village$winik_mgr$get_living_population(), 4)
})

test_that("winiks are added on even days, killed on odd", {

  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    # Add a single winik. This is the equivalent to saying the model starts with a single villager.
    new_winik <- winik$new(first_name <- "Sally", last_name <- "Smith")
    winik_mgr$add_winik(new_winik)
  }

  model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
    current_day <- current_state$date$day
    if((current_day%%2) == 0) {
      # Then it's an even day
      # Create two new winiks whose first names are random numbers
      for (i in 1:2) {
        name <- runif(1, 0.0, 100)
        new_winik <- winik$new(first_name <- name, last_name <- "Smith")
        winik_mgr$add_winik(new_winik)
      }
    } else {
      # It's an odd day
      living_winiks <- winik_mgr$get_living_winiks()
      # Kill the first one
      living_winiks[[1]]$alive <- FALSE
    }
  }

  coastal_village <- village$new("Test village", initial_condition, model)
  simulator <- simulation$new("-100-01-01", "-100-01-04", villages = list(coastal_village))
  simulator$run_model()

  testthat::expect_equal(coastal_village$winik_mgr$get_living_population(), 4)
})

test_that("resources are properly added", {

  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    corn <- resource$new(name="corn", quantity=10)
    resource_mgr$add_resource(corn)
  }

  model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
    # Add 1 to the corn stocks
    corn <- resource_mgr$get_resource("corn")
    corn$quantity <- corn$quantity + 1
  }

  coastal_village <- village$new("Test village", initial_condition, model)
  simulator <- simulation$new("-100-01-01", "-100-01-04", villages = list(coastal_village))
  simulator$run_model()
  coastal_village$resource_mgr$get_resource("corn")$quantity
  testthat::expect_equal(coastal_village$resource_mgr$get_resource("corn")$quantity, 13)
})
