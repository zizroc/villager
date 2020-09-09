library(R6)
library(tibble)
library(tidyverse)

#' @title Village Data
#' @docType class
#' @description desc
#' @details An object that represents the state of a village
#' @section Methods:
#' \itemize{
#'   \item{\code{\link{as_tibble}}}{Turns the state into a tibble}
#' }
#' @export# A class that represents Village properties at an instance in time; this is an
# object that represents the state of a village at an instance in time.
VillageState <- R6Class("VillageState", cloneable = TRUE,
                       public = list(
                         # The birth rate of villagers
                         birthRate = NA,
                         # The average death rate of villagers
                         deathRate = NA,
                         # Total number of crops that the village has
                         cropStock = NA,
                         # Maximum number of allowed population
                         carrying_capacity = NA,
                         # City's crop productivity
                         crop_productivity  = NA,
                         #Number of farmers that the village has
                         farmers = NA,
                         # Number of fishers in the village
                         fishers = NA,
                         # Catch rate for the village
                         fish_catch_rate  = NA,
                         # Total amount of fish a village has
                         fish_stock = NA,
                         # Total population that the village has
                         population = NA,
                         # Year that this slice of data belongs to
                         year = NA,

                         # Called when instantiating this object. People should be able to
                         # override most of the properties contained in this class, adding
                         # an option here is ideal.
                         initialize = function(birthRate = 0.085,
                                               deathRate = 0.070,
                                               carrying_capacity = 300,
                                               crop_productivity  = 3.0,
                                               fish_catch_rate  = 2.0,
                                               year = 1,
                                               population = 100,
                                               cropStock = 300,
                                               fish_stock = 200,
                                               farmers = 0,
                                               fishers = 0
                         ) {
                           self$birthRate  <- birthRate
                           self$deathRate  <- deathRate
                           self$carrying_capacity  <- carrying_capacity
                           self$crop_productivity  <- crop_productivity
                           self$fish_catch_rate  <- fish_catch_rate
                           self$year <- year #BCE
                           self$population <- population
                           self$cropStock <- cropStock
                           self$fish_stock <- fish_stock
                           self$farmers <-farmers
                           self$fishers <-fishers
                         },
                         as_tibble = function() {

                           return(tibble(
                             birthRate = self$birthRate,
                             deathRate = self$deathRate,
                             carrying_capacity = self$carrying_capacity,
                             crop_productivity = self$crop_productivity,
                             fish_catch_rate = self$fish_catch_rate,
                             year = self$year, #BCE
                             population = self$population,
                             cropStock = self$cropStock,
                             fish_stock = self$fish_stock,
                             farmers = self$farmers,
                             fishers = self$fishers
                           ))
                         },

                         # DEVNOTE: This method should be generalized to get any property back as a tibble
                         get_population = function () {
                           return(tibbble(name= self$population))
                         }
                       )
)
