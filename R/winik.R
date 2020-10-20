#' @export
#' @title Winik
#' @docType class
#' @description This is an object that represents a villager (winik).
#' @details This class acts as an abstraction for handling villager-level logic. It can take a number of functions that run at each timestep. It
#' also has an associated
#' @field identifier A unique identifier that can be used to identify and find the winik
#' @field first_name The winik's first name
#' @field last_name The winik's last name
#' @field age The winik's age
#' @field mother_id The identifier of the winik's mother
#' @field father_id The identifier of the winik's father
#' @field profession The winik's profession
#' @field partner The identifier of the winik's partner
#' @field gender The winik's gender
#' @field alive A boolean flag that represents whether the villager is alive or dead
#' @field children A list of children identifiers
#' @field models Unknown
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new winik}
#'   \item{\code{get_gender()}}{}
#'   \item{\code{get_age()}}{Returns age in terms of years}
#'   \item{\code{as_tibble()}}{Represents the current state of the winik as a tibble}
#'   }
winik <- R6::R6Class("winik",
                        public = list(identifier = NULL,
                                      first_name=NULL,
                                      last_name=NULL,
                                      age=NULL,
                                      mother_id=NULL,
                                      father_id=NULL,
                                      profession=NULL,
                                      partner=NULL,
                                      children=NULL,
                                      gender=NULL,
                                      alive=NULL,
                                      models=NULL,

                                      #' Create a new winik
                                      #'
                                      #' @description Used to created new winik objects.
                                      #'
                                      #' @export
                                      #' @param identifier The winik's identifier
                                      #' @param first_name The winik's first name
                                      #' @param last_name The winik's last naem
                                      #' @param age The age of the winik
                                      #' @param mother_id The identifier of the winik's monther
                                      #' @param father_id The identifier of the winik' father
                                      #' @param partner The identifier of the winik's partner
                                      #' @param children A list of identifiers of the children from this winik
                                      #' @param profession The winik's profession
                                      #' @param gender The gender of the winik
                                      #' @param models Unknown
                                      #' @return A new winik object
                                      initialize = function(identifier=NULL,
                                                            first_name=NA,
                                                            last_name=NA,
                                                            age=0,
                                                            mother_id=NULL,
                                                            father_id=NULL,
                                                            partner=NULL,
                                                            children=list(),
                                                            gender=NULL,
                                                            profession=NULL,
                                                            models = vector()) {

                                        # Check to see if the user supplied a single model, outside of a list
                                        # If so, put it in a vector because other code expects 'models' to be a list
                                        if(!is.vector(models) && !is.null(models)) {
                                          self$models <- append(self$models, models)
                                        } else {
                                          self$models<-models
                                        }

                                        self$alive <- TRUE
                                        self$identifier <- identifier
                                        self$first_name <- first_name
                                        self$last_name <- last_name
                                        self$age <- age
                                        self$mother_id <- mother_id
                                        self$father_id <- mother_id
                                        self$profession <- profession
                                        self$gender <- self$gender

                                        self$partner <- partner
                                        self$children <-children
                                      },

                                      #' A function that returns true or false whether the villager dies
                                      #' This is run each day
                                      #'
                                      #' @return A boolean whether the winik is alive (true for yes)
                                      is_alive = function() {
                                        # The villager survived the day
                                        return (self$alive)
                                      },

                                      #' Returns a tibble representation of the winik
                                      #'
                                      #' @description I hope there's a more scalable way to do this in R; Adding every new attribute to this
                                      #' function isn't practical
                                      #' @details The village_state holds a copy of all of the villagers at each timestep; this method is used to turn
                                      #' the winik properties into the object inserted in the village_state.
                                      #' @export
                                      #' @return A tibble representation of the winik
                                      as_tibble = function() {

                                       return(tibble::tibble(
                                         identifier = self$identifier,
                                         first_name = self$first_name,
                                         last_name = self$last_name,
                                         mother_id = self$mother_id,
                                         father_id = self$father_id,
                                         profession = self$profession,
                                         population = self$population,
                                         partner = self$partner,
                                         children = self$children,
                                         gender = self$gender,
                                         alive = self$alive,
                                         age = self$age
                                       ))
                                      }
                        ))
