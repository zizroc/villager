# Unit tests for the state

test_that("the default constructor works", {
  new_state <- villager::village_state$new()

  testthat::expect_equal(new_state$birthRate, 0.085)
  testthat::expect_equal(new_state$deathRate, 0.070)
  testthat::expect_equal(new_state$carryingCapacity, 300)
  testthat::expect_equal(new_state$date, NA)
})
