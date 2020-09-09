# The base class for all villages.
library(R6)
library(tibble)
library(tidyverse)


BaseVillage <- R6Class("BaseVillage",
                       public = list(
                         name = NA,
                         initialState = NULL,
                         StateRecords = NA,
                         tradePartners = NA,
                         models = NULL,
                         modelData = NULL,
                         initialize = function(name = NA,
                                               initialState = NA,
                                               modelData=NULL,
                                               models = list()) {
                           if (is.null(initialState)) {
                             initialState <- VillageState$new()
                           }
                           self$name <- name
                           # Holds a list of VillageState objects. Is the record of the village's state though time. Place the initial state as the first element
                           self$StateRecords <- c(initialState$clone())
                           # Set the models
                           self$models <- models
                           # Set the data
                           self$modelData<-modelData
                           # Initialize the trade partners to an empty list
                           self$tradePartners <- list()
                         },

                         # Moves the village one step in time. Any models are run as well as any trades.
                         propagate = function(year = 1) {
                           if (year == 1) {
                             # Get a reference to the initial state so that models can mutate this
                             village_data <-self$StateRecords[[length(self$StateRecords)]]
                           } else {
                             # Create a new state representing this slice in time. Since many of the
                             # values will be the same as the previous state, clone the previous state
                             village_data <- self$StateRecords[[length(self$StateRecords)]]$clone()
                             village_data$year <- year
                           }
                           # Run each of the models
                           for (f in self$models) {
                             if (year ==1) {
                               village_data<-f(currentState=village_data, previousState=NULL, data=self$modelData)
                             } else {
                               village_data<-f(currentState=village_data, previousState=self$StateRecords[[length(self$StateRecords)]], data=self$modelData)
                             }
                           }
                           # If there's a new state, add it to the list of states
                           if (year !=1) {
                           self$StateRecords <- c(self$StateRecords, village_data)
                           }
                         },

                         # Adds a village to this village's trading partners list. To connect the other village
                         # back to this one, set addBack to TRUE.
                         add_trade_partner = function(newTradePartner, addBack=TRUE) {
                           # Note that we're adding a reference, not a clone of newTradePartner to the list.
                           # This means that modifying a village inside tradePartners will modify the original village (danger).
                           # It comes with the added benefit of cheaply storing an entire village that will always be up to date.

                           # Make sure you don't copy the empty set into tradePartners
                           if (length(self$tradePartners) < 0 ) {
                             self$tradePartners <- c(newTradePartner)
                           } else {
                             self$tradePartners <- c(self$tradePartners, newTradePartner)
                           }

                           if (addBack) {
                             # Add this village as a trade partner of newTradePartner
                             # Don't add it back as a trade partner because we've added it above
                             # You'll also get an infinite loop
                             newTradePartner$add_trade_partner(self, FALSE)
                           }
                         },

                         # The logic and reasoning to make a trade should go in here
                         trade = function() {

                         },

                         # Returns the population of the village at some time
                         # If no time is specified, return the population in the
                         # current VillageData record.
                         #
                         # @param year: The year to look at
                         # @return: The population at some year
                         get_population = function(year = NA) {

                           # If time wasn't specified,
                           if (is.na(year)) {
                             return(self$CurrentVillageDataData$population)
                           } else {
                             tryCatch(
                               {
                                 return (self$StateRecords[[year]]$population)
                               },
                               error=function(cond) {
                                 return(NA)
                               }
                             )
                           }
                         },
                         as_tibble = function() {
                           big_tibble <- tibble()
                           for (data_record in self$StateRecords) {

                             tidy_row <- data_record$as_tibble()

                             big_tibble <- bind_rows(tidy_row, big_tibble)

                           }
                           return(big_tibble)
                         },

                         # Plots a dependent variable
                         plot = function(dependent_variable = "population") {
                           # Get the data as a tibble
                           tidy_data <- self$as_tibble()
                           p <- ggplot(data=tidy_data, aes(x=year, y=!!sym(dependent_variable)))+ geom_line()
                           return (p)
                         }
                       )
)
