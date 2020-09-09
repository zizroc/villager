Simulation <- R6Class("Simulation",
                      public = list(
                        name = NA,
                        villages = NA,
                        length = NA,

                        #' Creates a new Simulation instance
                        #'
                        #' @param name An optional name for the simulator
                        #' @param length The number of years to run the simulation for
                        #' @param villages A list of villages that will be simulated
                        initialize = function(name = NA,
                                              length = NA,
                                              villages = NULL) {
                          self$name <- name
                          self$villages <- villages
                          self$length <- length
                        },

                        #' Advances each village a single time step
                        #'
                        #' @description This this how the simulator 'runs' through the simulation
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
                        #' @param dependent_variable The
                        #' @return None
                        show_results = function(dependent_variable = "population") {
                          for (village in self$villages) {
                            print(village$plot(dependent_variable))
                          }
                        }
                      )
)
