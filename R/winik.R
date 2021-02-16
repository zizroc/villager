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
#' @field health A percentage value of the winik's current health
#' @section Methods:
#' \describe{
#'   \item{\code{as_tibble()}}{Represents the current state of the winik as a tibble}
#'   \item{\code{get_age()}}{Returns age in terms of years}
#'   \item{\code{get_gender()}}{}
#'   \item{\code{get_last_birth()}}{Get the number of days since the winik last gave birth}
#'   \item{\code{initialize()}}{Create a new winik}
#'   \item{\code{propagate()}}{Runs every day}
#'   }
winik <- R6::R6Class("winik",
                        public = list(age=NULL,
                                      alive=NULL,
                                      children=NULL,
                                      father_id=NULL,
                                      first_name=NULL,
                                      gender=NULL,
                                      health=NULL,
                                      identifier = NULL,
                                      last_name=NULL,
                                      mother_id=NULL,
                                      partner=NULL,
                                      profession=NULL,

                                      #' Create a new winik
                                      #'
                                      #' @description Used to created new winik objects.
                                      #'
                                      #' @export
                                      #' @param age The age of the winik
                                      #' @param alive Boolean whether the winik is alive or not
                                      #' @param children An ordered list of of the children from this winik
                                      #' @param gender The gender of the winik
                                      #' @param identifier The winik's identifier
                                      #' @param first_name The winik's first name
                                      #' @param last_name The winik's last naem
                                      #' @param mother_id The identifier of the winik's monther
                                      #' @param father_id The identifier of the winik' father
                                      #' @param partner The identifier of the winik's partner
                                      #' @param profession The winik's profession
                                      #' @param health A percentage value of the winik's current health
                                      #' @return A new winik object
                                      initialize = function(identifier=NULL,
                                                            first_name=NA,
                                                            last_name=NA,
                                                            age=0,
                                                            mother_id=NA,
                                                            father_id=NA,
                                                            partner=NA,
                                                            children=vector(mode = "character"),
                                                            gender=NA,
                                                            profession=NA,
                                                            alive=TRUE,
                                                            health=100) {
                                        self$alive <- alive
                                        self$identifier <- identifier
                                        self$first_name <- first_name
                                        self$last_name <- last_name
                                        self$age <- age
                                        self$mother_id <- mother_id
                                        self$father_id <- father_id
                                        self$profession <- profession
                                        self$gender <- gender
                                        self$partner <- partner
                                        self$children <- children
                                        self$health <- health
                                      },

                                      #' A function that returns true or false whether the villager dies
                                      #' This is run each day
                                      #'
                                      #' @return A boolean whether the winik is alive (true for yes)
                                      is_alive = function() {
                                        # The villager survived the day
                                        return (self$alive)
                                      },

                                      #' Handles logic for the winik that's done each day
                                      #'
                                      #' @return None
                                      propagate = function() {
                                        self$age <- self$age + 1
                                      },

                                      #' Gets the number of days from the last birth. This is also
                                      #' the age of the most recently born winik
                                      #'
                                      #' @return The number of days since last birth
                                      get_last_birth = function() {
                                        if(length(self$children) > 0) {
                                          # This works because the children list is sorted
                                          return (self$children[[1]]$age)
                                        }
                                        return (0)
                                      },

                                      #' Adds a child to the winik. This mehtod ensures that the
                                      #' 'children' vector is ordered.
                                      #'
                                      #' @param child The Winik object representing the child
                                      #' @return None
                                      add_child = function(child) {

                                        # HACK TURN THIS INTO ANYTHING ELSE
                                        bubble_sort <- function() {
                                          children_length <- length(self$children)
                                          if(children_length<= 1) {
                                            return()
                                          }
                                          for (i in 1:children_length) {
                                            j_len <- children_length-1
                                            for (j in 1:j_len) {
                                              if (self$children[[j]]$age > self$children[[j+1]]$age) {
                                                temp <- self$children[j+1]
                                                self$children[j+1] <- self$children[j]
                                                self$children[j] <- temp
                                              }
                                            }
                                          }
                                        }

                                        if (length(self$children) == 0) {
                                          self$children <- c(self$children, child)
                                        } else {
                                          self$children <- append(self$children, child, after = 0)
                                          bubble_sort()
                                        }
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
                                        winik_tibble <- tibble::tibble(
                                          identifier = self$identifier,
                                          first_name = self$first_name,
                                          last_name = self$last_name,
                                          mother_id = self$mother_id,
                                          father_id = self$father_id,
                                          profession = self$profession,
                                          partner = self$partner,
                                          gender = self$gender,
                                          alive = self$alive,
                                          age = self$age,
                                          health = self$health
                                        )
                                       return(winik_tibble)
                                      }
                        ))
