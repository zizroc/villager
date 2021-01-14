# villager
  <!-- badges: start -->
  [![Codecov test coverage](https://codecov.io/gh/zizroc/villager/branch/master/graph/badge.svg)](https://codecov.io/gh/zizroc/villager?branch=master)
  <!-- badges: end -->

## Installing
To install villager, you'll need to have the [`devtools`](https://github.com/r-lib/devtools) library installed. This is because the package hasn't been published to a repository yet, and `devtools` has a way to install from a GitHub repository.

To install `devtools` run the following from RStudio
```
install.packages("devtools")
```

Use the `devtools` library to install villager. Note that as of when this was written, this repository is private and the following won't work. Instead, clone the repositoy and install it through RStudio.

```
devtools::install_github("zizroc/villager")
```

## Using villager
Use `library(villager)` to import _villager_.

### Creating a Base Model

The most basic model: one that doesn't do anything, can be created from two classes. In fact, all simulations will involve these two classes.
```
  plains_village <- BaseVillage$new()
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()
```

### Adding a Model to a Village
To create an add a new model to village, start by creating the model template, shown below.
```
  test_model <- function(currentState, previousState, modelData, winik_mgr, resource_mgr) {
    if (currentState$year == 1) {
      # initial condition logic here
    } else {
      # 
  }
```
The model is then passed into the BaseVillage constructor.
```
  plains_village <- BaseVillage$new(models=test_model)
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()
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
The model is then passed into the BaseVillage constructor.
```
  plains_village <- BaseVillage$new(models=test_model)
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()
```


#### Adding Resources to a Model
The `resource_manager` class is used to add resources to a village.
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
```
The model is then passed into the BaseVillage constructor.
```
  plains_village <- BaseVillage$new(models=test_model)
  new_siumulator <- Simulation$new(length = 3, villages = list(plains_village))
  new_siumulator$run_model()
```
