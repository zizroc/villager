#' @export
#' @title Model Data
#' @docType class
#' @description This is an object that holds data meant to persist outside ofe the model itself.
#' @details Sometimes a model event occurs without any great description in the villager framework. When this happens
#' an alternative to subclassing is by placing the data in the model_data instance which can be accessed each day.
#' @field events A list of events
#' @section Methods:
#' \describe{
#'   }
model_data <- R6::R6Class("model_data",
                     public = list(events=NULL,
                                   #' Create a new model_data
                                   #'
                                   #' @description Instantiates a model_data class.
                                   #' @return A new model data object
                                   initialize = function() {
                                     self$events <- list()
                                   }
                     ))
