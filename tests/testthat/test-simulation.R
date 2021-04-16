# Unit tests for the simulation engine

test_that("the consrtructor works", {
  start_date = "100-01-01"
  end_date = "100-01-04"
  test_simulation <- simulation$new(start_date, end_date)
  testthat::expect_length(test_simulation$agents, 0)
  testthat::expect_equal(test_simulation$start_date, start_date)
  testthat::expect_equal(test_simulation$end_date, end_date)

  test_agent_1 <- agent$new()
  test_agent_2 <- agent$new()
  test_simulation <- simulation$new(start_date, end_date, c(test_agent_1, test_agent_2))
  testthat::expect_length(test_simulation$agents, 2)
})

test_that("that run_model works", {

})
