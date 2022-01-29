# Unit tests for the resource manager

test_that("the constructor works", {
  resource_mgr <- resource_manager$new()
  testthat::expect_equal(length(resource_mgr$get_resources()), 0)
})

test_that("resources are correctly added to the manager", {
  resource_mgr <- resource_manager$new()
  resource_1_name <- "corn"
  resource_1_quantity <- 11
  resource_2_name <- "beets"
  resource_2_quantity <- 13
  test_resource_1 <- resource$new(name=resource_1_name, quantity=resource_1_quantity)
  test_resource_2 <- resource$new(name=resource_2_name, quantity=resource_2_quantity)

  resource_mgr$add_resource(test_resource_1)
  testthat::expect_equal(length(resource_mgr$get_resources()), 1)
  testthat::expect_equal(resource_mgr$get_resources()[[1]]$name, resource_1_name)
  resource_mgr$add_resource(test_resource_2)
  testthat::expect_equal(length(resource_mgr$get_resources()), 2)

})

test_that("the manager returns all rsources", {
  resource_mgr <- resource_manager$new()

  apples  <- resource$new("apple", 5)
  oranges <- resource$new("orange", 10)
  cabbage <- resource$new("cabbage", 20)

  resource_mgr$add_resource(apples)
  resource_mgr$add_resource(oranges)
  resource_mgr$add_resource(cabbage)
  testthat::expect_equal(length(resource_mgr$get_resources()), 3)
})

test_that("the manager gets the correct resource", {
  resource_mgr <- resource_manager$new()
  resource_1_name <- "rice"
  resource_1_quantity <- 11
  resource_2_name <- "fish"
  resource_2_quantity <- 13
  resource_3_name <- "beets"
  resource_3_quantity <- 5

  test_resource_1 <- resource$new(name=resource_1_name, quantity=resource_1_quantity)
  test_resource_2 <- resource$new(name=resource_2_name, quantity=resource_2_quantity)
  test_resource_3 <- resource$new(name=resource_3_name, quantity=resource_3_quantity)

  resource_mgr$add_resource(test_resource_1)
  resource_mgr$add_resource(test_resource_2)
  resource_mgr$add_resource(test_resource_3)

  should_be_resource_1 <- resource_mgr$get_resource(test_resource_1$name)
  testthat::expect_equal(should_be_resource_1$name, resource_1_name)
})

test_that("the manager returns the correct resource index", {

  resource_mgr <- resource_manager$new()
  resource_1_name <- "rice"
  resource_1_quantity <- 11
  resource_2_name <- "fish"
  resource_2_quantity <- 13
  resource_3_name <- "beets"
  resource_3_quantity <- 5

  test_resource_1 <- resource$new(name=resource_1_name, quantity=resource_1_quantity)
  test_resource_2 <- resource$new(name=resource_2_name, quantity=resource_2_quantity)
  test_resource_3 <- resource$new(name=resource_3_name, quantity=resource_3_quantity)

  resource_mgr$add_resource(test_resource_1)
  resource_mgr$add_resource(test_resource_2)
  resource_mgr$add_resource(test_resource_3)

  index <- resource_mgr$get_resource_index(resource_2_name)
  expect_true(index == 2)
})

test_that("the manager removes resources", {
  resource_mgr <- resource_manager$new()
  resource_1_name <- "rice"
  resource_1_quantity <- 11
  resource_2_name <- "fish"
  resource_2_quantity <- 13
  resource_3_name <- "beets"
  resource_3_quantity <- 5

  test_resource_1 <- resource$new(name=resource_1_name, quantity=resource_1_quantity)
  test_resource_2 <- resource$new(name=resource_2_name, quantity=resource_2_quantity)
  test_resource_3 <- resource$new(name=resource_3_name, quantity=resource_3_quantity)

  resource_mgr$add_resource(test_resource_1)
  resource_mgr$add_resource(test_resource_2)
  resource_mgr$add_resource(test_resource_3)

  resource_mgr$remove_resource(resource_1_name)
  testthat::expect_length(resource_mgr$get_resources(), 2)
})

test_that("the manager can load resources from disk", {
  resource_mgr <- resource_manager$new()
  file_path = "test-files/test-resources.csv"
  resource_mgr$load(file_path)

  # Test that the resources exist with the expected quantities
  corn <- resource_mgr$get_resource("maize")
  testthat::expect_equal(corn$quantity, 10)

  corn <- resource_mgr$get_resource("salmon")
  testthat::expect_equal(corn$quantity, 5)

  corn <- resource_mgr$get_resource("cashews")
  testthat::expect_equal(corn$quantity, 0)

  corn <- resource_mgr$get_resource("trout")
  testthat::expect_equal(corn$quantity, 1)
})
