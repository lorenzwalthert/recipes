library(testthat)
library(recipes)
library(tibble)

context("General tidy method")

data(okc)

set.seed(131)
okc_rec <- recipe(~ ., data = okc) %>%
  step_other(all_nominal(), threshold = 0.05, other = "another") %>%
  step_date(date, features = "dow") %>%
  step_center(all_numeric()) %>%
  step_dummy(all_nominal()) %>%
  check_cols(starts_with("date"))

test_that('untrained', {
  exp_res_1 <- tibble(
    number = 1:5,
    operation = c("step", "step", "step", "step", "check"),
    type = c("other", "date", "center", "dummy", "cols"),
    trained = rep(FALSE, 5),
    skip = rep(FALSE, 5),
    id = vapply(okc_rec$steps, function(x) x$id, character(1))
  )
  expect_equal(tidy(okc_rec), exp_res_1)
})


test_that('trained', {
  exp_res_2 <- tibble(
    number = 1:5,
    operation = c("step", "step", "step", "step", "check"),
    type = c("other", "date", "center", "dummy", "cols"),
    trained = rep(TRUE, 5),
    skip = rep(FALSE, 5),
    id = vapply(okc_rec$steps, function(x) x$id, character(1))
  )
  expect_warning(
    trained <- prep(okc_rec, training = okc)
  )
  expect_equal(tidy(trained), exp_res_2)
})


test_that('bad args', {
  expect_error(tidy(trained, number = NULL))
  expect_error(tidy(trained, number = 100))
  expect_error(tidy(recipe(x = iris)))
})

