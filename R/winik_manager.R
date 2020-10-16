#' @export
#' @title Winik Manager
#' @docType class
#' @description This object manages all of the winiks in a village
#' @details This class acts as an abstraction for handling many villagers.
#' @field winiks A list of winiks
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new manager}
#'   \item{\code{get_winik()}}{Retrieves a minik from the manager}
#'   \item{\code{add_winik()}}{Adds a winik to the manager}
#'   \item{\code{create_winik()}}{Creates a new winik and adds it to the manager}
#'   \item{\code{remove_winik()}}{Removes a winik from the manager}
#'   \item{\code{get_states()}}{Returns all of the villager states in a vector}
#'   \item{\code{get_winik_index()}}{Retrieves the index of a winik in the internal list}
#'   }
winik_manager <- R6::R6Class("winik_manager",
                     public = list(winiks = NULL,
                                   #' Creates a new winik manager
                                   #'
                                   #' @param winiks An optional vector of winiks that the manager starts with
                                   initialize = function(winiks=vector()) {
                                     self$winiks <- winiks
                                   },

                                   #' Gets a winik given an identifier
                                   #'
                                   #' @param winik_identifier The identifier of the requested winik
                                   #' @return A winik object
                                   get_winik = function(winik_identifier) {
                                    return (list.filter(self$winiks, identifier == winik_identifier))
                                   },

                                   #' Adds a winik to the manager.
                                   #'
                                   #' @param new_winik The winik to add
                                   #' @return None
                                   add_winik = function(new_winik) {
                                     self$winiks <- append(append, new_winik)
                                   },

                                   #' Creates a winik,adds it to the manager, and then returns it
                                   #'
                                   #' @details There *has* to be an easy way to pass any number of arguments as a named list
                                   #' and unpack them and use them in the winik initialize method
                                   #' @param params Unknown
                                   #' @return The newly created winik
                                   create_winik = function(params) {
                                    new_winik <- winik$new(params)
                                    self$add_winik(new_winik)
                                   },

                                   #' Removes a winik from the manager
                                   #'
                                   #' @param winik_identifier The identifier of the winik being removed
                                   #' @return None
                                   remove_winik = function(winik_identifier) {
                                    winik_index <- self$get_winik_index(winik_identifier)
                                    self$winiks<-self$winiks[- winik_identifier]
                                   },

                                   #' Returns a list of villagers represented as tibbles
                                   #'
                                   #' @return A list of data frames
                                   get_states = function() {
                                     winik_states = vector(length = length(self$winiks))
                                     # Create a data frame to hold the states
                                     for (winik in self$winiks)
                                        winik_states <- append(winik_states, winik$as_tibble())
                                   },

                                   #' Returns the index of a winik in the internal winik list
                                   #'
                                   #' @param winik_identifier The identifier of the winik being located
                                   #' @return The index in the list, or NA
                                   get_winik_index =function(winik_identifier) {
                                     for (i in seq_along(self$winiks))
                                       if (self$winiks[i]$identifier == winik_identifier)
                                         return (i)
                                   }
                     ))
