# Unit tests for the simulation engine

test_that("the consrtructor works", {
  initial_condition <- function(current_state, model_ata, population_manager, resource_mgr) {
  }
  village <- village$new(name = "Random Population Village", initial_condition = initial_condition)

  mayan_simulation <- simulation$new(4, villages = c(village))
  testthat::expect_length(mayan_simulation$village_mgr$get_villages(), 1)
})

test_that("the number of villages added is correct", {
  initial_condition <- function(current_state, model_ata, population_manager, resource_mgr) {
  }
  coastal_village <- village$new("Test_Village", initial_condition)
  simulator <- simulation$new(2, villages = list(coastal_village))
  testthat::expect_length(simulator$village_mgr$get_villages(), 1)

  # Check with a second village
  plains_village  <- village$new("Test plains village", initial_condition)
  valley_village  <- village$new("Test valley village", initial_condition)
  new_siumulator <- simulation$new(2, villages = list(valley_village, plains_village))
  testthat::expect_length(new_siumulator$village_mgr$get_villages(), 2)
})
