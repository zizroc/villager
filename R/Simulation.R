#' @title simulation
#' @docType class
#' @description Advances one or more villages through time
#' @field start_date The Gregorian date that the simulation starts on
#' @field end_date The Gregorian date that the simulation ends on
#' @field agents All of the agents in the simulation
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
                        agents = NA,

                        #' Creates a new Simulation instance
                        #'
                        #' @param start_date The date to start the simulation
                        #' @param end_date The date that the simulation should end
                        #' @param agents A list of agents that will be simulated
                        initialize = function(start_date,
                                              end_date,
                                              agents) {
                          self$agents <- agents
                          self$start_date <- gregorian::as_gregorian(start_date)
                          self$end_date <- gregorian::as_gregorian(end_date)
                        },

                        #' Runs the simulation
                        #'
                        #' @return None
                        run_model = function() {
                          total_days <- gregorian::diff_days(self$start_date, self$end_date)

                          # Loop over each agent and run the user defined initial condition function
                          current_date <- gregorian::add_days(self$start_date, 1)
                          date_diff <- gregorian::diff_days(current_date, self$end_date)
                          total_days_passed <- 1
                          while (date_diff >= 0) {
                          # Iterate the villages a single timestep
                            for(single_agent in self$agents) {
                              single_agent$propagate(current_date, total_days_passed)
                              total_days_passed <- total_days_passed + 1
                            }
                            # Add '1' to the current day
                            current_date <- gregorian::add_days(current_date, 1)
                            date_diff <- gregorian::diff_days(current_date, self$end_date)

                          }
                        }
                      )
)
