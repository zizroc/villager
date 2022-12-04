# Unit tests for the agent manager

test_that("the constructor works", {
  agent_mgr <- agent_manager$new()
  testthat::expect_equal(length(agent_manager$agents), 0)
})

test_that("agents are correctly added to the manager", {
  agent_mgr <- agent_manager$new()
  agent_1_id <- "test_identifier_1"
  agent_2_id <- "test_identifier_2"
  test_agent_1 <- agent$new(identifier = agent_1_id)
  test_agent_2 <- agent$new(identifier = agent_2_id)

  agent_mgr$add_agent(test_agent_1)
  testthat::expect_equal(length(agent_mgr$agents), 1)
  testthat::expect_equal(agent_mgr$agents[[1]]$identifier, agent_1_id)
  agent_mgr$add_agent(test_agent_2)
  testthat::expect_equal(length(agent_mgr$agents), 2)
})

test_that("the manager gets the correct agents", {
  agent_mgr <- agent_manager$new()
  agent_1_id <- "test_identifier_1"
  agent_2_id <- "test_identifier_2"
  agent_3_id <- "test_identifier_3"
  test_agent_1 <- agent$new(identifier = agent_1_id)
  test_agent_2 <- agent$new(identifier = agent_2_id)
  test_agent_3 <- agent$new(identifier = agent_3_id)

  agent_mgr$add_agent(test_agent_1, test_agent_2, test_agent_3)

  should_be_agent_1 <- agent_mgr$get_agent(test_agent_1$identifier)
  testthat::expect_equal(should_be_agent_1$identifier, test_agent_1$identifier)
})

test_that("the manager returns the correct agent index", {
  agent_mgr <- agent_manager$new()
  agent_1_id <- "test_identifier_1"
  agent_2_id <- "test_identifier_2"
  agent_3_id <- "test_identifier_3"
  test_agent_1 <- agent$new(identifier = agent_1_id)
  test_agent_2 <- agent$new(identifier = agent_2_id)
  test_agent_3 <- agent$new(identifier = agent_3_id)

  agent_mgr$add_agent(test_agent_1, test_agent_2, test_agent_3)

  index <- agent_mgr$get_agent_index(test_agent_2$identifier)
  expect_true(index == 2)
})

test_that("the manager removes agents", {
  agent_mgr <- agent_manager$new()
  agent_1_id <- "test_identifier_1"
  agent_2_id <- "test_identifier_2"
  agent_3_id <- "test_identifier_3"
  test_agent_1 <- agent$new(identifier = agent_1_id)
  test_agent_2 <- agent$new(identifier = agent_2_id)
  test_agent_3 <- agent$new(identifier = agent_3_id)

  agent_mgr$add_agent(test_agent_1, test_agent_2, test_agent_3)

  agent_mgr$remove_agent(test_agent_1$identifier)
  testthat::expect_length(agent_mgr$agents, 2)
})

test_that("get_living_agents only returns agents that are living", {
  agent_mgr <- agent_manager$new()
  agent_1_id <- "test_identifier_1"
  agent_2_id <- "test_identifier_2"
  agent_3_id <- "test_identifier_3"
  agent_4_id <- "test_identifier_4"
  test_agent_1 <- agent$new(identifier = agent_1_id, alive = FALSE)
  test_agent_2 <- agent$new(identifier = agent_2_id, alive = TRUE)
  test_agent_3 <- agent$new(identifier = agent_3_id, alive = FALSE)
  test_agent_4 <- agent$new(identifier = agent_4_id, alive = TRUE)

  agent_mgr$add_agent(test_agent_1, test_agent_2, test_agent_3, test_agent_4)

  living_agents <- agent_mgr$get_living_agents()
  testthat::expect_length(living_agents, 2)
  testthat::expect_length(agent_mgr$agents, 4)

})

test_that("get_states returns the appropriate agent states", {
  agent_mgr <- agent_manager$new()
  agent_1_id <- "test_identifier_1"
  agent_2_id <- "test_identifier_2"
  agent_3_id <- "test_identifier_3"
  agent_4_id <- "test_identifier_4"
  test_agent_1 <- agent$new(identifier = agent_1_id, alive = FALSE)
  test_agent_2 <- agent$new(identifier = agent_2_id, alive = TRUE)
  test_agent_3 <- agent$new(identifier = agent_3_id, alive = FALSE)
  test_agent_4 <- agent$new(identifier = agent_4_id, alive = TRUE)

  agent_mgr$add_agent(test_agent_1, test_agent_2, test_agent_3, test_agent_4)

  states <- agent_mgr$get_states()

  testthat::expect_equal(states[1,]$identifier, agent_1_id)
  testthat::expect_equal(states[1,]$alive, FALSE)

  testthat::expect_equal(states[2,]$identifier, agent_2_id)
  testthat::expect_equal(states[2,]$alive, TRUE)

  testthat::expect_equal(states[3,]$identifier, agent_3_id)
  testthat::expect_equal(states[3,]$alive, FALSE)

  testthat::expect_equal(states[4,]$identifier, agent_4_id)
  testthat::expect_equal(states[4,]$alive, TRUE)
})

