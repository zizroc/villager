#' @export
#' @title Winik Manager
#' @docType class
#' @description A class that abstracts the management of aggregations of Winik classes. Each village should have
#' an instance of a winik_manager to interface the winiks inside.
#' @field winiks A list of winiks objects that the winik manager manages.
#' @field winik_class A class describing winiks. This is usually the default villager supplied 'winik' class
#' @section Methods:
#' \describe{
#'   \item{\code{add_winik()}}{Adds a single winik to the manager.}
#'   \item{\code{get_average_age()}}{Returns the average age, in years, of all the winiks.}
#'   \item{\code{get_living_winiks()}}{Gets a list of all the winiks that are currently alive.}
#'   \item{\code{get_states()}}{Returns a data.frame consisting of all of the managed winiks.}
#'   \item{\code{get_winik()}}{Retrieves a particular winik from the manager.}
#'   \item{\code{get_winik_index()}}{Retrieves the index of a winik.}
#'   \item{\code{initialize()}}{Creates a new manager instance.}
#'   \item{\code{load()}}{Loads a csv file defining a population of winiks and places them in the manager.}
#'   \item{\code{remove_winik()}}{Removes a winik from the manager}
#'   }
winik_manager <- R6::R6Class("winik_manager",
  public = list(
    winiks = NULL,
    winik_class = NULL,

    #' Creates a new winik manager instance.
    #'
    #' @param winik_class The class that's being used to represent agents being managed
    initialize = function(winik_class=villager::winik) {
      self$winiks <- vector()
      self$winik_class <- winik_class
    },

    #' Given the identifier of a winik, sort through all of the managed winiks and return it
    #' if it exists.
    #'
    #' @description Return the R6 instance of a winik with identiifier 'winik_identifier'.
    #' @param winik_identifier The identifier of the requested winik.
    #' @return An R6 winik object
    get_winik = function(winik_identifier) {
      for (winik in self$winiks) {
        if (winik$identifier == winik_identifier) {
          return(winik)
        }
      }
    },

    #' Returns a list of all the winiks that are currently alive.
    #'
    #' @return A list of living winiks
    get_living_winiks = function() {
      living_winiks <- list()
      for (winik in self$winiks) {
        if (winik$alive) {
          living_winiks <- append(living_winiks, winik)
        }
      }
      return(living_winiks)
    },

    #' Adds a winik to the manager.
    #'
    #' @param new_winik The winik to add to the manager
    #' @return None
    add_winik = function(new_winik) {
      # Create an identifier if it's null
      if (is.null(new_winik$identifier)) {
        new_winik$identifier <- uuid::UUIDgenerate()
      }
      self$winiks <- append(self$winiks, new_winik)
    },

    #' Removes a winik from the manager
    #'
    #' @param winik_identifier The identifier of the winik being removed
    #' @return None
    remove_winik = function(winik_identifier) {
      winik_index <- self$get_winik_index(winik_identifier)
      self$winiks <- self$winiks[-winik_index]
    },

    #' Returns a data.frame of winiks
    #'
    #' @details Each row of the data.frame represents a winik object
    #' @return A single data.frame of all winiks
    get_states = function() {
      # Allocate the appropriate sized table so that the row can be emplaced instead of appended
      winik_count <- length(self$winiks)
      winik_fields <- names(self$winik_class$public_fields)
      column_names <- winik_fields[!winik_fields %in% c("children")]
      state_table <- data.frame(matrix(nrow = winik_count, ncol = length(column_names)))

      if (winik_count > 0) {
        # Since we know that a winik exists and we need to match the columns here with the
        # column names in winik::as_table, get the first winik and use its column names
        colnames(state_table) <- column_names
        for (i in 1:winik_count) {
          state_table[i, ] <-  self$winiks[[i]]$as_table()
        }
      }
      return(state_table)
    },

    #' Returns the index of a winik in the internal winik list
    #'
    #' @param winik_identifier The identifier of the winik being located
    #' @return The index in the list, or R's default return value
    get_winik_index = function(winik_identifier) {
      for (i in seq_len(length(self$winiks))) {
        if (self$winiks[[i]]$identifier == winik_identifier) {
          return(i)
        }
      }
      return(NA)
    },

    #' Connects two winiks together as mates
    #'
    #' @param winik_a A winik that will be connected to winik_b
    #' @param winik_b A winik that will be connected to winik_a
    connect_winiks = function(winik_a, winik_b) {
      winik_a$partner <- winik_b$identifier
      winik_b$partner <- winik_a$identifier
    },

    #' Returns the total number of winiks that are alive
    #' @return The numnber of living winiks
    get_living_population = function() {
      total_living_population <- 0
      for (winik in self$winiks)
        if (winik$alive == TRUE) {
          total_living_population <- total_living_population + 1
        }
      return(total_living_population)
    },

    #' Returns the averag age, in years, of all of the winiks
    #'
    #' @details This is an *example* of the kind of logic that the manager might handle. In this case,
    #' the manager is performing calculations about its aggregation (winiks). Note that the 364 days needs to
    #' work better
    #'
    #' @return The average age in years
    get_average_age = function() {
      total_age <- 0
      for (winik in self$winiks)
        total_age <- total_age + winik$age
      average_age_days <- total_age / length(self$winiks)
      return(average_age_days / 364)
    },

    #' Takes all of the winiks in the manager and reconstructs the children
    #'
    #' @details This is typically called when loading winiks from disk for the first time.
    #' When children are created during the simulation, the family connections are made
    #' through the winik class and added to the manager via add_winik.
    #' @return None
    add_children = function() {
      for (winik in self$winiks) {
        if (!is.na(winik$mother_id)) {
          if (!is.na(self$get_winik_index(winik$mother_id))) {
            mother <- self$get_winik(winik$mother_id)
            mother$add_child(winik)
          }
        }
        if (!is.na(winik$father_id)) {
          if (!is.na(self$get_winik_index(winik$father_id))) {
            father <- self$get_winik(winik$father_id)
            father$add_child(winik)
          }
        }
      }
    },

    #' Loads winiks from disk.
    #'
    #' @details Populates the winik manager with a set of winiks defined in a csv file.
    #' @param file_name The location of the file holding the winiks.
    #' @return None
    load = function(file_name) {
      winiks <- read.csv(file_name, row.names = NULL)
      for (i in seq_len(nrow(winiks))) {
        winiks_row <- winiks[i, ]
        new_winik <- winik$new(
            identifier = winiks_row$identifier,
            first_name = winiks_row$first_name,
            last_name = winiks_row$last_name,
            age = winiks_row$age,
            mother_id = winiks_row$mother_id,
            father_id = winiks_row$father_id,
            partner = winiks_row$partner,
            gender = winiks_row$gender,
            profession = winiks_row$profession,
            alive = winiks_row$alive,
            health = winiks_row$health
          )
        self$add_winik(new_winik)
      }
      self$add_children()
    }
  )
)
