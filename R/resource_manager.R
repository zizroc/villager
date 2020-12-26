#' @export
#' @title Resource Manager
#' @docType class
#' @description This object manages all of the resources in a village
#' @details This class acts as an abstraction for handling many resources
#' @field resources A list of resource objects
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new manager}
#'   \item{\code{get_resource()}}{Retrieves a resource from the manager}
#'   \item{\code{add_resource()}}{Adds a resource to the manager}
#'   \item{\code{remove_resource()}}{Removes a resource from the manager}
#'   \item{\code{get_resource_index()}}{Retrieves the index of the resource}
#'   \item{\code{get_states()}}{Returns a list of states}
#'   \item{\code{load()}}{Loads a csv file of resources and adds them to the manager.}
#'   }
resource_manager <- R6::R6Class("resource_manager",
                                public = list(resources = NULL,

                                              #' Creates a new resource manager
                                              #'
                                              #' @description Used to create a new manager to handle resources
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
                                                for (i in 1:length(self$resources)) {
                                                  if (self$resources[[i]]$name == name) {
                                                    return (i)
                                                  }
                                                }
                                              },

                                              #' Returns a vector of resources represented as tibbles
                                              #'
                                              #' @return A list of data frames
                                              get_states = function() {
                                                # Create a data frame to hold the states
                                                state_tibble <- tibble::tibble()
                                                for (i in seq_along(self$resources)) {
                                                  if (i ==1) {
                                                    state_tibble <- self$resources[[i]]$as_tibble()
                                                  }
                                                  else {
                                                    state_tibble <- rbind(state_tibble, self$resources[[i]]$as_tibble())
                                                  }
                                                }
                                                return (state_tibble)
                                              },

                                              #' Loads a csv file of resources into the manager
                                              #'
                                              #' @param file_name The path to the csv file
                                              #' @return None
                                              load = function(file_name) {
                                                resources <- read.csv(file_name)
                                                for(i in 1:nrow(resources)) {
                                                  resource_row <- resources[i,]
                                                  self$add_resource(resource$new(name=resource_row$name, quantity=resource_row$quantity))
                                                }
                                              }
                                ))
