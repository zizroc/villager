#' @title simulation
#' @docType class
#' @description Advances one or more villages through time
#' @field start_date The Gregorian date that the simulation starts on
#' @field end_date The Gregorian date that the simulation ends on
#' @field villages A list of villages that the simulator will run
#' @field writer An instance of a data_writer class for writing village data to disk
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
                        writer=NA,

                        #' Creates a new Simulation instance
                        #'
                        #' @description Creates a new simulation object to control the experiment
                        #' @param start_date The date to start the simulation
                        #' @param end_date The date that the simulation should end
                        #' @param villages A list of villages that will be simulated
                        #' @param writer The data writer to be used with the villages
                        initialize = function(start_date,
                                              end_date,
                                              villages,
                                              writer=data_writer$new()) {
                          self$villages <- villages
                          self$start_date <- gregorian::as_gregorian(start_date)
                          self$end_date <- gregorian::as_gregorian(end_date)
                          self$writer <- writer
                        },

                        #' Runs the simulation
                        #'
                        #' @return None
                        run_model = function() {
                          total_days <- gregorian::diff_days(self$start_date, self$end_date)
                          for (village in self$villages) {
                            village$set_initial_state(self$start_date)
                          }
                          # Loop over each village and run the user defined initial condition function
                          current_date <- gregorian::add_days(self$start_date, 1)
                          date_diff <- gregorian::diff_days(current_date, self$end_date)
                          total_days_passed <- 1
                          while (date_diff >= 0) {
                          # Iterate the villages a single time step
                            for(village in self$villages) {
                              village$propagate(current_date, total_days_passed)
                              #self$writer$write(village$current_state)
                              total_days_passed <- total_days_passed + 1
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
