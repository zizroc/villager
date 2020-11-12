#' @title trade_event
#' @docType class
#' @description This is an object that represents a single trade_event (e.g., transaction)
#' @details This class abstracts the idea of a trade_event
#' @field name The name of the trade_event
#' @field quantity The quantity of the resource held
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new trade_event}
#'   \item{\code{as_tibble()}}{Represents the current state of the trade_event as a tibble}
#'   }
trade_event <- R6::R6Class("trade_event",
                        cloneable = TRUE,
                        public = list(
                          identifier  = NA,
                          type        = NA,
                          sell_value  = NA,
                          buy_value   = NA,
                          #' Creates a new trade_event
                          #' @description Creates a new trade_event object
                          #' @param name The name of the trade_event
                          #' @param sell_value The quantity present
                          #' @param buy_value The quantity
                          initialize = function(identifier = NA,
                                                sell_value = 0,
                                                buy_value  = 0) {
                            self$identifier <- identifier
                            self$sell_value <- sell_value
                            self$buy_value  <- buy_value
                          },

                          #' Returns a tibble representation of the trade_event
                          #'
                          #' @export
                          #' @return A tibble representation of the resource
                          as_tibble = function() {
                            return(tibble::tibble(
                              identifier = self$identifier,
                              sell_value = self$sell_value,
                              buy_value  = self$buy_value
                            ))
                          }
                        )
)
