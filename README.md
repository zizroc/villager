# villager
[![Codecov test coverage](https://codecov.io/gh/zizroc/villager/branch/master/graph/badge.svg)](https://codecov.io/gh/zizroc/villager?branch=main)

villager is a framework for creating and running agent based models in R. It's purpose is to provide an extensible framework where modeling can be done in native R.

## Features
- Extensible data output system (csv, excel sheets, sqlite)
- Built in support for agents and resources
- Easy to use date management

## Installing
villager should be installed with [`devtools`](https://github.com/r-lib/devtools).

```
devtools::install_github("zizroc/villager")
```

## Takeaways
When reading though the Readme and vignettes, it's important to take note of a few concepts

- Date times should use the [gregorian](edgararuiz/gregorian) package
- Villages are the highest aggregate; they contain villages which in turn contain agents (winiks)
- Agents and resources can be subclassed to support additional properties 
- The data_writer class can be subclassed when writing to data sources other than csv
- Models are functions that are added to villages; each village can exhibit different behavior

## Using villager

`villager` is about modeling populations with (optional) associated resources. It supports a community level aggregation of agents, referred to as _villages_ or an individual _village_. Agents, which are referred to as gender-neutral _winiks_, are members of community level aggregations. 

villager compliant models _must_ conform to the function template below. The `winik_mgr` and `resource_mgr` are responsible for interacting with the individual agents and resources. 

```{r}
test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  ...
  ...
}
```

### Creating & Managing Agents

Agents are created by instantiating the `winik` class. There are a number of winik properties that can be passed to the constructor.

```{r}
test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  mother <- winik$new(first_name="Kirsten", last_name="Taylor", age=9125)
  father <- winik$new(first_name="Joshua", last_name="Thompson", age=7300)
  daughter <- winik$new(first_name="Mariylyyn", last_name="Thompson", age=10220)
}
```

To add winiks to the simulation, use the provided `winik_mgr` object to call `add_winik`. Because the classes are R6, the object can be modified after being added to the manager and the changes will be persisted without needing to re-add the villager. For example, setting a daughter's mother and her father below. Note that the standard way is to modify the properties _beforehand_, although not strictly necessary.

```{r}
test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  winik_mgr <- winik_manager$new()
  winik_mgr$add_winik(mother)
  winik_mgr$add_winik(father)
  winik_mgr$add_winik(daughter)
  daughter$mother_id <- mother$identifier
  daughter$father_id <- father$identifier
}
```

The winik manager can also be used to pair winiks, representitive of a relationship or social bond.
```
winik_mgr$winik_mgr$connect_winiks(mother, father)
```

### Creating & Managing Resources

Resources are similar to winiks in that they're both R6 classes, are instantiated similarly, and are also managed by an object passed into the model. An example of creating resources and adding them to the simualtion is given below.

```
test_model <- function(current_state, previous_state, model_data, winik_mgr, resource_mgr) {
  corn_resource <- resource$new(name="corn", quantity = 10)
  fish_resource <- resource$new(name="fish", quantity = 15)
  corn_resource$quantity=5
  
  resource_mgr <- resource_manager$new()
  resource_mgr$add_resource(corn_resource)
  resource_mgr$add_resource(fish_resource)
  fish_resource$quantity=5
}
```

### State

Objects of type `village`, `winik`, and `resource`have particular states at a particular time. As the simulation progresses, the state of these change based on model logic. At the end of each time step, the state of each object is saved, giving a compelte record of the system's evolution. The essance of any agent based model is changing the state at each time step. villager provides a mechanim for defining the initial state and for changing the state throughout the simulation.

### Managing the Initial State

Creating the initial state is done by creating a function that resembles model functions from above. The manager classes are used to populate the village with an initial population of agents and resources.

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


## Creating Villages and Running Models

Models are tied to particular village instances. This binding is done when villages are created, shown below. Models can have names and must always be paired with an initial condition function and a model function.

```{r}
small_village <- village$new("Test Model 1", initial_condition, test_model)
```

The `simulator` class is responsible for running simulations. It encapsulates _all_ of the villages and controls the duration of the simulation. The simulator below runs for 13 years. The simulator can be paired with any number of villages, in the case of the simulator below, there's only a single village.

```
simulator <- simulation$new("-100-01-01", "-87-01-01", list(small_village))
simulator$run_model()
```

### Example: A small village with a single family

We can combine the examples above into a full simulation that...

- Starts with an initial population of three villagers
- Increases the age of each villager at the start of each day
- Runs for 13 years
- Sets the villager profession after age 12


```{r}
library(villager)
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
library(villager)
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

## Advanced Usage

In the examples above, the default properties of agents and resources were used. It's possible that these won't cover all the needs for more diverse models. There are vignettes on extending the agent and resource classes to handle these situations.