test_that("the manager can load agents from disk", {
  agent_mgr <- agent_manager$new()
  file_path <- "test-files/test-agents.csv"
  agent_mgr$load(file_path)

  # Test that the resources exist with the expected quantities
  jimi_hendrix <- agent_mgr$get_agent(1)
  testthat::expect_equal(jimi_hendrix$first_name, "Jimi")
  testthat::expect_equal(jimi_hendrix$last_name, "Hendrix")
  testthat::expect_equal(jimi_hendrix$mother_id, NA)
  testthat::expect_equal(jimi_hendrix$father_id, NA)
  testthat::expect_equal(jimi_hendrix$profession, "musician")
  testthat::expect_equal(jimi_hendrix$partner, 2)
  testthat::expect_equal(jimi_hendrix$gender, "male")
  testthat::expect_equal(jimi_hendrix$alive, FALSE)
  testthat::expect_equal(jimi_hendrix$age, 27)

  janis_joplin <- agent_mgr$get_agent(2)
  testthat::expect_equal(janis_joplin$first_name, "Janis")
  testthat::expect_equal(janis_joplin$last_name, "Joplin")
  testthat::expect_equal(janis_joplin$mother_id, NA)
  testthat::expect_equal(janis_joplin$father_id, NA)
  testthat::expect_equal(janis_joplin$profession, "musician")
  testthat::expect_equal(janis_joplin$partner, 1)
  testthat::expect_equal(janis_joplin$gender, "female")
  testthat::expect_equal(janis_joplin$alive, FALSE)
  testthat::expect_equal(janis_joplin$age, 27)

  jim_morrison <- agent_mgr$get_agent(3)
  testthat::expect_equal(jim_morrison$first_name, "Jim")
  testthat::expect_equal(jim_morrison$last_name, "Morrison")
  testthat::expect_equal(jim_morrison$mother_id, NA)
  testthat::expect_equal(jim_morrison$father_id, NA)
  testthat::expect_equal(jim_morrison$profession, "musician")
  testthat::expect_true(is.na(jim_morrison$partner))
  testthat::expect_equal(jim_morrison$gender, "male")
  testthat::expect_equal(jim_morrison$alive, FALSE)
  testthat::expect_equal(jim_morrison$age, 27)
})

test_that("the agent manager can properly add children to parents", {
  agent_mgr <- agent_manager$new()

  # Create two sets of parents
  mother_1 <- agent$new(identifier = "mother1", alive = TRUE)
  mother_2 <- agent$new(identifier = "mother2", alive = TRUE)
  father_1 <- agent$new(identifier = "father1", alive = TRUE)
  father_2 <- agent$new(identifier = "father2", alive = TRUE)
  agent_mgr$add_agent(mother_1, mother_2, father_1, father_2)
  # Connect the mom and dads
  agent_mgr$connect_agents(mother_1, father_1)
  agent_mgr$connect_agents(mother_2, father_2)

  # Make sure that they're really connected
  testthat::expect_equal(mother_1$partner, father_1$identifier)
  testthat::expect_equal(father_1$partner, mother_1$identifier)
  testthat::expect_equal(mother_2$partner, father_2$identifier)
  testthat::expect_equal(father_2$partner, mother_2$identifier)


  # Create two children for the first set of parents
  child1 <-
    agent$new(
      identifier = "child1",
      alive = TRUE,
      mother_id = mother_1$identifier,
      father_id = father_1$identifier
    )
  child2 <-
    agent$new(
      identifier = "child2",
      alive = TRUE,
      mother_id = mother_1$identifier,
      father_id = father_1$identifier
    )
  # Create another two for the other parents
  child3 <-
    agent$new(
      identifier = "child3",
      alive = TRUE,
      mother_id = mother_2$identifier,
      father_id = father_2$identifier
    )
  child4 <-
    agent$new(
      identifier = "child4",
      alive = TRUE,
      mother_id = mother_2$identifier,
      father_id = father_2$identifier
    )

  agent_mgr$add_agent(child1, child2, child3, child4)

  # Use the agent manager to add the children to the parents
  agent_mgr$add_children()
  testthat::expect_length(mother_1$children, 2)
  testthat::expect_length(father_1$children, 2)
  testthat::expect_length(mother_2$children, 2)
  testthat::expect_length(father_2$children, 2)
})
