# Unit tests for the simulation engine

test_that("The consrtructor works", {
  village = BaseVillage$new(name="Random Population Village")

  mayanSimulation <- Simulation$new(length=10, #years
                                    villages=c(village))
  testthat::expect_length(mayanSimulation$villages, 1)
  testthat::expect_equal(mayanSimulation$length, 10)
})

test_that("the number of villages added is correct", {
  coastal_village <- BaseVillage$new()
  simulator <- Simulation$new(length = 3, villages = list(coastal_village))
  testthat::expect_length(simulator$villages, 1)

  # Check with a second village
  plains_village  <- BaseVillage$new()
  valley_village  <- BaseVillage$new()
  new_siumulator <- Simulation$new(length = 3, villages = list(valley_village, plains_village))
  print(length(new_siumulator$villages))
  testthat::expect_length(new_siumulator$villages, 2)
})
