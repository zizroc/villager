#' @export
#' @title Trade Manager
#' @docType class
#' @description This object manages trade between villages
#' @details This class acts as an abstraction for handling trade events
#' @field trade_events A list of trade_event objects
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new manager}
#'   \item{\code{get_resource()}}{Retrieves a trade_event from the manager}
#'   \item{\code{add_resource()}}{Adds a trade_event to the manager}
#'   \item{\code{remove_trade()}}{Removes a trade_event from the manager}
#'   \item{\code{get_trade_index()}}{Retrieves the index of the trade_event}
#'   \item{\code{get_states()}}{Returns a list of states}
#'   }
trade_manager <- R6::R6Class("trade_manager",
                                public = list(trade_events = NULL,

                                              #' Creates a new resource manager
                                              #'
                                              #' @description Used to create a new manager to handle trade
                                              initialize = function() {
                                                self$resources <- vector()
                                              },

                                              #' Gets a resource given a resource name
                                              #'
                                              #' @param name The name of the requested resource
                                              #' @return A resource object
                                              get_resource = function(name) {
                                                for (res in self$resources)
                                                  if (res$name == name)
                                                    return (res)
                                              },

                                              #' Adds a resource to the manager.
                                              #'
                                              #' @param new_resource The resource to add
                                              #' @return None
                                              add_resource = function(new_resource) {
                                                self$resources <- append(self$resources, new_resource)
                                              },

                                              #' Removes a resource from the manager
                                              #'
                                              #' @param name The name of the resource being removed
                                              #' @return None
                                              remove_resource = function(name) {
                                                resource_index <- self$get_resource_index(name)
                                                self$resources<-self$resources[- resource_index]
                                              },

                                              #' Returns the index of a resource in the internal resource list
                                              #'
                                              #' @param name The name of the resource being located
                                              #' @return The index in the list, or R's default return value
                                              get_resource_index = function(name) {
                                                for (i in seq_along(length(self$resources))) {
                                                  if (self$resources[[i]]$name == name) {
                                                    return (i)
                                                  }
                                                }
                                              },

                                              #' Returns a vector of resources represented as tibbles
                                              #'
                                              #' @return A list of data frames
                                              get_states = function() {
                                                vector_states = vector(length = length(self$resources))
                                                # Create a data frame to hold the states
                                                for (res in self$resources)
                                                  vector_states <- append(vector_states, res$as_tibble())
                                              }
                                ))
