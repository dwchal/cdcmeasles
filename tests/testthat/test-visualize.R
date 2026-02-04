# Tests for visualization functions in cdcmeasles

# Skip all visualization tests if ggplot2 is not available
skip_if_not_installed("ggplot2")

# Create sample data for testing
sample_weekly_data <- data.frame(
  week_start = as.Date(c("2023-01-01", "2023-01-08", "2023-01-15", "2023-01-22")),
  week_end = as.Date(c("2023-01-07", "2023-01-14", "2023-01-21", "2023-01-28")),
  cases = c(10, 15, 8, 12)
)

sample_yearly_data <- data.frame(
  year = c(2018, 2019, 2020, 2021, 2022, 2023),
  cases = c(372, 1282, 13, 49, 118, 58),
  states_with_cases = c(17, 31, 8, 16, 22, 18)
)

sample_state_data <- data.frame(
  state = c("california", "texas", "new york", "florida"),
  cases = c(50, 30, 45, 20)
)

# Tests for plot_measles_time_series
test_that("plot_measles_time_series returns ggplot object", {
  p <- plot_measles_time_series(sample_weekly_data)
  expect_s3_class(p, "ggplot")
})
test_that("plot_measles_time_series validates input data", {
  expect_error(
    plot_measles_time_series("not a data frame"),
    "'data' must be a data frame"
  )

  expect_error(
    plot_measles_time_series(data.frame()),
    "'data' contains no rows"
  )
})

test_that("plot_measles_time_series checks for required columns", {
  bad_data <- data.frame(x = 1:3, y = 1:3)

  expect_error(
    plot_measles_time_series(bad_data),
    "Column 'week_start' not found"
  )

  expect_error(
    plot_measles_time_series(bad_data, date_col = "x"),
    "Column 'cases' not found"
  )
})

test_that("plot_measles_time_series respects custom parameters", {
  p <- plot_measles_time_series(
    sample_weekly_data,
    title = "Custom Title",
    subtitle = "Custom Subtitle",
    line_color = "blue",
    show_points = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Custom Title")
  expect_equal(p$labels$subtitle, "Custom Subtitle")
})

test_that("plot_measles_time_series works with yearly data", {
  p <- plot_measles_time_series(
    sample_yearly_data,
    date_col = "year",
    title = "Yearly Cases"
  )

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$x, "Year")
})

# Tests for plot_measles_bars
test_that("plot_measles_bars returns ggplot object", {
  p <- plot_measles_bars(sample_yearly_data)
  expect_s3_class(p, "ggplot")
})

test_that("plot_measles_bars validates input", {
  expect_error(
    plot_measles_bars("not a data frame"),
    "'data' must be a data frame"
  )
})

test_that("plot_measles_bars checks for required columns", {
  bad_data <- data.frame(x = 1:3, y = 1:3)

  expect_error(
    plot_measles_bars(bad_data),
    "Column 'year' not found"
  )
})

test_that("plot_measles_bars handles highlight_recent option", {
  p_no_highlight <- plot_measles_bars(sample_yearly_data, highlight_recent = FALSE)
  p_highlight <- plot_measles_bars(sample_yearly_data, highlight_recent = TRUE)

  expect_s3_class(p_no_highlight, "ggplot")
  expect_s3_class(p_highlight, "ggplot")
})

test_that("plot_measles_bars respects custom parameters", {
  p <- plot_measles_bars(
    sample_yearly_data,
    title = "Custom Bar Title",
    fill_color = "steelblue"
  )

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Custom Bar Title")
})

# Tests for plot_measles_state_map
test_that("plot_measles_state_map returns ggplot object when maps available", {
  skip_if_not_installed("maps")

  p <- plot_measles_state_map(sample_state_data)
  expect_s3_class(p, "ggplot")
})

test_that("plot_measles_state_map validates input", {
  skip_if_not_installed("maps")

  expect_error(
    plot_measles_state_map("not a data frame"),
    "'data' must be a data frame"
  )
})

test_that("plot_measles_state_map checks for required columns", {
  skip_if_not_installed("maps")

  bad_data <- data.frame(x = 1:3, y = 1:3)

  expect_error(
    plot_measles_state_map(bad_data),
    "Column 'state' not found"
  )
})

test_that("plot_measles_state_map respects custom parameters", {
  skip_if_not_installed("maps")

  p <- plot_measles_state_map(
    sample_state_data,
    title = "Custom Map Title",
    low_color = "yellow",
    high_color = "red"
  )

  expect_s3_class(p, "ggplot")
  expect_equal(p$labels$title, "Custom Map Title")
})

# Tests for plot_measles_dashboard
test_that("plot_measles_dashboard returns plot with weekly data only", {
  p <- plot_measles_dashboard(sample_weekly_data)
  expect_s3_class(p, "ggplot")
})

test_that("plot_measles_dashboard works with both data types", {
  # This will return combined plot if patchwork is available,
  # otherwise just the weekly plot
  p <- plot_measles_dashboard(sample_weekly_data, sample_yearly_data)

  # Should be either a ggplot or a patchwork object
  expect_true(inherits(p, "ggplot") || inherits(p, "patchwork"))
})
