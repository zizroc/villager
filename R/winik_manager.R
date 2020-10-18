#' @export
#' @title Winik Manager
#' @docType class
#' @description This object manages all of the winiks in a village
#' @details This class acts as an abstraction for handling many villagers.
#' @field winiks A list of winiks
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new manager}
#'   \item{\code{propegate()}}{Advances the winik one timestep}
#'   \item{\code{get_winik()}}{Retrieves a minik from the manager}
#'   \item{\code{add_winik()}}{Adds a winik to the manager}
#'   \item{\code{remove_winik()}}{Removes a winik from the manager}
#'   \item{\code{get_states()}}{Returns all of the villager states in a vector}
#'   \item{\code{get_winik_index()}}{Retrieves the index of a winik in the internal list}
#'   \item{\code{get_average_age()}}{Returns the average age in years of the winiks}
#'
#'   }
winik_manager <- R6::R6Class("winik_manager",
                     public = list(winiks = NULL,

                                   #' Creates a new winik manager
                                   #'
                                   #' @description Used to create a new manager to handle a population of
                                   #' winiks
                                   initialize = function() {
                                    self$winiks <- vector()
                                   },

                                   #' Advances all of the winiks a single time step
                                   #'
                                   #' @details This might go away
                                   propegate = function() {
                                     #for (winik in self$winiks)
                                       #winik$propegate()
                                   },

                                   #' Gets a winik given an identifier
                                   #'
                                   #' @details Oftentimes the identifier of the winik is known, and the object needs to be retrieved.
                                   #' This method  is used to get the object, given the identifier
                                   #' @param winik_identifier The identifier of the requested winik
                                   #' @return A winik object
                                   get_winik = function(winik_identifier) {
                                     for (winik in self$winiks)
                                       if (winik$identifier == winik_identifier)
                                        return (winik)
                                   },

                                   #' Adds a winik to the manager.
                                   #'
                                   #' @param new_winik The winik to add
                                   #' @return None
                                   add_winik = function(new_winik) {
                                     self$winiks <- append(self$winiks, new_winik)
                                   },

                                   #' Removes a winik from the manager
                                   #'
                                   #' @param winik_identifier The identifier of the winik being removed
                                   #' @return None
                                   remove_winik = function(winik_identifier) {
                                     winik_index <- self$get_winik_index(winik_identifier)
                                    self$winiks<-self$winiks[- winik_index]
                                   },

                                   #' Returns a vector of villagers represented as tibbles
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
                                   #' @return The index in the list, or R's default return value
                                   get_winik_index = function(winik_identifier) {
                                     for (i in seq_along(length(self$winiks))) {
                                       if (self$winiks[[i]]$identifier == winik_identifier) {
                                         return (i)
                                       }
                                     }
                                   },

                                   #' Connects two winiks together as mates
                                   #'
                                   #' @param winik_a A winik that will be connected to winik_b
                                   #' @param winik_b A winik that will be connected to winik_a
                                   connect_winiks = function(winik_a, winik_b) {
                                     winik_a$partner <- winik_b$identifier
                                     winik_b$partner <- winik_a$identifier
                                   },

                                   #' Returns the averag age, in years, of all of the winiks
                                   #'
                                   #' @details This is an *example* of the kind of logic that the manager might handle. In this case,
                                   #' the manager is performing calculations about its aggregation (winiks). Note that the 364 days needs to
                                   #' work better
                                   #'
                                   #' @return The average age in years
                                   get_average_age = function() {
                                     total_age <- 0
                                    for (winik in self$winiks)
                                      total_age <- total_age+winik$age

                                    average_age_days = total_age/length(self$winiks)
                                    return (average_age_days/364)
                                   }
                     ))
