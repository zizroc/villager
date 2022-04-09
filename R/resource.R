#' @title resource
#' @docType class
#' @description This is an object that represents a single resource.
#' @field name The name of the resource
#' @field quantity The quantity of the resource that exists
#' @export
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new resource}
#'   \item{\code{as_table()}}{Represents the current state of the resource as a tibble}
#'   }
resource <- R6::R6Class("resource",
  cloneable = TRUE,
  public = list(
    name = NA,
    quantity = NA,

    #' Creates a new resource.
    #'
    #' @description Creates a new resource object
    #' @param name The name of the resource
    #' @param quantity The quantity present
    initialize = function(name = NA, quantity = 0) {
      self$name <- name
      self$quantity <- quantity
    },

    #' Returns a data.frame representation of the resource
    #'
    #' @return A data.frame of resources

    as_table = function() {
      return(data.frame(name = self$name, quantity = self$quantity))
    }
  )
)
