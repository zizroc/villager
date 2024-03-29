#' @export
#' @title agent
#' @docType class
#' @description This is an object that represents a villager (agent).
#' @details This class acts as an abstraction for handling villager-level logic. It can take a
#'  number of functions that run at each timestep. It also has an associated
#' @field identifier A unique identifier that can be used to identify and find the agent
#' @field first_name The agent's first name
#' @field last_name The agent's last name
#' @field age The agent's age
#' @field mother_id The identifier of the agent's mother
#' @field father_id The identifier of the agent's father
#' @field profession The agent's profession
#' @field partner The identifier of the agent's partner
#' @field gender The agent's gender
#' @field alive A boolean flag that represents whether the villager is alive or dead
#' @field children A list of children identifiers
#' @field health A percentage value of the agent's current health
#' @importFrom  uuid UUIDgenerate
#' @section Methods:
#' \describe{
#'   \item{\code{as_table()}}{Represents the current state of the agent as a tibble}
#'   \item{\code{get_age()}}{Returns age in terms of years}
#'   \item{\code{get_gender()}}{}
#'   \item{\code{get_days_sincelast_birth()}}{Get the number of days since the agent last gave birth}
#'   \item{\code{initialize()}}{Create a new agent}
#'   \item{\code{propagate()}}{Runs every day}
#'   }
agent <- R6::R6Class("agent",
  public = list(
    age = NULL,
    alive = NULL,
    children = NULL,
    father_id = NULL,
    first_name = NULL,
    gender = NULL,
    health = NULL,
    identifier = NULL,
    last_name = NULL,
    mother_id = NULL,
    partner = NULL,
    profession = NULL,

    #' Create a new agent
    #'
    #' @description Used to created new agent objects.
    #'
    #' @export
    #' @param age The age of the agent
    #' @param alive Boolean whether the agent is alive or not
    #' @param children An ordered list of of the children from this agent
    #' @param gender The gender of the agent
    #' @param identifier The agent's identifier
    #' @param first_name The agent's first name
    #' @param last_name The agent's last name
    #' @param mother_id The identifier of the agent's mother
    #' @param father_id The identifier of the agent' father
    #' @param partner The identifier of the agent's partner
    #' @param profession The agent's profession
    #' @param health A percentage value of the agent's current health
    #' @return A new agent object
    initialize = function(identifier = NA,
                          first_name = NA,
                          last_name = NA,
                          age = 0,
                          mother_id = NA,
                          father_id = NA,
                          partner = NA,
                          children = vector(mode = "character"),
                          gender = NA,
                          profession = NA,
                          alive = TRUE,
                          health = 100) {
      if (is.na(identifier)) {
        identifier <- uuid::UUIDgenerate()
      }
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
    #' @return A boolean whether the agent is alive (true for yes)
    is_alive = function() {
      # The villager survived the day
      return(self$alive)
    },

    #' Gets the number of days from the last birth. This is also
    #' the age of the most recently born agent
    #'
    #' @return The number of days since last birth
    get_days_since_last_birth = function() {
      if (length(self$children) > 0) {
        # This works because the children list is sorted
        return(self$children[[1]]$age)
      }
      return(0)
    },

    #' Connects a child to the agent. This method ensures that the
    #' 'children' vector is ordered.
    #'
    #' @param child The agent object representing the child
    #' @return None
    add_child = function(child) {
      sort_children <- function() {
        children_length <- length(self$children)
        if (children_length <= 1) {
          return()
        }
        for (i in 1:children_length) {
          j_len <- children_length - 1
          for (j in 1:j_len) {
            if (self$children[[j]]$age > self$children[[j + 1]]$age) {
              temp <- self$children[j + 1]
              self$children[j + 1] <- self$children[j]
              self$children[j] <- temp
            }
          }
        }
      }

      if (length(self$children) == 0) {
        self$children <- c(self$children, child)
      } else {
        self$children <- append(self$children, child, after = 0)
        sort_children()
      }
    },

    #' Returns a data.frame representation of the agent
    #'
    #' @description I hope there's a more scalable way to do this in R; Adding every new attribute to this
    #' function isn't practical
    #' @details The village_state holds a copy of all of the villagers at each timestep; this method is used to turn
    #' the agent properties into the object inserted in the village_state.
    #' @export
    #' @return A data.frame representation of the agent
    as_table = function() {
      agent_table <- data.frame(
        age = self$age,
        alive = self$alive,
        father_id = self$father_id,
        first_name = self$first_name,
        gender = self$gender,
        health = self$health,
        identifier = self$identifier,
        last_name = self$last_name,
        mother_id = self$mother_id,
        partner = self$partner,
        profession = self$profession
      )
      return(agent_table)
    }
  )
)
