# Unit tests for the winik manager

test_that("the constructor works", {
    winik_mgr <- winik_manager$new()
    testthat::expect_equal(length(winik_manager$winiks), 0)
  })

test_that("winiks are correctly added to the manager", {
  winik_mgr <- winik_manager$new()
  winik_1_id <- "test_identifier_1"
  winik_2_id <- "test_identifier_2"
  test_winik_1 = winik$new(identifier=winik_1_id)
  test_winik_2 = winik$new(identifier=winik_2_id)

  winik_mgr$add_winik(test_winik_1)
  testthat::expect_equal(length(winik_mgr$winiks), 1)
  testthat::expect_equal(winik_mgr$winiks[[1]]$identifier, winik_1_id)
  winik_mgr$add_winik(test_winik_2)
  testthat::expect_equal(length(winik_mgr$winiks), 2)
  })

test_that("the manager gets the correct winiks", {
  winik_mgr <- winik_manager$new()
  winik_1_id <- "test_identifier_1"
  winik_2_id <- "test_identifier_2"
  winik_3_id <- "test_identifier_3"
  test_winik_1 = winik$new(identifier=winik_1_id)
  test_winik_2 = winik$new(identifier=winik_2_id)
  test_winik_3 = winik$new(identifier=winik_3_id)

  winik_mgr$add_winik(test_winik_1)
  winik_mgr$add_winik(test_winik_2)
  winik_mgr$add_winik(test_winik_3)

  should_be_winik_1 <- winik_mgr$get_winik(test_winik_1$identifier)
  testthat::expect_equal(should_be_winik_1$identifier, test_winik_1$identifier)
})

test_that("the manager returns the correct winik index", {
  winik_mgr <- winik_manager$new()
  winik_1_id <- "test_identifier_1"
  winik_2_id <- "test_identifier_2"
  winik_3_id <- "test_identifier_3"
  test_winik_1 = winik$new(identifier=winik_1_id)
  test_winik_2 = winik$new(identifier=winik_2_id)
  test_winik_3 = winik$new(identifier=winik_3_id)

  winik_mgr$add_winik(test_winik_1)
  winik_mgr$add_winik(test_winik_2)
  winik_mgr$add_winik(test_winik_3)

  index <- winik_mgr$get_winik_index(test_winik_2$identifier)
  expect_true(index == winik_2_id)
})

test_that("the manager removes winiks", {
  winik_mgr <- winik_manager$new()
  winik_1_id <- "test_identifier_1"
  winik_2_id <- "test_identifier_2"
  winik_3_id <- "test_identifier_3"
  test_winik_1 = winik$new(identifier=winik_1_id)
  test_winik_2 = winik$new(identifier=winik_2_id)
  test_winik_3 = winik$new(identifier=winik_3_id)

  winik_mgr$add_winik(test_winik_1)
  winik_mgr$add_winik(test_winik_2)
  winik_mgr$add_winik(test_winik_3)

  winik_mgr$remove_winik(test_winik_1$identifier)
  testthat::expect_length(winik_mgr$winiks, 2)
})

#test_that("add_partner connects one winik to another", {
#  female_winik <- winik$new()
#  male_winik <- winik$new()
#  winik_mgr <- winik_manager$new()
#  winik_mgr$add_partner(male_winik, add_back=FALSE)
#  expect_true(female_winik$partner == male_winik$identifier)
#  expect_true(is.null(male_winik$partner))
#})
