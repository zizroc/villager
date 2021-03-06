#' @export
#' @title Model Data
#' @docType class
#' @description This is an object that holds model data
#' @details This class that holds misc fields that are used in models
#' @field events A list of events
#' @section Methods:
#' \describe{
#'   }
model_data <- R6::R6Class("model_data",
                     public = list(events=NULL,
                                   #' Create a new model_data
                                   #'
                                   #' @description Used to created new model data objects.
                                   #'
                                   #' @export
                                   #' @return A new model data object
                                   initialize = function() {
                                     self$events <- list()
                                   }
                     ))
