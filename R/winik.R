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
#'   \item{\code{propegate()}}{Unknown}
#'   \item{\code{add_partner()}}{Adds a partner to the wink}
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
                                      #' @param first_name The winik's first name
                                      #' @param last_name The winik's last naem
                                      #' @param age The age of the winik
                                      #' @param mother_id The identifier of the winik's monther
                                      #' @param father_id The identifier of the winik' father
                                      #' @param partner The identifier of the winik's partner
                                      #' @param children A list of identifiers of the children from this winik
                                      #' @param gender The gender of the winik
                                      #' @param models Unknown
                                      #'
                                      initialize = function(first_name=NA,
                                                            last_name=NA,
                                                            age=0,
                                                            mother_id=NULL,
                                                            father_id=NULL,
                                                            partner=NULL,
                                                            children=list(),
                                                            gender=NULL,
                                                            models = vector()) {

                                        # Check to see if the user supplied a single model, outside of a list
                                        # If so, put it in a vector because other code expects 'models' to be a list
                                        if(!is.vector(models) && !is.null(models)) {
                                          self$models <- append(self$models, models)
                                        } else {
                                          self$models<-models
                                        }

                                        self$alive <- TRUE
                                        self$identifier <- uuid::UUIDgenerate()
                                        self$first_name <- first_name
                                        self$last_name <- last_name
                                        self$age <- age
                                        self$mother_id <- mother_id
                                        self$father_id <- mother_id
                                        self$profession <- self$get_profession()
                                        if (is.null(gender))
                                          self$gender <- self$get_gender()

                                        self$partner <- partner
                                        self$children <-children
                                      },

                                      #' Gets a random number between 0 and 1; Treat
                                      #' 0: female
                                      #' 1: male
                                      #'
                                      #' @return A string representing the gender
                                      get_gender = function() {
                                        self$gender <- runif(1,0,1)
                                        if (self$gender)
                                          return ("male")
                                        return ("female")
                                      },

                                      #' Gets a random number between 0 and 1; Treat that as
                                      #' 0: farmer
                                      #' 1: fisher
                                      #'
                                      #' @return A string representing a profession
                                      get_profession = function() {
                                        if (age < 9)
                                          return (NULL)
                                        profession <- runif(1,0,1)
                                        if (profession)
                                          return("fisher")
                                        else
                                          return("farmer")
                                      },

                                      #' Advance one time step
                                      #'
                                      #' @details We need to think about how to make this flexible for people to use
                                      propegate = function() {
                                        # Check to see if they die
                                        self$alive = self$is_alive()

                                        # Check to see if they have a profession
                                        if (is.null(self$profession))
                                          self$get_profession()
                                      },

                                      #' A function that returns true or false whether the villager dies
                                      #' This is run each day
                                      #'
                                      #' @return A boolean whether the winik is alive (true for yes)
                                      is_alive = function() {
                                        # The villager survived the day
                                        return(TRUE)
                                      },

                                      #' If certain conditions are met, create a new child and connect its properties to the mother and father
                                      #' Poorly named function
                                      #'
                                      #' @return A new winik that's a child of this one
                                      has_child = function() {
                                        if ( (self$age > 14) && !is.null(self$partner) && (self$gender == 'female'))
                                          child <- villager$new(first_name=NA,
                                                                last_name=self$last_name,
                                                                age=0,
                                                                mother_id=self$identifier,
                                                                father_id=self$partner$identifier,
                                                                partner=NULL,
                                                                children=list(),
                                                                gender=NULL)

                                        return (child)

                                        # Return nothing otherwise
                                        return (NULL)
                                      },

                                      #' Adds a partner to the villager
                                      #'
                                      #' @param new_partner The identifier of the partner winik
                                      #' @param add_back Adds this winik's identifier to the other winik
                                      add_partner = function(new_partner, add_back = TRUE) {
                                        self$partner <- new_partner
                                        new_partner$partner <- self$identifier
                                      },

                                      #' Because age is stored as days, convert it to years
                                      #'
                                      #' @return The age of the winik in years
                                      get_age = function() {
                                        return (self$age/364)
                                      },

                                      #' Returns a tibble representation of the winik
                                      #'
                                      #' @description I hope there's a more scaleable way to do this in R; Adding every new attribute to this
                                      #' function isn't practical
                                      #' @details The village_state holds a copy of all of the villagers at each timestep; this method is used to turn
                                      #' the winik properties into the object insertedin the villag_state.
                                      #' @return A tibble representation of the winik
                                      as_tibble = function() {

                                       return(tibble(
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
