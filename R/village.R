#' @export
#' @title Village
#' @docType class
#' @description This is an object that represents the state of a village at a particular time.
#' @details This class acts as a type of record that holds the values of the different village variables. This class can be subclassed
#' to include more variables that aren't present.
#' @field name An optional name for the village
#' @field initial_condition A function that sets the initial state of the village
#' @field StateRecords A list of state objects, one for each time step
#' @field tradePartners A list of villages that this village can trade with
#' @field models A list of functions or a single function that should be run at each timestep
#' @field model_data Optional data that models may need
#' @field winik_mgr The manager that handles all of the winiks
#' @field resource_mgr The manager that handles all of the resources
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new village}
#'   \item{\code{propagate()}}{Advances the village a single time step}
#'   \item{\code{set_initial_state()}}{Initializes the initial state of the village}
#'   \item{\code{add_trade_partner(newTradePartner, addBack)}}{Adds a trde partner}.
#'   \item{\code{trade()}}{Executes a trade at a time step}.
#'   \item{\code{as_tibble()}}{Adds a trde partner}.
#'   \item{\code{plot()}}{Plots the time dependant variables}.
#'   }
village <- R6::R6Class("village",
                       public = list(
                         name = NA,
                         initial_condition = NA,
                         StateRecords = NA,
                         tradePartners = NA,
                         models = NULL,
                         model_data = NULL,
                         winik_mgr = NULL,
                         resource_mgr = NULL,

                         #' Initializes a village
                         #'
                         #' @description This method is meant to set the variables that are needed for a village to propagate through
                         #' time.
                         #' @details Any villages that derive this class should call this method's initialize method.
                         #' @param name An optional name for the village
                         #' @param initial_condition A function that gets called on the first timestep
                         #' @param models A list of functions or a single function that should be run at each timestep
                         initialize = function(name,
                                               initial_condition,
                                               models = list()) {
                           self$initial_condition <- initial_condition
                           self$winik_mgr <- winik_manager$new()
                           self$resource_mgr <- resource_manager$new()
                           # Check to see if the user supplied a single model, outside of a list
                           # If so, put it in a vector because other code expects 'models' to be a list
                           if(!is.list(models) && !is.null(models)) {
                             self$models<-list(models)
                           } else {
                             self$models<-models
                           }

                           self$name <- name
                           # Creates an empty state that the initial condition will populate
                           self$StateRecords <- NULL
                           # Set the data
                           self$model_data<-model_data$new()
                           # Initialize the trade partners to an empty list
                           self$tradePartners <- list()
                         },

                         #' Utility method for optimizing particular aspects of the village class
                         #' @details In particalr, it's used to set the size of large vectors
                         #' @param simulation_days The number of days that the simulation will run for
                         optimize = function(simulation_days) {
                          self$StateRecords <- vector(mode="list", length=simulation_days)
                         },

                         #' Propagates the village a single time step
                         #'
                         #' @details This method is used to advance the village a single timestep. It should NOT be used
                         #' to set initial conditions. See the set_initial_state method.
                         #' @param date The date that the village is computing the new state for
                         #' @param total_days_passed Number of days that have passed since the village's creation
                         #' @return None
                         propagate = function(date, total_days_passed) {
                           # Create a new state representing this slice in time. Since many of the
                           # values will be the same as the previous state, clone the previous state
                           village_data <- self$StateRecords[[total_days_passed]]$clone(deep=TRUE)
                           # Update the date in the state record to reflect the current date
                           village_data$date <- date
                           self$winik_mgr$propagate()
                           # Run each of the models
                           for (model in self$models) {
                             # Create a read only copy of the last state so that users can make decisions off of it
                               previous_state_copy <- self$StateRecords[[total_days_passed]]$clone(deep=TRUE)
                               model(village_data, previous_state_copy, self$model_data, self$winik_mgr, self$resource_mgr)
                           }
                           village_data$winik_states <- self$winik_mgr$get_states()
                           village_data$resource_states <- self$resource_mgr$get_states()
                           self$StateRecords[[total_days_passed+1]] <- village_data
                         },

                         #' Connects two villages so that they can trade with each other.
                         #'
                         #' @description Connects two villages together for trade
                         #' @details This method takes advantage of R6's reference semantics. Because classes that are derived
                         #' from village are R6, they can be directly modified.
                         #' @param newTradePartner A derived village object representing a village that this village
                         #' can trade with
                         #' @param addBack An optional parameter that, when true will
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
                         #' @name trade
                         #' @description Executes a village's trade
                         #'
                         trade = function() {

                         },

                         #' Runs the user defined function that sets the initial state of the village
                         #'
                         #' @description Runs the initial condition model
                         #' @param date The date that the the initial condition represents
                         set_initial_state = function(date) {
                           self$StateRecords[[1]] <- village_state$new()
                           self$initial_condition(self$StateRecords[[1]], self$model_data, self$winik_mgr, self$resource_mgr)
                           self$StateRecords[[1]]$winik_states <- self$winik_mgr$get_states()
                           self$StateRecords[[1]]$resource_states <- self$resource_mgr$get_states()
                           self$StateRecords[[1]]$date <- date
                          },

                        #' @description Gives a tibble representation of the state
                        #' @return Returns a tibble composing of rows which are
                        #' properties from village_state
                         as_tibble = function() {
                           big_tibble <- tibble::tibble()
                           for (data_record in self$StateRecords) {
                             tidy_row <- data_record$as_tibble()
                             big_tibble <- dplyr::bind_rows(tidy_row, big_tibble)

                           }
                           return(big_tibble)
                         },

                         #' Plots a dependent variable against time
                         #' @description This method can be used to quickly spot check various dependent
                         #' variables.
                         #' @param dependent_variable The variable name that should be plotted
                         #' @return Returns a ggplot object representing the plot
                         plot = function(dependent_variable = "population") {
                           # Get the data as a tibble
                           tidy_data <- self$as_tibble()
                           p <- ggplot2::ggplot(data=tidy_data, ggplot2::aes(x=year, y=!!rlang::sym(dependent_variable)))+ ggplot2::geom_line()
                           return (p)
                         }
                       )
)
