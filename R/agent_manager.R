#' @export
#' @title agent Manager
#' @docType class
#' @description A class that abstracts the management of aggregations of agent classes. Each village should have
#' an instance of a agent_manager to interface the agents inside.
#' @field agents A list of agents objects that the agent manager manages.
#' @field agent_class A class describing agents. This is usually the default villager supplied 'agent' class
#' @importFrom R6 R6Class
#' @importFrom  uuid UUIDgenerate
#' @section Methods:
#' \describe{
#'   \item{\code{add_agent()}}{Adds a single agent to the manager.}
#'   \item{\code{get_average_age()}}{Returns the average age, in years, of all the agents.}
#'   \item{\code{get_living_agents()}}{Gets a list of all the agents that are currently alive.}
#'   \item{\code{get_states()}}{Returns a data.frame consisting of all of the managed agents.}
#'   \item{\code{get_agent()}}{Retrieves a particular agent from the manager.}
#'   \item{\code{get_agent_index()}}{Retrieves the index of a agent.}
#'   \item{\code{initialize()}}{Creates a new manager instance.}
#'   \item{\code{load()}}{Loads a csv file defining a population of agents and places them in the manager.}
#'   \item{\code{remove_agent()}}{Removes a agent from the manager}
#'   }
agent_manager <- R6::R6Class("agent_manager",
  public = list(
    agents = NULL,
    agent_class = NULL,

    #' Creates a new agent manager instance.
    #'
    #' @param agent_class The class that's being used to represent agents being managed
    initialize = function(agent_class=villager::agent) {
      self$agents <- vector()
      self$agent_class <- agent_class
    },

    #' Given the identifier of a agent, sort through all of the managed agents and return it
    #' if it exists.
    #'
    #' @description Return the R6 instance of a agent with identifier 'agent_identifier'.
    #' @param agent_identifier The identifier of the requested agent.
    #' @return An R6 agent object
    get_agent = function(agent_identifier) {
      for (agent in self$agents) {
        if (agent$identifier == agent_identifier) {
          return(agent)
        }
      }
    },

    #' Returns a list of all the agents that are currently alive.
    #'
    #' @return A list of living agents
    get_living_agents = function() {
      living_agents <- list()
      for (agent in self$agents) {
        if (agent$alive) {
          living_agents <- append(living_agents, agent)
        }
      }
      return(living_agents)
    },

    #' Adds a agent to the manager.
    #'
    #' @param new_agent The agent to add to the manager
    #' @return None
    add_agent = function(new_agent) {
      # Create an identifier if it's null
      if (is.null(new_agent$identifier)) {
        new_agent$identifier <- uuid::UUIDgenerate()
      }
      self$agents <- append(self$agents, new_agent)
    },

    #' Removes a agent from the manager
    #'
    #' @param agent_identifier The identifier of the agent being removed
    #' @return None
    remove_agent = function(agent_identifier) {
      agent_index <- self$get_agent_index(agent_identifier)
      self$agents <- self$agents[-agent_index]
    },

    #' Returns a data.frame of agents
    #'
    #' @details Each row of the data.frame represents a agent object
    #' @return A single data.frame of all agents
    get_states = function() {
      # Allocate the appropriate sized table so that the row can be emplaced instead of appended
      agent_count <- length(self$agents)
      agent_fields <- names(self$agent_class$public_fields)
      column_names <- agent_fields[!agent_fields %in% c("children")]
      state_table <- data.frame(matrix(nrow = agent_count, ncol = length(column_names)))

      if (agent_count > 0) {
        # Since we know that a agent exists and we need to match the columns here with the
        # column names in agent::as_table, get the first agent and use its column names
        colnames(state_table) <- column_names
        for (i in 1:agent_count) {
          state_table[i, ] <-  self$agents[[i]]$as_table()
        }
      }
      return(state_table)
    },

    #' Returns the index of a agent in the internal agent list
    #'
    #' @param agent_identifier The identifier of the agent being located
    #' @return The index in the list, or R's default return value
    get_agent_index = function(agent_identifier) {
      for (i in seq_len(length(self$agents))) {
        if (self$agents[[i]]$identifier == agent_identifier) {
          return(i)
        }
      }
      return(NA)
    },

    #' Connects two agents together as mates
    #'
    #' @param agent_a A agent that will be connected to agent_b
    #' @param agent_b A agent that will be connected to agent_a
    connect_agents = function(agent_a, agent_b) {
      agent_a$partner <- agent_b$identifier
      agent_b$partner <- agent_a$identifier
    },

    #' Returns the total number of agents that are alive
    #' @return The number of living agents
    get_living_population = function() {
      total_living_population <- 0
      for (agent in self$agents)
        if (agent$alive == TRUE) {
          total_living_population <- total_living_population + 1
        }
      return(total_living_population)
    },

    #' Returns the average age, in years, of all of the agents
    #'
    #' @details This is an *example* of the kind of logic that the manager might handle. In this case,
    #' the manager is performing calculations about its aggregation (agents). Note that the 364 days needs to
    #' work better
    #'
    #' @return The average age in years
    get_average_age = function() {
      total_age <- 0
      for (agent in self$agents)
        total_age <- total_age + agent$age
      average_age_days <- total_age / length(self$agents)
      return(average_age_days / 364)
    },

    #' Takes all of the agents in the manager and reconstructs the children
    #'
    #' @details This is typically called when loading agents from disk for the first time.
    #' When children are created during the simulation, the family connections are made
    #' through the agent class and added to the manager via add_agent.
    #' @return None
    add_children = function() {
      for (agent in self$agents) {
        if (!is.na(agent$mother_id)) {
          if (!is.na(self$get_agent_index(agent$mother_id))) {
            mother <- self$get_agent(agent$mother_id)
            mother$add_child(agent)
          }
        }
        if (!is.na(agent$father_id)) {
          if (!is.na(self$get_agent_index(agent$father_id))) {
            father <- self$get_agent(agent$father_id)
            father$add_child(agent)
          }
        }
      }
    },

    #' Loads agents from disk.
    #'
    #' @details Populates the agent manager with a set of agents defined in a csv file.
    #' @param file_name The location of the file holding the agents.
    #' @return None
    load = function(file_name) {
      agents <- read.csv(file_name, row.names = NULL)
      for (i in seq_len(nrow(agents))) {
        agents_row <- agents[i, ]
        new_agent <- agent$new(
            identifier = agents_row$identifier,
            first_name = agents_row$first_name,
            last_name = agents_row$last_name,
            age = agents_row$age,
            mother_id = agents_row$mother_id,
            father_id = agents_row$father_id,
            partner = agents_row$partner,
            gender = agents_row$gender,
            profession = agents_row$profession,
            alive = agents_row$alive,
            health = agents_row$health
          )
        self$add_agent(new_agent)
      }
      self$add_children()
    }
  )
)
