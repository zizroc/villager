#' @title Simulator
#' @docType class
#' @description Advances one or more villages through time
#' @field villages A list of villages that the simulator will run
#' @field length The number of time steps in the simulation
#' @export
#' @section Methods:
#' \describe{
#'   \item{\code{run_model()}}{Runs the simulation}
#'   \item{\code{show_results(dependent_variable)}}{Displays the time dependant variables post-simulation}.
#'   }
Simulation <- R6::R6Class("Simulation",
                      public = list(
                        villages = NA,
                        length = NA,

                        #' Creates a new Simulation instance
                        #'
                        #' @export
                        #' @param length The number of years to run the simulation for
                        #' @param villages A list of villages that will be simulated
                        initialize = function(length = NA,
                                              villages = NULL) {
                          self$villages <- villages
                          self$length <- length
                        },

                        #' Advances each village a single time step
                        #'
                        #' @description This this how the simulator 'runs' through the simulation
                        #'
                        #' @export
                        #' @return None
                        run_model = function() {
                          for (village in self$villages) {
                            for(t in 1:self$length){
                              village$propagate(year=t)
                            }
                          }
                        },

                        #' Prints the plots of the data from each village in the simulator
                        #'
                        #' @details This should be done better; the plots look like garbage
                        #' @export
                        #' @param dependent_variable The
                        #' @return None
                        show_results = function(dependent_variable = "population") {
                          for (village in self$villages) {
                            print(village$plot(dependent_variable))
                          }
                        }
                      )
)
