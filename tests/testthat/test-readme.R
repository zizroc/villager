test_that("the first example properly sets the profession of the winiks", {
  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    # Create the initial villagers
    mother <- winik$new(first_name="Kirsten", last_name="Taylor", age=9125)
    father <- winik$new(first_name="Joshua", last_name="Thompson", age=7300)
    daughter <- winik$new(first_name="Mariylyyn", last_name="Thompson", age=10220)
    daughter$mother_id <- mother$identifier
    daughter$father_id <- father$identifier

    # Add the winiks to the manager
    winik_mgr$connect_winiks(mother, father)
    winik_mgr$add_winik(mother)
    winik_mgr$add_winik(father)
    winik_mgr$add_winik(daughter)

    # Create the resources
    corn_resource <- resource$new(name="corn", quantity = 10)
    fish_resource <- resource$new(name="fish", quantity = 15)

    # Add the resources to the manager
    resource_mgr$add_resource(corn_resource)
    resource_mgr$add_resource(fish_resource)
  }

  test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
    for (winik in winik_mgr$get_living_winiks()) {
      winik$age <- winik$age+1
      if (winik$age >= 4383) {
        winik$profession <- "Farmer"
      }
    }
  }

  small_village <- village$new("Test Model", initial_condition, test_model)
  simulator <- simulation$new(4745, list(small_village))
  simulator$run_model()

  for (winik in simulator$villages[[1]]$winik_mgr$get_living_winiks()) {
    testthat::expect_equal(winik$profession, "Farmer")
  }
})

test_that("the second example", {
  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    for (i in 1:10) {
      name <- runif(1, 0.0, 100)
      new_winik <- winik$new(first_name <- name, last_name <- "Smith")
      winik_mgr$add_winik(new_winik)
    }
  }

  model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
    current_day <- current_state$step
    print(current_day)
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
  simulator <- simulation$new(4, villages = list(coastal_village))
  simulator$run_model()
  mgr <- simulator$villages[[1]]$winik_mgr
  # Test that there are 14 winiks
  testthat::expect_equal(14, length(mgr$winiks))
  # Test that 8 are alive
  testthat::expect_equal(12, length(mgr$get_living_winiks()))
})
