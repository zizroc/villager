# Unit tests for the winik class

test_that("the default constructor works", {
  test_winik <- winik$new()

  # Make sure that new winik's start at age 0
  testthat::expect_equal(test_winik$age, 0)

  # Also make sure that they're alive
  testthat::expect_equal(test_winik$age, 0)
})

test_that("custom constructor values work", {
  first_name <- "Bonnie"
  test_winik <- winik$new(age = 10, first_name = first_name, health = 80)
  testthat::expect_equal(test_winik$age, 10)
  testthat::expect_equal(test_winik$first_name, first_name)
  testthat::expect_equal(test_winik$health, 80)

})

test_that("is_alive returns true or false", {
  test_winik <- winik$new()
  is_alive <- test_winik$is_alive()
  expect_true(isTRUE(is_alive) || isFALSE(is_alive))
})

test_that("get_days_since_last_birth returns the age of the youngest winik", {
  mother_winik <- winik$new(age = 10000,
                          first_name = "Mother",
                          health = 80)

  daughter_winik <- winik$new(age = 10,
                            first_name = "Susan",
                            health = 100)
  mother_winik$add_child(daughter_winik)
  testthat::expect_equal(mother_winik$get_days_since_last_birth(), 10)

  son_winik <- winik$new(age = 1,
                              first_name = "Garry",
                              health = 100)
  mother_winik$add_child(son_winik)
  testthat::expect_equal(mother_winik$get_days_since_last_birth(), 1)

  son2_winik <- winik$new(age = 15,
                         first_name = "Garry",
                         health = 100)
  mother_winik$add_child(son2_winik)
  testthat::expect_equal(mother_winik$get_days_since_last_birth(), 1)
})
