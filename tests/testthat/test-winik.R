
test_that("the default constructor works", {
  test_winik <- winik$new()

  # Make sure that new winik's start at age 0
  expect_true(test_winik$age == 0)

  # Also make sure that they're alive
  expect_true(test_winik$age == 0)
})


test_that("custom constructor values work", {
  first_name <- 'Bonnie'
  test_winik <- winik$new(age = 10, first_name = first_name)
  expect_true(test_winik$age == 10)
  expect_true(test_winik$first_name == first_name)

})

test_that("get_gender returns male or female", {
  test_winik <- winik$new()
  gender <- test_winik$get_gender()
  expect_true(gender == "female" || gender == "male")
})

test_that("is_alive returns true or false", {

})

test_that("add_partner connects one winik to another", {

})

test_that("add_partner connects two winiks together", {

})
