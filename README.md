# villager
[![Build Status](https://travis-ci.com/zizroc/villager.svg?branch=master)](https://travis-ci.com/zizroc/villager) [![Codecov test coverage](https://codecov.io/gh/zizroc/villager/branch/master/graph/badge.svg)](https://codecov.io/gh/zizroc/villager?branch=master)

## Installing
To install villager, you'll need to have the [`devtools`](https://github.com/r-lib/devtools) library installed. This is because the package hasn't been published to CRAN yet and `devtools` has a way to install from a GitHub repository.

To install `devtools` run the following from RStudio
```
install.packages("devtools")
```

To install `villager`, run
```
devtools::install_github("zizroc/villager")
```

## Using villager

`villager` is about modeling _populations_ with optional _resources_. Populations can be aggregated into a few structures: winiks, families, and villages. Winiks represent individual people; they can have health levels, names, partners, children, etc. Families are abstract aggregations of winiks; the logic for creating families is left to the modeler (you) for flexibility. Villages are aggregations of families.


Resources are represented as simple objects that 

In summary, there are a few fundamental concepts to keep in mind while modeling with _villager_.

1. Simulations contain villages
1. Models are on a per-village basis. You can have multiple villages, all with different logic.
2. Villages contain winiks
3. Villages contain resources
4. Villages expose winiks and resources through their respective _manager_ classes

### Creating & Managing Villagers

Villagers are created by instantiating the `winik` class. There are a number of winik properties that can be passed to the contructor; a comprehensive list of winik properties can be found on the [winik documentation page]().
```
mother <- winik$new(first_name="Kirsten", last_name="Taylor", age=9125)
father <- winik$new(first_name="Joshua", last_name="Thompson", age=7300)
daughter <- winik$new(first_name="Mariylyyn", last_name="Thompson", age=10220)
```

To aggregate winiks, instantiate the `winik_manager` class and use the provideed methods, outlined on the winik manager [docs page](). Because the classes are R6, the object can be modified after being added to the manager and the changes will be persisted without needing to re-add the villager. For example, setting the daughter's mother and father parameters below.

```
winik_mgr <- winik_manager$new()
winik_mgr$add_winik(mother)
winik_mgr$add_winik(father)
winik_mgr$add_winik(daughter)
daughter$mother_id <- mother$identifier
daughter$father_id <- father$identifier
```

The winik manager can also be used to pair winiks, representitive of a relationship.
```
winik_mgr$winik_mgr$connect_winiks(mother, father)
```

### Creating & Managing Resources

Resources are similar to winiks in that they're both R6 classes, are instantiated similarly, and are also managed.

```
corn_resource <- resource$new(name="corn", quantity = 10)
fish_resource <- resource$new(name="fish", quantity = 15)
corn_resource$quantity=5

resource_mgr <- resource_manager$new()
resource_mgr$add_resource(corn_resource)
resource_mgr$add_resource(fish_resource)
corn_resource$quantity=5
```

In the example above, `corn_resource` does _not_ have to be placed back in the resource manager.

### State

Objects of type `village`, `winik`, and `resource`have particular states at a particular time. As the simulation progresses, the state of these change based on model logic. At the end of each time step, the state of each object is saved, giving a compelte record of the system's evolution. 

### Managing the Initial State

Creating the initial state is done by creating a function, the name doesn't matter but the parameters _must_ match the ones in the example below. Note that the winik and resource managers are provided by the library as parameters. An example initial state with the three winiks and resources created earlier is given below.

```
initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
  # Create the initial villagers
  mother <- winik$new(first_name="Kirsten", last_name="Taylor", age=9125)
  father <- winik$new(first_name="Joshua", last_name="Thompson", age=7300)
  daughter <- winik$new(first_name="Mariylyyn", last_name="Thompson", age=10220)
  daughter$mother_id <- mother$identifier
  daughter$father_id <- father$identifier
  
  # Add the winiks to the manager
  winik_mgr$connect_winiks(mother, father)
  winik_mgr$add_winik(mother)
  winik_mgr$add_winik(father)
  winik_mgr$add_winik(daughter)
  
  # Create the resources
  corn_resource <- resource$new(name="corn", quantity = 10)
  fish_resource <- resource$new(name="fish", quantity = 15)
  
  # Add the resources to the manager
  resource_mgr$add_resource(corn_resource)
  resource_mgr$add_resource(fish_resource)
}
```


### Creating Models

Like the initial condition-the logic for mutating the state is contained in a function with _similar_ parameters, shown below. It's important that all  model functions take these parameters. An example model that increases the age of the each living villager by 1 at each time step and sets their profession to 'Farmer' after approximately 12 years (4383 days).

```
test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
print(current_state$date)
  for (winik in winik_mgr$get_living_winiks()) {
    winik$age <- winik$age+1
    if (winik$age >= 4383) {
      winik$profession <- "Farmer"
    }
  }
}
```

### Creating Villages and Running Models

Models live inside `village` objects and are added to villages when the village is created.

```
small_village <- village$new("Test Model 1", initial_condition, test_model)
```

The `simulator` class is responsible for running simulations. It encapsulates _all_ of the villages and controls the duration of the simulation. The simulator below runs for 13 years

```
simulator <- simulation$new("-100-01-01", "-87-01-01", list(small_village))
simulator$run_model()
```

### Accessing Saved Data



### Example: A small village with a single family

We can combine the examples above into a full simulation that...

- Starts with an initial population of _three_ villagers
- Increases the age of each villager at the start of each day
- Runs for 13 years
- Sets the villager professtion after age 12


```
initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
  # Create the initial villagers
  mother <- winik$new(first_name="Kirsten", last_name="Taylor", age=9125)
  father <- winik$new(first_name="Joshua", last_name="Thompson", age=7300)
  daughter <- winik$new(first_name="Mariylyyn", last_name="Thompson", age=10220)
  daughter$mother_id <- mother$identifier
  daughter$father_id <- father$identifier
  
  # Add the winiks to the manager
  winik_mgr$connect_winiks(mother, father)
  winik_mgr$add_winik(mother)
  winik_mgr$add_winik(father)
  winik_mgr$add_winik(daughter)
  
  # Create the resources
  corn_resource <- resource$new(name="corn", quantity = 10)
  fish_resource <- resource$new(name="fish", quantity = 15)
  
  # Add the resources to the manager
  resource_mgr$add_resource(corn_resource)
  resource_mgr$add_resource(fish_resource)
}

test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
print(current_state$date)
  for (winik in winik_mgr$get_living_winiks()) {
    winik$age <- winik$age+1
    if (winik$age >= 4383) {
      winik$profession <- "Farmer"
    }
  }
}



small_village <- village$new("Test Model", initial_condition, test_model)
simulator <- simulation$new("-100-01-01", "-87-01-01", list(small_village))
simulator$run_model()
```

### Full Example 2

To demonstrate programatically creating villagers, consider the model below that has the following logic.

- Starts with 10 villagers
- Every even day, two new villagers are created
- Every odd day, one villager dies

```
  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
      for (i in 1:10) {
        name <- runif(1, 0.0, 100)
        new_winik <- winik$new(first_name <- name, last_name <- "Smith")
        winik_mgr$add_winik(new_winik)
      }
  }

  model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  print(current_state$date)
    current_day <- current_state$date$day
    if((current_day%%2) == 0) {
      # Then it's an even day
      # Create two new winiks whose first names are random numbers
      for (i in 1:2) {
        name <- runif(1, 0.0, 100)
        new_winik <- winik$new(first_name <- name, last_name <- "Smith")
        winik_mgr$add_winik(new_winik)
      }
    } else {
      # It's an odd day
      living_winiks <- winik_mgr$get_living_winiks()
      # Kill the first one
      living_winiks[[1]]$alive <- FALSE
    }
  }
  coastal_village <- village$new("Test village", initial_condition, model)
  simulator <- simulation$new("-100-01-01", "-99-01-04", villages = list(coastal_village))
  simulator$run_model()
  ```

## Extending villager

When the default values for the `winik` and `resource` classes aren't sufficient-which will be the case for most custom agent based models, they can be extended by subclassing.

The `village` constructor takes optional arguments for the `winik` and `village` classes that should be used in the simulation. The defaults for these are the classes included by villager. Because the subclasses can be long, it's reccomended to place them in separate files (ie winik-extended.R).

### Extending Resources

The current fields that a resource has are `name` and `amount`. This can be extended to include features like expiration dates or trade histories. To extend the `resource` class, start by copy and pasting the source into a new file. Pick an approriate name for the new class. In the case below, the extened class below adds functionality to track when a resource was created. The new class should have `inherit = resource` in its R6::R6Class constructor.

```
#' @title resource_expiration
#' @docType class
#' @description This is an object that represents a resource that tracks when it was created

#' @field creation The date that the resource was created
#' @export
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new resource}
#'   \item{\code{as_tibble()}}{Represents the current state of the resource as a tibble}
#'   }
resource_expiration <- R6::R6Class("resource_expiration",
                                   inherit = resource,
                                   cloneable = TRUE,
                                   public = list(
                                     creation_date = NA,
                                     #' Creates a new resource.
                                     #'
                                     #' @param name The name of the resource
                                     #' @param quantity The quantity present
                                     initialize = function(name=NA, quantity=0, creation_date=NA) {
                                       super$initialize(name, quantity)
                                       # Your init code here
                                     },

                                     #' Returns a data.frame representation of the resource
                                     #'
                                     #' @return A data.frame of resources
                                     as_table = function() {
                                       return(data.frame(
                                         name = self$name,
                                         quantity = self$quantity
                                       ))
                                     }
                                   )
)
```


The class above can be extended to include an extra field that tracks when a resource was created.
```
#' @title resource_expiration
#' @docType class
#' @description This is an object that represents a resource that tracks when it was created

#' @field creation The date that the resource was created
#' @export
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new resource}
#'   \item{\code{as_tibble()}}{Represents the current state of the resource as a tibble}
#'   }
resource_expiration <- R6::R6Class("resource_expiration",
                                   inherit = resource,
                                   cloneable = TRUE,
                                   public = list(
                                     creation_date = NA,
                                     #' Creates a new resource.
                                     #'
                                     #' @param name The name of the resource
                                     #' @param quantity The quantity present
                                     #' #param creation_date The date at which this resource was created
                                     initialize = function(name=NA, quantity=0, creation_date=NA) {
                                       super$initialize(name, quantity)
                                       self$creation_date <- creation_date
                                     },



                                     #' Returns a data.frame representation of the resource
                                     #'
                                     #' @return A data.frame of resources
                                     as_table = function() {
                                       return(data.frame(
                                         name = self$name,
                                         quantity = self$quantity
                                       ))
                                     }
                                   )
)
```

The class can then be used in the simulation model in place of the traditional `resource` class.

The following model runs for a year and tracks when resources are created. After a number of days, the quantity of each resource is set to zero, signifying that the resource has expired.
```
initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
  for (i in 1:10) {
    name <- runif(1, 0.0, 100)
    new_winik <- winik$new(first_name <- name, last_name <- "Smith")
    winik_mgr$add_winik(new_winik)
  }
  # Create two new resources at the current date (The first day)
  corn <- resource_expiration$new("Corn", 10, current_state$date)
  rice <- resource_expiration$new("Rice", 20, current_state$date)
  resource_mgr$add_resource(corn)
  resource_mgr$add_resource(rice)
}

# Create the model that, each day, checks to see whether or not any resource expire
model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  # Loop over all of the resources and check if any expire
  for (resource in resource_mgr$get_resources()) {
    # Figure out how many days have passed
    days_passed <- gregorian::diff_days(resource$creation_date, current_state$date)
    if (resource$name == "Corn") {
      if (days_passed > 10 && resource$quantity > 0) {
        print("Setting Corn quantity to 0")
        resource$quantity <- 0
      }
    } else if (resource$name == "Rice" && resource$quantity > 0) {
      if (days_passed > 20) {
        print("Setting Rice quantity to 0")
        resource$quantity <- 0
      }
    }
  }
}
# Create the village and simulation
coastal_village <- village$new("Village with expiring resources", initial_condition, model)
simulator <- simulation$new("100-01-01", "101-01-04", villages = list(coastal_village))
simulator$run_model()
```

### Extending winiks

Like the `resource` class, the `winik` class can also be extended to accomidate for modeling needs. The new class must declare that it inherits from the winik class with `inherit = winik`. A base subclassed winik class is given below. This 

```











#' @export
#' @title Winik
#' @docType class
#' @description This is an object that represents an extended villager with the ability to track hair color
#' @field hair_color The color of the villager's hair
#' @section Methods:
#' \describe{
#'   \item{\code{initialize()}}{Create a new winik}
#'   \item{\code{as_tibble()}}{Represents the current state of the winik as a tibble}
#'   }
villager_extended <- R6::R6Class("winik",
                                 inherit = resource,
                                 public = list(
                                   hair_color = NA,

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
                                   #' @param hair_color The villager's hair color
                                   #' @return A new winik object
                                   initialize = function(identifier=NA,
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
                                                         health=100,
                                                         hair_color=NA) {
                                     super$initialize(identifier,
                                                      first_name,
                                                      last_name,
                                                      age,
                                                      mother_id,
                                                      father_id,
                                                      partner,
                                                      children,
                                                      gender,
                                                      profession,
                                                      alive,
                                                      health)
                                     self$hair_color <- hair_color
                                   },

                                   #' Handles logic for the winik that's done each day
                                   #'
                                   #' @return None
                                   propagate = function() {
                                     self$age <- self$age + 1
                                   },


                                   #' Returns a data.frame representation of the winik
                                   #'
                                   #' @description I hope there's a more scalable way to do this in R; Adding every new attribute to this
                                   #' function isn't practical
                                   #' @details The village_state holds a copy of all of the villagers at each timestep; this method is used to turn
                                   #' the winik properties into the object inserted in the village_state.
                                   #' @export
                                   #' @return A data.frame representation of the winik
                                   as_table = function() {
                                     winik_tibble <- data.frame(
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



initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
  for (i in 1:10) {
    name <- runif(1, 0.0, 100)
    new_winik <- villager_extended$new(first_name <- name, last_name <- "Smith", hair_color="Red")
    winik_mgr$add_winik(new_winik)
  }
}

# Create the model that, each day, checks to see whether or not any resource expire
model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  # Figure out how many days have passed
  days_passed <- gregorian::diff_days(resource$creation_date, current_state$date)
  # Loop over all of the resources and check if any expire
  for (villager in winik_mgr$get_living_winiks()) {
    if (days_passed > 365) {
      print("Setting hair color to grey")
      villager$hair_color <- "Grey"
    }
  }
}
# Create the village and simulation
coastal_village <- village$new("Village with expiring resources", initial_condition, model)
simulator <- simulation$new("100-01-01", "101-01-04", villages = list(coastal_village))
simulator$run_model()




```





