#' @title resource
#' @docType class
#' @description This is an object that represents a single resource
#' @details This class abstracts the idea of a resource
#' @field name The name of the resource
#' @field quantity The quantity of the resource held
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new resource}
#'   \item{\code{as_tibble()}}{Represents the current state of the resource as a tibble}
#'   }
resource <- R6::R6Class("resource",
                        cloneable = TRUE,
                        public = list(
                          name = NA,
                          quantity = NA,

                          #' Creates a new resource
                          #'
                          #' @description Creates a new resource object
                          #' @param name The name of the resource
                          #' @param quantity The quantity present
                          initialize = function(name=NA, quantity=0) {
                            self$name <- name
                            self$quantity <- quantity
                          },

                          #' Returns a tibble representation of the resource
                          #'
                          #' @export
                          #' @return A tibble representation of the resource
                          as_tibble = function() {
                            return(tibble::tibble(
                              name = self$name,
                              quantity = self$quantity
                            ))
                          }
                        )
)
