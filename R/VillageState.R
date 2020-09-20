#' @title Village State
#' @docType class
#' @description This is an object that represents the state of a village at a particular time.
#' @details This class acts as a type of record that holds the values of the different village variables. This class can be subclassed
#' to include more variables that aren't present.
#' @section Methods:
#' @field birthRate The average birth rate of the village's citizens
#' @field deathRate The average death rate of the village's citizens
#' @field carryingCapacity The maximum number of villagers the village can sustain
#' @field cropProductivity Productivity for crops
#' @field fishCatchRate Rate of fish caught
#' @field year The year that the state represents
#' @field population The number of villagers in the village
#' @field cropStock The number of crops in the village
#' @field fishStock The number of fish in the village
#' @field farmers The number of farmers in the village
#' @field fishers The number of fishers in the village
#' @section Methods:
#' \describe{
#'   \item{\code{propagate()}}{Advances the village a single time step}
#'   \item{\code{as_tibble()}}{Turns the object into a tibble}.
#'   }
VillageState <- R6::R6Class("VillageState", cloneable = TRUE,
                        public = list(
                          birthRate = NA,
                          deathRate = NA,
                          cropStock = NA,
                          carryingCapacity = NA,
                          cropProductivity  = NA,
                          farmers = NA,
                          fishers = NA,
                          fishCatchRate  = NA,
                          fishStock = NA,
                          population = NA,
                          year = NA,

                          #' Creates a new State
                          #'
                          #' @description Initializes all of the properties in the state to the ones passed in. This should
                          #' be called by subclasses during initialization.
                          #' @details When adding a new property, make sure to add it to the tibble
                          #' representation.
                          #' @export
                          #' @param birthRate The average birth rate of the village's citizens
                          #' @param deathRate The average death rate of the village's citizens
                          #' @param carryingCapacity The maximum number of villagers the village can sustain
                          #' @param cropProductivity Productivity for crops
                          #' @param fishCatchRate Rate of fish caught
                          #' @param year The year that the state represents
                          #' @param population The number of villagers in the village
                          #' @param cropStock The number of crops in the village
                          #' @param fishStock The number of fish in the village
                          #' @param farmers The number of farmers in the village
                          #' @param fishers The number of fishers in the village
                          initialize = function(birthRate = 0.085,
                                                deathRate = 0.070,
                                                carryingCapacity = 300,
                                                cropProductivity  = 3.0,
                                                fishCatchRate  = 2.0,
                                                year = 1,
                                                population = 100,
                                                cropStock = 300,
                                                fishStock = 200,
                                                farmers = 0,
                                                fishers = 0
                          ) {
                            self$birthRate  <- birthRate
                            self$deathRate  <- deathRate
                            self$carryingCapacity  <- carryingCapacity
                            self$cropProductivity  <- cropProductivity
                            self$fishCatchRate  <- fishCatchRate
                            self$year <- year
                            self$population <- population
                            self$cropStock <- cropStock
                            self$fishStock <- fishStock
                            self$farmers <-farmers
                            self$fishers <-fishers
                          },

                          #' Returns a tibble representation of the state
                          #'
                          #' @description Sometimes it's useful to visualize the states. Tibbles are
                          #' the common data structure to hold the data. This method gives a tibble
                          #' with each property.
                          #' @export
                          #' @return Returns a tibble representation of the state
                          as_tibble = function() {

                            return(tibble::tibble(
                              birthRate = self$birthRate,
                              deathRate = self$deathRate,
                              carryingCapacity = self$carryingCapacity,
                              cropProductivity = self$cropProductivity,
                              fishCatchRate = self$fishCatchRate,
                              year = self$year,
                              population = self$population,
                              cropStock = self$cropStock,
                              fishStock = self$fishStock,
                              farmers = self$farmers,
                              fishers = self$fishers
                            ))
                          }
                        )
)
