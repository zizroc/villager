#' @export
#' @title simulation
#' @docType class
#' @description Advances one or more villages through time
#' @field length The total number of time steps that the simulation runs for
#' @field villages A list of villages that the simulator will run
#' @field writer An instance of a data_writer class for writing village data to disk
#' @section Methods:
#' \describe{
#'   \item{\code{run_model()}}{Runs the simulation}
#'   }
simulation <- R6::R6Class("simulation",
  public = list(
    length = NA,
    village_mgr = NA,
    writer = NA,

    #' Creates a new Simulation instance
    #'
    #' @description Creates a new simulation object to control the experiment
    #' @param length The number of steps the simulation takes
    #' @param villages A list of villages that will be simulated
    #' @param writer The data writer to be used with the villages
    initialize = function(length,
                          villages,
                          writer = villager::data_writer$new()) {
      self$village_mgr <- village_manager$new(villages)
      self$length <- length
      self$writer <- writer
    },

    #' Runs the simulation
    #'
    #' @return None
    run_model = function() {
      for (village in self$village_mgr$get_villages()) {
        village$set_initial_state()
      }
      # Loop over each village and run the user defined initial condition function. Index off of 1 because the
      # initial condition is set at 0
      current_step <- 1
      while (current_step <= self$length) {
        # Iterate the villages a single time step
        for (village in self$village_mgr$get_villages()) {
          village$propagate(current_step, self$village_mgr)
          self$writer$write(village$current_state, village$name)
        }
        current_step <- current_step + 1
      }
    }
  )
)
