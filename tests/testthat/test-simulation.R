# Unit tests for the simulation engine

test_that("The consrtructor works", {
  village_initial_condition = VillageState$new()
  village = BaseVillage$new(name="Random Population Village",
                            initialState=village_initial_condition)

  mayanSimulation <- Simulation$new(length=10, #years
                                    villages=c(village))

  expect_true (length(mayanSimulation$villages) > 0)
  expect_true (mayanSimulation$length == 10)
})

test_that("the number of villages added is correct", {
  new_state <- VillageState$new()
  coastal_village <- BaseVillage$new(initialState=new_state)
  simulator <- Simulation$new(length = 3, villages = list(coastal_village))
  testthat::expect_length(simulator$villages, 1)

  # Check with a second village
  plains_village  <- BaseVillage$new(initialState=new_state)
  valley_village  <- BaseVillage$new(initialState=new_state)
  new_siumulator <- Simulation$new(length = 3, villages = list(valley_village, plains_village))
  print(length(new_siumulator$villages))
  testthat::expect_length(new_siumulator$villages, 2)
})
