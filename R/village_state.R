#' @title village_state
#' @docType class
#' @description This is an object that represents the state of a village at a particular time.
#' @details This class acts as a type of record that holds the values of the different village variables. This class
#'  can be subclassed to include more variables that aren't present.
#' @section Methods:
#' @field step The time step that the state is relevant to
#' @field agent_states A list of agent states
#' @field resource_states A list of resource states
#' @section Methods:
#' \describe{
#'   }
village_state <- R6::R6Class("village_state",
  cloneable = TRUE,
  public = list(
    step = NA,
    agent_states = NA,
    resource_states = NA,

    #' Creates a new State
    #'
    #' @description Initializes all of the properties in the state to the ones passed in. This should
    #' be called by subclasses during initialization.
    #' @details When adding a new property, make sure to add it to the tibble
    #' representation.
    #' @export
    #' @param step The time step that the state is relevant to
    #' @param agent_states A vector of tibbles representing the states of the agents
    #' @param resource_states A vector of tibbles representing the states of the resources
    initialize = function(step = 0,
                          agent_states = vector(),
                          resource_states = vector()) {
      self$step <- step
      self$agent_states <- agent_states
      self$resource_states <- resource_states
    }
  )
)
