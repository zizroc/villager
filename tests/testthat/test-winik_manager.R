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
  expect_true(index == 2)
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

test_that("get_living_winiks only returns winiks that are living", {
  winik_mgr <- winik_manager$new()
  winik_1_id <- "test_identifier_1"
  winik_2_id <- "test_identifier_2"
  winik_3_id <- "test_identifier_3"
  winik_4_id <- "test_identifier_4"
  test_winik_1 = winik$new(identifier=winik_1_id, alive=FALSE)
  test_winik_2 = winik$new(identifier=winik_2_id, alive=TRUE)
  test_winik_3 = winik$new(identifier=winik_3_id, alive=FALSE)
  test_winik_4 = winik$new(identifier=winik_4_id, alive=TRUE)

  winik_mgr$add_winik(test_winik_1)
  winik_mgr$add_winik(test_winik_2)
  winik_mgr$add_winik(test_winik_3)
  winik_mgr$add_winik(test_winik_4)

  living_winiks <- winik_mgr$get_living_winiks()
  testthat::expect_length(living_winiks, 2)
  testthat::expect_length(winik_mgr$winiks, 4)

})

test_that("the manager can load winiks from disk", {
  winik_mgr <- winik_manager$new()
  file_path = "test-files/test-winiks.csv"
  winik_mgr$load(file_path)

  # Test that the resources exist with the expected quantities
  jimi_hendrix <- winik_mgr$get_winik(1)
  testthat::expect_equal(jimi_hendrix$first_name, "Jimi")
  testthat::expect_equal(jimi_hendrix$last_name, "Hendrix")
  testthat::expect_equal(jimi_hendrix$mother_id, NA)
  testthat::expect_equal(jimi_hendrix$father_id, NA)
  testthat::expect_equal(jimi_hendrix$profession, "musician")
  testthat::expect_equal(jimi_hendrix$partner, 2)
  testthat::expect_equal(jimi_hendrix$gender, "male")
  testthat::expect_equal(jimi_hendrix$alive, FALSE)
  testthat::expect_equal(jimi_hendrix$age, 27)

  janis_joplin <- winik_mgr$get_winik(2)
  testthat::expect_equal(janis_joplin$first_name, "Janis")
  testthat::expect_equal(janis_joplin$last_name, "Joplin")
  testthat::expect_equal(janis_joplin$mother_id, NA)
  testthat::expect_equal(janis_joplin$father_id, NA)
  testthat::expect_equal(janis_joplin$profession, "musician")
  testthat::expect_equal(janis_joplin$partner, 1)
  testthat::expect_equal(janis_joplin$gender, "female")
  testthat::expect_equal(janis_joplin$alive, FALSE)
  testthat::expect_equal(janis_joplin$age, 27)

  jim_morrison <- winik_mgr$get_winik(3)
  testthat::expect_equal(jim_morrison$first_name, "Jim")
  testthat::expect_equal(jim_morrison$last_name, "Morrison")
  testthat::expect_equal(jim_morrison$mother_id, NA)
  testthat::expect_equal(jim_morrison$father_id, NA)
  testthat::expect_equal(jim_morrison$profession, "musician")
  testthat::expect_true(is.na(jim_morrison$partner))
  testthat::expect_equal(jim_morrison$gender, "male")
  testthat::expect_equal(jim_morrison$alive, FALSE)
  testthat::expect_equal(jim_morrison$age, 27)
})

#test_that("add_partner connects one winik to another", {
#  female_winik <- winik$new()
#  male_winik <- winik$new()
#  winik_mgr <- winik_manager$new()
#  winik_mgr$add_partner(male_winik, add_back=FALSE)
#  expect_true(female_winik$partner == male_winik$identifier)
#  expect_true(is.null(male_winik$partner))
#})
