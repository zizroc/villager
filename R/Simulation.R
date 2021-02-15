#' @title simulation
#' @docType class
#' @description Advances one or more villages through time
#' @field start_date The Gregorian date that the simulation starts on
#' @field end_date The Gregorian date that the simulation ends on
#' @field villages A list of villages that the simulator will run
#' @export
#' @section Methods:
#' \describe{
#'   \item{\code{run_model()}}{Runs the simulation}
#'   \item{\code{show_results(dependent_variable)}}{Displays the time dependant variables post-simulation}.
#'   }
simulation <- R6::R6Class("simulation",
                      public = list(
                        start_date = NA,
                        end_date = NA,
                        villages = NA,

                        #' Creates a new Simulation instance
                        #'
                        #' @param start_date The date to start the simulation
                        #' @param end_date The date that the simulation should end
                        #' @param villages A list of villages that will be simulated
                        initialize = function(start_date,
                                              end_date,
                                              villages) {
                          self$villages <- villages
                          self$start_date <- gregorian::as_gregorian(start_date)
                          self$end_date <- gregorian::as_gregorian(end_date)
                        },

                        #' Runs the simulation
                        #'
                        #' @return None
                        run_model = function() {
                          for (village in self$villages) {
                            village$set_initial_state(self$start_date)
                          }
                          # Loop over each village and run the user defined initial condition function
                          current_date <- gregorian::add_days(self$start_date, 1)
                          date_diff <- gregorian::diff_days(current_date, self$end_date)
                          while (date_diff >= 0) {
                          # Iterate the villages a single timestep
                            for(village in self$villages){
                              village$propagate(current_date)
                            }
                            # Add '1' to the current day
                            current_date <- gregorian::add_days(current_date, 1)
                            date_diff <- gregorian::diff_days(current_date, self$end_date)

                          }
                        },

                        #' Prints the plots of the data from each village in the simulator
                        #'
                        #' @details This should be done better; the plots look like garbage
                        #' @param dependent_variable The
                        #' @return None
                        show_results = function(dependent_variable = "population") {
                          for (village in self$villages) {
                            print(village$plot(dependent_variable))
                          }
                        }
                      )
)
