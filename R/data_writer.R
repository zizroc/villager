#' @export
#' @title Data Writer
#' @docType class
#' @description A class responsible for the simulation data to disk.
#' @details This class can be subclasses to provide advanced data writing to other data sources. This should also be subclassed if the winik and resource
#' classes are subclasses, to write any addional fields to the data source.
#' @field results_directory The folder where the simulation resulst are written to
#' @field winik_filename The location where the winiks are written to
#' @field resource_filename The location where the resources are written to
#' @section Methods:
#' \describe{
#'   \item{\code{write()}}{Writes the winik and resources to disk.}
#'   }
data_writer <- R6::R6Class("data_writer",
                     public = list(results_directory=NULL,
                                   winik_filename=NULL,
                                   resource_filename=NULL,

                                   #' Create a new data writer.
                                   #'
                                   #' @description Creates a new data writer object that has optional paths for data files.
                                   #' @export
                                   #' @param results_directory The directory where the results file is written to
                                   #' @param winik_filename The name of the file for the winik data
                                   #' @param resource_filename The name of the file for the resource data
                                   #' @return A new winik object
                                   initialize = function(results_directory='results', winik_filename='winiks.csv', resource_filename='resources.csv') {
                                     self$results_directory <- results_directory
                                     self$winik_filename <- winik_filename
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
                                   #' @description Takes a state an the name of a village and writes the winiks and resources to disk
                                   #' @param state The village's village_state that's being written
                                   #' @param village_name The name of the village. This is used to create the data directory
                                   #' @export
                                   #' @return None
                                   write = function(state, village_name) {
                                     # Check the the village_name folder where the csv files are written to exists
                                     res_folder <- file.path(self$results_directory, village_name)
                                     if (file.exists(res_folder)) {
                                       unlink(res_folder, recursive = TRUE)
                                     }
                                     dir.create(res_folder, recursive = TRUE)

                                     # Write the winiks
                                     winik_filename <- file.path(res_folder, self$winik_filename)

                                     readr::write_csv(state$winik_states, winik_filename, na="NA")

                                     # Write the resources
                                     resource_filename <- file.path(res_folder, self$resource_filename)
                                     write.table(state$resource_states, resource_filename, sep = ",")
                                   }
                                   )
                     )
