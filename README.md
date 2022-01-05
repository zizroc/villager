# villager
[![Build Status](https://travis-ci.com/zizroc/villager.svg?branch=master)](https://travis-ci.com/zizroc/villager) [![Codecov test coverage](https://codecov.io/gh/zizroc/villager/branch/master/graph/badge.svg)](https://codecov.io/gh/zizroc/villager?branch=master)

## Installing
To install villager, you'll need to have the [`devtools`](https://github.com/r-lib/devtools) library installed. This is because the package hasn't been published to CRAN yet and `devtools` has a way to install from a GitHub repository.

To install `devtools` run the following from RStudio
```
install.packages("devtools")
```

### Installing via Zip Download

The easiest way to install _villager_ is by downloading the [zip archive](https://github.com/zizroc/villager/archive/master.zip). Open the project in RStudio and install the package by clicking `Install and Restart`.

### Installing via devtools

When this repository becomes public, it can be installed with devtools.

```
devtools::install_github("zizroc/villager")
```

## Using villager

There are a few fundamental concepts to keep in mind while modeling with _villager_.

1. Simulations contain villages and hold the date rannge for the simulation
2. Villages contain _manager_ classes for handling resources and winiks
3. The managers are exposed to users which act as the interface points for controlling a village
4. Every village must have a function that sets the initial condition

### Initial conditions

Every village must have an initial condition. The initial condition is a function that sets the initial state
of the village. The template for an initial condition is

```
initial_condition <- function(current_state, model_data, population_mgr, resource_mgr) {
  ...
  ...
}
```

Where

1. `current_state`: The village_state object for the first day
2. `model_data`: The optional model_data parameter in the village constructor
3. `population_mgr`: The manager for population. Used to add and remove villagers
4. `resource_mgr`: The manager for resources. Used to add and remove resources

#### Adding villagers to an initial state
Suppose you wanted to create a village that has an initial population of three winiks. The initial condition would look like

```
  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    for (i in 0:3) {
      new_winik <- winik$new(first_name <- i, last_name <- "smith")
      winik_mgr$add_winik(new_winik)
    }
  }
```

#### Adding Resources to an initial state
Suppose you wanted to add reasources to the initial state. This is possible with the resource_mgr parameter.

```
initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
  for (i in 0:3) {
    new_resource <- resource$new(name="corn", quantity = 10)
    resource_mgr$add_resource(new_resource)
  }
}
```

#### Adding Winiks to a Village
The `winik_mgr` object that passed into the model is used to add winiks to the village.

```
  test_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    if (currentState$year == 1) {
      # Load a number of winiks from a theoretic winik file
      winik_mgr("winiks.csv")
    } else {
      # If it's not year 1, add a winik
      new_winik<-winik$new()
      winik_mgr$add_winik(new_winik)
  }
```
=======
### Modeling

Like the initial condition, models are defined as functions. The template for a valid function is

```
model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  Model logic here
}
```

Models are added to villages in the village constructor,
```
plains_village <- village(models = model)
```

A village can have any number of model functions defined for it, enabling logic to be encapsulated and organized. For example, a second model can be created and added to the village.

```
  test_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    if (currentState$year == 1) {
      # Load any resources from disk
      resource_mgr$load("resources.csv")
      
      # Add a resource that wasn't in the file
      corn <- resource$new(name="corn", quantity=10)
    } else {
      # Add 1 to the corn stocks
      corn <- resource_mgr$get_resource("corn")
      corn$quantity <- corn$quantity + 1
  }
model_2 <- function(current_state, previous_state, model_data, population_mgr, resource_mgr) {
  # Model logic here
}
plains_village <- village(models = list(model, model_2))
```

#### Modeling Populations
Villager exposes population innformation through the `population_manager`, which is passed into the model at each day. The manager
can be used to access winiks, which can then be modified. For example, consider the following model that adds a winik to the village
each day.

```
  initial_condition <- function(current_state, model_data, population_mgr, resource_mgr) {
    # Add a single winik. This is the equivalent to saying the model starts with a single villager.
    new_winik <- winik$new(first_name <- "Sally", last_name <- "Smith")
    population_mgr$add_winik(new_winik)
  }

  model <- function(current_state, previous_state, model_data, population_mgr, resource_mgr) {
    # Create a new winik whose first name is a random number
    name <- runif(1, 0.0, 100)
    new_winik <- winik$new(first_name <- name, last_name <- "Smith")
    population_mgr$add_winik(new_winik)
  }
plains_village <- village$new(models = list(model, model_2))
```



It's also possible to encompass population logic within other structures. For example, a model that adds
two winiks to the village on even days and kills one on odd days. In this case, the `$ate` slot in `current_state` is used
to get the current date in terms of the `gregorian` R package.
```
  initial_condition <- function(current_state, model_data, winik_mgr, resource_mgr) {
    # Add a single winik. This is the equivalent to saying the model starts with a single villager.
    new_winik <- winik$new(first_name <- "Sally", last_name <- "Smith")
    winik_mgr$add_winik(new_winik)
  }

  model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
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
  simulator <- simulation$new("-100-01-01", "-100-01-04", villages = list(coastal_village))
  simulator$run_model()
  ```

#### Modeling Resources

Resources are handled very similarly to population in that there's a class that represents an inndividual
resource, _resource_. There's also a manager class that is used to manage them.

