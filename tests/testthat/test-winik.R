# Unit tests for the agent class

test_that("the default constructor works", {
  test_agent <- agent$new()

  # Make sure that new agent's start at age 0
  testthat::expect_equal(test_agent$age, 0)

  # Also make sure that they're alive
  testthat::expect_equal(test_agent$age, 0)
})

test_that("custom constructor values work", {
  first_name <- "Bonnie"
  test_agent <- agent$new(age = 10, first_name = first_name, health = 80)
  testthat::expect_equal(test_agent$age, 10)
  testthat::expect_equal(test_agent$first_name, first_name)
  testthat::expect_equal(test_agent$health, 80)

})

test_that("is_alive returns true or false", {
  test_agent <- agent$new()
  is_alive <- test_agent$is_alive()
  expect_true(isTRUE(is_alive) || isFALSE(is_alive))
})

test_that("get_days_since_last_birth returns the age of the youngest agent", {
  mother_agent <- agent$new(age = 10000,
                          first_name = "Mother",
                          health = 80)

  daughter_agent <- agent$new(age = 10,
                            first_name = "Susan",
                            health = 100)
  mother_agent$add_child(daughter_agent)
  testthat::expect_equal(mother_agent$get_days_since_last_birth(), 10)

  son_agent <- agent$new(age = 1,
                              first_name = "Garry",
                              health = 100)
  mother_agent$add_child(son_agent)
  testthat::expect_equal(mother_agent$get_days_since_last_birth(), 1)

  son2_agent <- agent$new(age = 15,
                         first_name = "Garry",
                         health = 100)
  mother_agent$add_child(son2_agent)
  testthat::expect_equal(mother_agent$get_days_since_last_birth(), 1)
})
