# Integrated unit tests


test_that("winiks profession can change based on age", {

  initial_condition <- function(currentState, modelData, winik_manager, resource_mgr) {
    # 40 years old male
    winik_manager$add_winik(winik$new(identifier = "male1", age=14610, alive=TRUE, gender="Male"))
    # 20 year old male
    winik_manager$add_winik(winik$new(identifier = "male2", age=7305, alive=TRUE, gender="Male"))
    # 13 year old female
    winik_manager$add_winik(winik$new(identifier = "female1", age=4748, alive=TRUE, gender="Female"))
    # 8 year old female
    winik_manager$add_winik(winik$new(identifier = "female2", age=2292, alive=TRUE, gender="Female"))
  }

  winik_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    # Get the new list of living winiks and assign professions
    for (living_winik in winik_mgr$get_living_winiks()) {
      if (living_winik$age >= 14610) {
        living_winik$profession <- "Forager"
      } else if (living_winik$age >= 3287 && living_winik$age < 14610 && living_winik$gender == "Male") {
        living_winik$profession <- "Fisher"
      } else if (living_winik$age >= 5113 && living_winik$age <= 14610 && living_winik$gender == "Female") {
        living_winik$profession <- "Farmer"
      } else if (living_winik$age >= 5113 && living_winik$age <= 5113 && living_winik$gender == "Female") {
        living_winik$profession <- "Fisher"
      } else if (living_winik$age < 3287) {
        living_winik$profession <- "Child"
      }
    }
  }

  # Create a default village
  plains_village  <- village$new("Test Village", initial_condition, models=winik_model)
  # Run the simulationn for a year so that the winiks get assigned new professionns
  new_siumulator <- simulation$new(start_date="100-01-01", end_date = "101-01-01", villages = list(plains_village))
  new_siumulator$run_model()

  # Check to see that the professions are correct
  village_winik_mgr <- new_siumulator$villages[[1]]$winik_mgr
  print(plains_village$StateRecords[[1]]$winik_states)
  print(village_winik_mgr$get_winik("male1"))
  print(village_winik_mgr$get_winik("male1")$profession)
  print(village_winik_mgr$get_winik("male1")$profession)
  print(village_winik_mgr$get_winik("male1")$profession)

  testthat::expect_equal(village_winik_mgr$get_winik("male1")$profession, "Forager")
  testthat::expect_equal(village_winik_mgr$get_winik("male2")$profession, "Fisher")
  testthat::expect_equal(village_winik_mgr$get_winik("female1")$profession, "Farmer")
  testthat::expect_equal(village_winik_mgr$get_winik("female2")$profession, "Child")

})
