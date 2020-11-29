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
#'   \item{\code{get_living_winiks()}}{Returns the winik objects for winiks that are alive}
#'   \item{\code{add_winik()}}{Adds a winik to the manager}
#'   \item{\code{remove_winik()}}{Removes a winik from the manager}
#'   \item{\code{get_states()}}{Returns all of the villager states in a vector}
#'   \item{\code{get_winik_index()}}{Retrieves the index of a winik in the internal list}
#'   \item{\code{get_average_age()}}{Returns the average age in years of the winiks}
#'   \item{\code{load()}}{Loads winiks from disk}
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

                                   #' Returns a list of all the winiks that are currently alive
                                   #'
                                   #' @return A list of living winiks
                                   get_living_winiks = function() {
                                     living_winiks <- list()
                                     for (winik in self$winiks) {
                                       if (winik$alive) {
                                         living_winiks <- append(living_winiks, winik)
                                       }
                                     }
                                     return (living_winiks)
                                   },

                                   #' Adds a winik to the manager.
                                   #'
                                   #' @param new_winik The winik to add
                                   #' @return None
                                   add_winik = function(new_winik) {
                                     # Create an identifier if it's null
                                     if(is.null(new_winik$identifier)) {
                                      new_winik$identifier <- uuid::UUIDgenerate()
                                     }
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

                                   #' Returns a tibble of winiks
                                   #'
                                   #' @details Each row of the tibble represents a winik object
                                   #' @return A single tibble of all winiks
                                   get_states = function() {
                                     # Create a data frame to hold the states
                                     state_tibble <- tibble::tibble()
                                     for (i in seq_along(self$winiks)) {
                                       if (i ==1) {
                                         state_tibble <- self$winiks[[i]]$as_tibble()
                                       }
                                       else {
                                         state_tibble <- rbind(state_tibble, self$winiks[[i]]$as_tibble())
                                       }
                                     }
                                     return (state_tibble)
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

                                   #' Returns the total number of winiks that are alive
                                   #' @export
                                   #' @return The numnber of living winiks
                                   get_living_population = function(){
                                     total_living_population <- 0
                                     for (winik in self$winiks)
                                       if (winik$alive)
                                         total_living_population <- total_living_population + 1
                                      return (total_living_population)
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
                                   },

                                   #' Loads winiks from disk
                                   #'
                                   #' @details Populates the winik manager with a set of winiks defined in a csv file
                                   #' @param file_name The location of the file holding the winiks=
                                   #' @return None
                                   load = function(file_name) {
                                     winiks <- read.csv(file_name, row.names=NULL)
                                     for(i in 1:nrow(winiks)) {
                                       winiks_row <- winiks[i,]
                                         new_winik <- winik$new(identifier = winiks_row$identifier,
                                                               first_name= winiks_row$first_name,
                                                               last_name=winiks_row$last_name,
                                                               age=winiks_row$age,
                                                               mother_id=winiks_row$mother_id,
                                                               father_id=winiks_row$father_id,
                                                               partner=winiks_row$partner,
                                                               gender=winiks_row$gender,
                                                               profession=winiks_row$profession,
                                                               alive=winiks_row$alive,
                                                               health=winiks_row$health)
                                       self$add_winik(new_winik)
                                     }
                                   }
                     ))
