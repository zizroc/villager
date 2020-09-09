# The base class for all villages.
library(R6)
library(tibble)
library(tidyverse)

#' @title Village State
#' @docType class
#' @description This is an object that represents the state of a village at a particular time.
#' @details This class acts as a type of record that holds the values of the different village variables. This class can be subclassed
#' to include more variables that aren't present.
#' @import R6
#' @section Methods:
#' \itemize{
#'   \item{\code{\link{initialize}}}{Creates a new instance of the village}
#'   \item{\code{\link{as_tibble}}}{Get all of the village's states as a tibble}
#'   \item{\code{\link{add_trade_partner}}}{Connects two villages for trade}
#'   \item{\code{\link{trade}}}{Executes trades}
#'   \item{\code{\link{plot}}}{Plots a single village property over time}
#' }
BaseVillage <- R6Class("BaseVillage",
                       public = list(
                         name = NA,
                         initialState = NULL,
                         StateRecords = NA,
                         tradePartners = NA,
                         models = NULL,
                         modelData = NULL,

                         #' Initializes a village
                         #'
                         #' @description This method is meant to set the variables that are needed for a village to propagate through
                         #' time.
                         #' @details Any villages that derive this class should call this method's initialize method.
                         #' @param name An optional name for the village
                         #' @param iniitalState A VillageSTate object that will be used as the village's initial state
                         #' @param models A list of functions or a single function that should be run at each timestep
                         #' @param modelData
                         initialize = function(name = NA,
                                               initialState = NULL,
                                               models = list(),
                                               modelData=NULL) {

                           # If the initial state wasn't set, set one.
                           # DEVNOTE: Do we want to allow that?
                           # if (is.null(initialState)) {
                           #   initialState <- VillageState$new()
                           # }

                           # Check to see if the user supplied a single model, outside of a list
                           # If so, put it in a vector because other code expects 'models' to be a list
                           if(!is.list(models) && !is.null(models)) {
                             self$models<-list(models)
                           } else {
                             self$models<-models
                           }
                           self$name <- name
                           # Holds a list of VillageState objects. Is the record of the village's state though time. Place the initial state as the first element
                           self$StateRecords <- c(initialState$clone())
                           # Set the data
                           self$modelData<-modelData
                           # Initialize the trade partners to an empty list
                           self$tradePartners <- list()
                         },

                         #' Propagates the village a single time step
                         #'
                         #' @param year The year that the village is computing the new state for
                         #' @return None
                         propagate = function(year = 1) {
                           if (year == 1) {
                             # The state should already exist as the village's initial condition
                             # Get a reference to the initial state so that the user defined models can mutate it
                             village_data <-self$StateRecords[[length(self$StateRecords)]]
                           } else {
                             # Create a new state representing this slice in time. Since many of the
                             # values will be the same as the previous state, clone the previous state
                             village_data <- self$StateRecords[[length(self$StateRecords)]]$clone(deep=TRUE)
                           }
                           # Update the year in the state record
                           village_data$year <- year
                           # Run each of the models
                           for (model in self$models) {
                             if (year == 1) {
                               # At year==1 there won't be a previousState, set it to NULL
                               model(currentState=village_data, previousState=NULL, modelData=self$modelData)
                             } else {
                               model(currentState=village_data, previousState=self$StateRecords[[length(self$StateRecords)]], modelData=self$modelData)
                               }
                           }
                           # If there's a new state, add it to the list of states
                           if (year != 1) {
                           self$StateRecords <- c(self$StateRecords, village_data)
                           }
                         },

                         #' Connects two villages so that they can trade with each other.
                         #'
                         #' @description
                         #' @details This method takes advantage of R6's reference semantics. Because classes that are derived
                         #' from BaseVillage are R6, they can be directly modified. This
                         #'
                         #' @pram newTradePartner A derived BaseVillage object representing a village that this village
                         #' can trade with
                         #' @param addBack An optional parameter that, when true will
                         #'
                         add_trade_partner = function(newTradePartner, addBack=TRUE) {

                           # Make sure you don't copy the empty set into tradePartners
                           if (length(self$tradePartners) < 0 ) {
                             self$tradePartners <- c(newTradePartner)
                           } else {
                             self$tradePartners <- c(self$tradePartners, newTradePartner)
                           }

                           if (addBack) {
                             # Check if the other village should be connected back to this one
                             newTradePartner$add_trade_partner(self, FALSE)
                           }
                         },

                         #' Runs the village's trade algorithms
                         #'
                         #'
                         #'
                         trade = function() {

                         },

                        #' Get a tibble representation of a village
                        #'
                        #'
                        #' @return Returns a tibble composing of rows which are
                        #' properties from VillageState.
                         as_tibble = function() {
                           big_tibble <- tibble()
                           for (data_record in self$StateRecords) {
                             tidy_row <- data_record$as_tibble()
                             big_tibble <- bind_rows(tidy_row, big_tibble)

                           }
                           return(big_tibble)
                         },

                         #' Plots a dependent variable against time
                         #' @description This method can be used to quickly spot check various dependent
                         #' variables.
                         #'
                         #' @return Returns a ggplot object representing the plot
                         plot = function(dependent_variable = "population") {
                           # Get the data as a tibble
                           tidy_data <- self$as_tibble()
                           p <- ggplot(data=tidy_data, aes(x=year, y=!!sym(dependent_variable)))+ geom_line()
                           return (p)
                         }
                       )
)
