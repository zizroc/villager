#' R6 Class representing data that's external from resources and winiks
#'
#' It contains a single variable, 'events' for when the data holds a list of events
model_data <- R6::R6Class("model_data",
                          public = list(
                            #' @field events Any events that need to be tracked
                            events=NULL,
                            #' @description Creates a new model_data object
                            #' @return A new model data object
                            initialize = function() {
                              self$events <- list()
                            }
                          ))
