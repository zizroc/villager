# villager


## Installing
To install villager, you'll need to have the [`devtools`](https://github.com/r-lib/devtools) library installed. This is because the package hasn't been published to a repository yet, and `devtools` has a way to install from a GitHub repository.

To install `devtools` run the following from RStudio
```
install.packages("devtools")
```

To install `villager`, run the following

```
devtools::install_github("zizroc/villager")
```


## Using villager






## Developing
villager is an open source project and welcomes contributions. Before making a contribution, be sure to create an issue ahead of time for feedback. In some cases features may already be planned and in work.

### Pull Requests
When contributing code, issue a pull request to the `master` branch. The pull request should have a summary of what was done and how to test that it works. These are generally reviewed by one to two people. Expect up to a weeks time for a complete code review.

### Unit Tests
Code additions and changes should be accompanied by relavant unit tests. After issuing a pull request, make sure that the test coverage hasn't decreased.

### Developing
To work on the library, clone the repository with
`git clone `
Open the project in RStudio, and use the `Build` tab in the upper right quadrant to check and install the package.
The tidyverse style _should_ be used, right now it's not.

