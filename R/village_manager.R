#' @export
#' @title Village Manager
#' @docType class
#' @description This object manages all of the villages. It acts as an interface to them
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new manager}
#'   \item{\code{get_villages()}}{Gets all of the villages that the manager has}
#'   \item{\code{get_village()}}{Retrieves a specific village from the manager, by name}
#'   \item{\code{add_village()}}{Adds a village to the manager}
#'   }
village_manager <- R6::R6Class(
  "village_manager",
  public = list(
    #' @field villages A list of village objects
    villages = NULL,
    #' Creates a new, village manager
    #' @description Get a new instance of a village_manager
    initialize = function(villages) {
      self$villages <- villages
    },

    #' Gets all of the managed villages
    #'
    #' @return A list of resources
    get_villages = function() {
      return(self$villages)
    },

    #' Gets a village given a village name
    #'
    #' @param name The name of the requested village
    #' @return A village object
    get_village = function(name) {
      for (village in self$villages) {
        if (village$name == name) {
          return(village)
        }
      }
    },

    #' Adds a village to the manager.
    #'
    #' @param ... The villages to add
    #' @return None
    add_resource = function(...) {
      for (new_village in list(...)) {
        self$villages <- append(self$villages, new_village)
      }
    }
  )
)
