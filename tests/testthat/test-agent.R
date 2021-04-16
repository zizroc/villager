test_that("the consrtructor works", {

  # Test the empty constructor
  test_agent_1 <- agent()
  testthat::expect_equal(test_agent$identifier, NA)
  testthat::expect_length(test_agent$agents, 0)

  # Test a full constructor
  test_agent_2 <- agent$new(identifier=1234, list(test_agent_1))
  testthat::expect_equal(test_agent$identifier, 1234)
  testthat::expect_length(test_agent$agents, 1)
})
