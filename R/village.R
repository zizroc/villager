#' @export
#' @title Village
#' @docType class
#' @description This is an object that represents the state of a village at a particular time.
#' @details This class acts as a type of record that holds the values of the
#'  different village variables. This class can be subclassed to include more variables that aren't present.
#' @importFrom  R6 R6Class
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Creates a new village}
#'   \item{\code{propagate()}}{Advances the village a single time step}
#'   \item{\code{set_initial_state()}}{Initializes the initial state of the village}
#'   }
village <- R6::R6Class("village",
  public = list(
    #' @field name Unique identifier for the village
    identifier = NA,
    #' @field name An optional name for the village
    name = NA,
    #' @field initial_condition A function that sets the initial state of the village
    initial_condition = NA,
    #' @field current_state The village's current state
    current_state = NA,
    #' @field previous_state The village's previous state
    previous_state = NA,
    #' @field models A list of functions or a single function that should be run at each timestep
    models = NULL,
    #' @field model_data Optional data that models may need
    model_data = NULL,
    #' @field agent_mgr The manager that handles all of the agents
    agent_mgr = NULL,
    #' @field resource_mgr The manager that handles all of the resources
    resource_mgr = NULL,

    #' Initializes a village
    #'
    #' @description This method is meant to set the variables that are needed for a village to propagate through
    #' time.
    #' @param name An optional name for the village
    #' @param initial_condition A function that gets called on the first time step
    #' @param models A list of functions or a single function that should be run at each time step
    #' @param agent_class The class that's being used to represent agents
    #' @param resource_class The class being used to describe the resources
    initialize = function(name,
                          initial_condition,
                          models = list(),
                          agent_class = villager::agent,
                          resource_class = villager::resource) {
      self$initial_condition <- initial_condition
      self$agent_mgr <- agent_manager$new(agent_class)
      self$resource_mgr <- resource_manager$new(resource_class)
      self$identifier <- uuid::UUIDgenerate()
      # Check to see if the user supplied a single model, outside of a list
      # If so, put it in a vector because other code expects 'models' to be a list
      if (!is.list(models) && !is.null(models)) {
        self$models <- list(models)
      } else {
        self$models <- models
      }
      self$name <- name
      # Creates an empty state that the initial condition will populate
      self$current_state <- village_state$new()
      self$previous_state <- self$current_state$clone(deep = TRUE)
      # Set the data
      self$model_data <- model_data$new()
    },

    #' Propagates the village a single time step
    #'
    #' @details This method is used to advance the village a single time step. It should NOT be used
    #' to set initial conditions. See the set_initial_state method.
    #' @param current_step The current time step
    #' @return None
    propagate = function(current_step, village_mgr) {
      # Create a new state representing this slice in time. Since many of the
      # values will be the same as the previous state, clone the previous state
      self$current_state <- self$previous_state$clone(deep = TRUE)
      # Update the current_step in the state record to reflect the new step
      self$current_state$step <- current_step
      # Run each of the models
      for (model in self$models) {
        # Create a read only copy of the last state so that users can make decisions off of it
        self$previous_state <- self$current_state$clone(deep = TRUE)
        model(self$current_state, self$previous_state, self$model_data, self$agent_mgr, self$resource_mgr, village_mgr
        )
      }
      self$current_state$agent_states <- self$agent_mgr$get_states()

      # Add the time step to the data
      if (nrow(self$current_state$agent_states) > 0) {
        self$current_state$agent_states$step <- self$current_state$step
      }
      self$current_state$resource_states <- self$resource_mgr$get_states()
      if (nrow(self$current_state$resource_states) > 0) {
        self$current_state$resource_states$step <- self$current_state$step
      }
    },

    #' Runs the user defined function that sets the initial state of the village
    #'
    #' @description Runs the initial condition model
    set_initial_state = function() {
      self$current_state <- village_state$new()
      self$current_state$step <- 0
      self$initial_condition(self$current_state,
                             self$model_data,
                             self$agent_mgr,
                             self$resource_mgr)
      self$current_state$agent_states <- self$agent_mgr$get_states()
      self$current_state$resource_states <- self$resource_mgr$get_states()

    }
  )
)
