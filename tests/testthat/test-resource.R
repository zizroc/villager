# Unit tests for the resource class

test_that("the default constructor works", {
  res_name <- "fish"
  res_quantity <- 11
  test_resource <- resource$new(name=res_name, quantity=res_quantity)

  # Make sure that new winik's start at age 0
  testthat::expect_equal(test_resource$name, res_name)

  # Also make sure that they're alive
  testthat::expect_equal(test_resource$quantity, res_quantity)
})
