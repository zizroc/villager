# Unit tests for the state

test_that("the default constructor works", {
  new_state <- villager::village_state$new()
  testthat::expect_equal(new_state$state, NULL)
})
