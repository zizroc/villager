#' @export
#' @title Agent
#' @docType class
#' @description This is an object that represents an abstract agent.
#' @details This class is the basic agent in the framework.
#' @field identifier A unique identifier that can be used to identify the agent
#' @field age A time-step dependent variable
#' @section Methods:
#' \describe{
#'   \item{\code{as_tibble()}}{Represents the current state of the agent as a tibble}
#'   \item{\code{get_age()}}{Returns age in terms of years}
#'   \item{\code{get_id()}}{Returns unique identifier}
#'   \item{\code{initialize()}}{Create a new agent}
#'   \item{\code{propagate()}}{Runs every time-step}
#'   }
agent <- R6::R6Class(
  "agent",
  public = list(
    identifier = NULL,
    #' Create a new agent
    #'
    #' @description Used to created new agent objects.
    #'
    #' @export
    #' @param identifier The agent's unique identifier
    #' @return A new agent object
    initialize = function(
      identifier = NA,
      age        = 0
    ) {
      if (is.na(identifier)) {
        library(uuid)
        identifier <- uuid::UUIDgenerate()
      }
      self$identifier <- identifier
    },
    #' Agent-level time dependence
    #'
    #' @return None
    propagate = function() {
   }
  ))
