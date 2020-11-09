#' @export
#' @title Village State
#' @docType class
#' @description This is an object that represents the state of a village at a particular time.
#' @details This class acts as a type of record that holds the values of the different village variables. This class can be subclassed
#' to include more variables that aren't present.
#' @field name An optional name for the village
#' @field initialState The initial state that the village has
#' @field StateRecords A list of state objects, one for each time step
#' @field tradePartners A list of villages that this village can trade with
#' @field models A list of functions or a single function that should be run at each timestep
#' @field modelData Optional data that models may need
#' @field population_manager The manager that handles all of the winiks
#' @field resource_mgr The manager that handles all of the resources
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new village}
#'   \item{\code{propagate()}}{Advances the village a single time step}
#'   \item{\code{add_trade_partner(newTradePartner, addBack)}}{Adds a trde partner}.
#'   \item{\code{trade()}}{Executes a trade at a time step}.
#'   \item{\code{as_tibble()}}{Adds a trde partner}.
#'   \item{\code{plot()}}{Plots the time dependant variables}.
#'   }
BaseVillage <- R6::R6Class("BaseVillage",
                       public = list(
                         name = NA,
                         initialState = NULL,
                         StateRecords = NA,
                         tradePartners = NA,
                         models = NULL,
                         modelData = NULL,
                         population_manager = NULL,
                         resource_mgr = NULL,

                         #' Initializes a village
                         #'
                         #' @description This method is meant to set the variables that are needed for a village to propagate through
                         #' time.
                         #' @details Any villages that derive this class should call this method's initialize method.
                         #' @param name An optional name for the village
                         #' @param initialState A VillageSTate object that will be used as the village's initial state
                         #' @param models A list of functions or a single function that should be run at each timestep
                         #' @param modelData Optional data that models may need
                         #' @param population_manager A population manager that may have winiks inside
                         initialize = function(name = NA,
                                               initialState = NULL,
                                               models = list(),
                                               modelData=NULL,
                                               population_manager=NULL) {

                           if (is.null(population_manager))
                             self$population_manager <- winik_manager$new()
                           self$resource_mgr <- resource_manager$new()
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
                         #' @export
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
                               # At year==1 there won't be a previous_state, set it to NULL
                               model(currentState=village_data, previousState=NULL, modelData=self$modelData,
                                     population_manager=self$population_manager, resource_mgr=self$resource_mgr)
                             } else {
                               previous_state_copy <- self$StateRecords[[length(self$StateRecords)]]$clone(deep=TRUE)
                               model(currentState=village_data, previousState=previous_state_copy, modelData=self$modelData,
                                     population_manager=self$population_manager, resource_mgr=self$resource_mgr)
                               }
                           }
                           # If there's a new state, add it to the list of states
                           if (year != 1) {
                           self$StateRecords <- c(self$StateRecords, village_data)
                           }

                           village_data$winik_states <- self$population_manager$get_states()
                           village_data$resource_states <- self$resource_mgr$get_states()

                         },

                         #' Connects two villages so that they can trade with each other.
                         #'
                         #' @description Connects two villages together for trade
                         #' @details This method takes advantage of R6's reference semantics. Because classes that are derived
                         #' from BaseVillage are R6, they can be directly modified. This
                         #'
                         #' @export
                         #' @param newTradePartner A derived BaseVillage object representing a village that this village
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
                         #' @name trade
                         #' @description Executes a village's trade
                         #'
                         #' @export
                         trade = function() {

                         },

                        #' @description Gives a tibbble representation of the state
                        #' @export
                        #' @return Returns a tibble composing of rows which are
                        #' properties from VillageState.
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
                         #' @export
                         #' @return Returns a ggplot object representing the plot
                         plot = function(dependent_variable = "population") {
                           # Get the data as a tibble
                           tidy_data <- self$as_tibble()
                           p <- ggplot2::ggplot(data=tidy_data, ggplot2::aes(x=year, y=!!rlang::sym(dependent_variable)))+ ggplot2::geom_line()
                           return (p)
                         }
                       )
)
