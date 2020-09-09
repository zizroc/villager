Simulation <- R6Class("Simulation",
                      public = list(
                        name = NA,
                        villages = NA,
                        length = NA,
                        initialize = function(name = NA,
                                              length = NA,
                                              villages = list()) {
                          self$name <- name
                          self$villages <- villages
                          self$length <- length
                        },
                        run_model = function(val) {
                          for (village in self$villages) {
                            for(t in 1:self$length){
                              village$propagate(year=t)
                            }
                          }
                        },
                        show_results = function(dependent_variable = "population") {
                          for (village in self$villages) {
                            print(village$plot(dependent_variable))
                          }
                        }
                      )
)