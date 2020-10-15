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

test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
