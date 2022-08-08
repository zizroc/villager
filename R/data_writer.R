#' @export
#' @title Data Writer
#' @docType class
#' @description A class responsible for the simulation data to disk.
#' @details This class can be subclasses to provide advanced data writing to other data sources. This should also
#' be subclassed if the agent and resource classes are subclasses, to write any additional fields to the data source.
#' @field results_directory The folder where the simulation results are written to
#' @field agent_filename The location where the agents are written to
#' @field resource_filename The location where the resources are written to
#' @importFrom  readr write_csv
#' @section Methods:
#' \describe{
#'   \item{\code{write()}}{Writes the agent and resources to disk.}
#'   }
data_writer <- R6::R6Class(
  "data_writer",
  public = list(
    results_directory = NULL,
    agent_filename = NULL,
    resource_filename = NULL,

    #' Create a new data writer.
    #'
    #' @description Creates a new data writer object that has optional paths for data files.
    #' @param results_directory The directory where the results file is written to
    #' @param agent_filename The name of the file for the agent data
    #' @param resource_filename The name of the file for the resource data
    #' @return A new agent object
    initialize = function(results_directory = "results",
                          agent_filename = "agents.csv",
                          resource_filename = "resources.csv") {
      self$results_directory <- results_directory
      self$agent_filename <- agent_filename
      self$resource_filename <- resource_filename

      # Check that the directory exists, delete it if it does
      res_folder <- file.path(self$results_directory)
      if (file.exists(res_folder)) {
        unlink(res_folder, recursive = TRUE)
      }
      dir.create(res_folder, recursive = TRUE)
    },

    #' Writes a village's state to disk.
    #'
    #' @description Takes a state an the name of a village and writes the agents and resources to disk
    #' @param state The village's village_state that's being written
    #' @param village_name The name of the village. This is used to create the data directory
    #' @return None
    write = function(state, village_name) {
      # Check that the village_name folder where the csv files are written to exists; create it if it doesn't
      res_folder <- file.path(self$results_directory, village_name)
      if (!file.exists(res_folder)) {
        dir.create(res_folder, recursive = TRUE)
      }
      # Write the agents to disk
      agent_path <- file.path(res_folder, self$agent_filename)
      append <- TRUE
      col_names <- FALSE
      if (!file.exists(agent_path)) {
        file.create(agent_path, recursive = TRUE)
        append <- FALSE
        col_names <- TRUE
      }
      readr::write_csv(state$agent_states,
                       file = agent_path,
                       na = "NA",
                       append = append,
                       col_names = col_names)

      # Write the resources
      append <- TRUE
      col_names <- FALSE
      resources_path <- file.path(res_folder, self$resource_filename)
      if (!file.exists(resources_path)) {
        file.create(resources_path, recursive = TRUE)
        append <- FALSE
        col_names <- TRUE
      }
      readr::write_csv(state$resource_states,
                       file = resources_path,
                       na = "NA",
                       append = append,
                       col_names = col_names)
    }
  )
)
