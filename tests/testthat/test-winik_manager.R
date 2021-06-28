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

test_that("get_states returns the appropriate winik states", {
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

  states <- winik_mgr$get_states()
  testthat::expect_equal(states[1,]$identifier, winik_1_id)
  testthat::expect_equal(states[1,]$alive, FALSE)

  testthat::expect_equal(states[2,]$identifier, winik_2_id)
  testthat::expect_equal(states[2,]$alive, TRUE)

  testthat::expect_equal(states[3,]$identifier, winik_3_id)
  testthat::expect_equal(states[3,]$alive, FALSE)

  testthat::expect_equal(states[4,]$identifier, winik_4_id)
  testthat::expect_equal(states[4,]$alive, TRUE)
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

test_that("propagate increases the age of the winik by one day", {
  winik_mgr <- winik_manager$new()
  winik_mgr$load("test-files/test-winiks.csv")
  for (living_winik in winik_mgr$get_living_winiks()) {
    testthat::expect_equal(living_winik$age, 35)
  }
  winik_mgr$propagate()
  for (living_winik in winik_mgr$get_living_winiks()) {
    testthat::expect_equal(living_winik$age, 36)
  }
})

test_that("the winik manager can properly add children to parents", {
  winik_mgr <- winik_manager$new()

  # Create two sets of parents
  mother_1 = winik$new(identifier="mother1", alive=TRUE)
  mother_2 = winik$new(identifier="mother2", alive=TRUE)
  father_1 = winik$new(identifier="father1", alive=TRUE)
  father_2 = winik$new(identifier="father2", alive=TRUE)
  winik_mgr$add_winik(mother_1)
  winik_mgr$add_winik(mother_2)
  winik_mgr$add_winik(father_1)
  winik_mgr$add_winik(father_2)
  # Connect the mom and dads
  winik_mgr$connect_winiks(mother_1, father_1)
  winik_mgr$connect_winiks(mother_2, father_2)

  # Make sure that they're really connected
  testthat::expect_equal(mother_1$partner, father_1$identifier)
  testthat::expect_equal(father_1$partner, mother_1$identifier)
  testthat::expect_equal(mother_2$partner, father_2$identifier)
  testthat::expect_equal(father_2$partner, mother_2$identifier)


  # Create two children for the first set of parents
  child1 = winik$new(identifier="child1", alive=TRUE, mother_id = mother_1$identifier, father_id = father_1$identifier)
  child2 = winik$new(identifier="child2", alive=TRUE, mother_id = mother_1$identifier, father_id = father_1$identifier)
  # Create another two for the other parents
  child3 = winik$new(identifier="child3", alive=TRUE, mother_id = mother_2$identifier, father_id = father_2$identifier)
  child4 = winik$new(identifier="child4", alive=TRUE, mother_id = mother_2$identifier, father_id = father_2$identifier)

  winik_mgr$add_winik(child1)
  winik_mgr$add_winik(child2)
  winik_mgr$add_winik(child3)
  winik_mgr$add_winik(child4)

  # Use the winik manager to add the children to the parents
  winik_mgr$add_children()
  testthat::expect_length(mother_1$children, 2)
  testthat::expect_length(father_1$children, 2)
  testthat::expect_length(mother_2$children, 2)
  testthat::expect_length(father_2$children, 2)
})

#test_that("add_partner connects one winik to another", {
#  female_winik <- winik$new()
#  male_winik <- winik$new()
#  winik_mgr <- winik_manager$new()
#  winik_mgr$add_partner(male_winik, add_back=FALSE)
#  expect_true(female_winik$partner == male_winik$identifier)
#  expect_true(is.null(male_winik$partner))
#})
