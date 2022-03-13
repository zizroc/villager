#' @export
#' @title Resource Manager
#' @docType class
#' @description This object manages all of the resources in a village.
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new manager}
#'   \item{\code{get_resources()}}{Gets all of the resources that the manager has}
#'   \item{\code{get_resource()}}{Retrieves a resource from the manager}
#'   \item{\code{add_resource()}}{Adds a resource to the manager}
#'   \item{\code{remove_resource()}}{Removes a resource from the manager}
#'   \item{\code{get_resource_index()}}{Retrieves the index of the resource}
#'   \item{\code{get_states()}}{Returns a list of states}
#'   \item{\code{load()}}{Loads a csv file of resources and adds them to the manager.}
#'   }
resource_manager <- R6::R6Class("resource_manager",
                                public = list(
                                              #' @field resources A list of resource objects
                                              resources = NA,
                                              #' Creates a new , empty, resource manager for a village.
                                              #' @description Get a new instance of a resource_manager
                                              initialize = function() {
                                                self$resources <- vector()
                                              },

                                              #' Gets all of the managed resources
                                              #'
                                              #' @return A list of resources
                                              get_resources = function() {
                                                return (self$resources)
                                              },

                                              #' Gets a resource given a resource name
                                              #'
                                              #' @param name The name of the requested resource
                                              #' @return A resource object
                                              get_resource = function(name) {
                                                for (res in self$resources) {
                                                  if (res$name == name) {
                                                    return (res)
                                                  }
                                                }
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

                                              #' Returns a dataframe where each row is a resource
                                              #'
                                              #' @return A single dataframe
                                              get_states = function() {
                                                # Create a data frame to hold the states

                                                # Allocate the appropriate sized table so that the row can be emplaced instead of appended
                                                resource_count <- length(self$resources)
                                                state_table <- data.frame(matrix(nrow=resource_count,
                                                                                 ncol=length(names(villager::resource$public_fields))))
                                                if(resource_count > 0) {
                                                  # Name the columns in the proper order
                                                  test_resource <- self$resources[[1]]$as_table()
                                                  colnames(state_table) <- names(test_resource)
                                                  for (i in 1:resource_count) {
                                                    state_table[i, ] <-  self$resources[[i]]$as_table()
                                                  }
                                                }
                                                return(state_table)
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
