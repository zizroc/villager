# Unit tests for the data_writer

test_that("the constructor properly saves the parameters", {
  # Create a data writer with default values
  results_dir <- "./test_results"
  villagers_file <- "my_villagers.csv"
  resources_file <- "my_resources.csv"
  writer <- data_writer$new(results_dir, villagers_file, resources_file)

  testthat::expect_equal(writer$results_directory, results_dir)
  testthat::expect_equal(writer$winik_filename, villagers_file)
  testthat::expect_equal(writer$resource_filename, resources_file)
})

test_that("the default village states are properly saved to disk for an individual day", {
  # Create a data writer with default values
  writer <- data_writer$new("./test_results", "my_villagers.csv", "my_resources.csv")
  test_env <- readRDS("test-files/small_village_single_day.rds")
  state_to_write <- test_env$current_state
  writer$write(state_to_write, "test_village")

  # Read the data back
  winiks <- read.csv("./test_results/test_village/my_villagers.csv")
  resources <- read.csv("./test_results/test_village/my_resources.csv")
  testthat::expect_equal(winiks, state_to_write$winik_states)
})
