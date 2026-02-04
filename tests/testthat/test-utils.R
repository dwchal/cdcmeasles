# Tests for utility functions in cdcmeasles

test_that("get_cdc_urls returns expected structure", {
  urls <- get_cdc_urls()

  expect_type(urls, "list")
  expect_named(urls, c("weekly", "yearly", "info"))
  expect_true(all(grepl("^https://", urls)))
  expect_true(grepl("MeaslesCasesWeekly", urls$weekly))
  expect_true(grepl("MeaslesCasesYear", urls$yearly))
})

test_that("get_measles_metadata returns expected structure", {
  meta <- get_measles_metadata()

  expect_type(meta, "list")
  expect_true("source" %in% names(meta))
  expect_true("data_urls" %in% names(meta))
  expect_true("weekly_columns" %in% names(meta))
  expect_true("yearly_columns" %in% names(meta))
  expect_true("last_checked" %in% names(meta))

  # Check that last_checked is a Date

  expect_s3_class(meta$last_checked, "Date")

  # Check data_urls structure
  expect_type(meta$data_urls, "list")
  expect_named(meta$data_urls, c("weekly", "yearly"))
})

test_that("get_measles_data validates type argument", {
  expect_error(
    get_measles_data(type = "invalid"),
    "'arg' should be one of"
  )
})

test_that("clean_measles_data validates input", {
  # Test with non-data frame
  expect_error(
    clean_measles_data("not a data frame"),
    "Input must be a data frame"
  )

  # Test with empty data frame
  empty_df <- data.frame()
  expect_warning(
    result <- clean_measles_data(empty_df),
    "Input data frame is empty"
  )
})

test_that("clean_measles_data handles column name conversion", {
  df <- data.frame(
    CASES = c(10, 20, 30),
    YEAR = c(2020, 2021, 2022)
  )

  result <- clean_measles_data(df)

  expect_true(all(names(result) == tolower(names(result))))
  expect_true("cases" %in% names(result))
  expect_true("year" %in% names(result))
})

test_that("clean_measles_data converts date columns", {
  df <- data.frame(
    week_start = c("2023-01-01", "2023-01-08"),
    cases = c(5, 10)
  )

  result <- clean_measles_data(df)

  expect_s3_class(result$week_start, "Date")
})

test_that("clean_measles_data converts numeric columns", {
  df <- data.frame(
    cases = c("10", "20", "30"),
    year = c("2020", "2021", "2022")
  )

  result <- clean_measles_data(df)

  expect_type(result$cases, "double")
  expect_type(result$year, "double")
})

test_that("clean_measles_data removes NA when requested", {
  df <- data.frame(
    cases = c(10, NA, 30),
    year = c(2020, 2021, 2022)
  )

  result_keep <- clean_measles_data(df, remove_na = FALSE)
  result_remove <- clean_measles_data(df, remove_na = TRUE)

  expect_equal(nrow(result_keep), 3)
  expect_equal(nrow(result_remove), 2)
})

# Integration tests that require network access
# These are skipped by default and only run when CDCMEASLES_TEST_NETWORK=true
test_that("is_data_available returns logical vector", {
  skip_if_not(
    identical(Sys.getenv("CDCMEASLES_TEST_NETWORK"), "true"),
    "Skipping network tests. Set CDCMEASLES_TEST_NETWORK=true to run."
  )

  result <- is_data_available(verbose = FALSE)

  expect_type(result, "logical")
  expect_named(result, c("weekly", "yearly"))
})

test_that("get_measles_data returns data frame when available", {
  skip_if_not(
    identical(Sys.getenv("CDCMEASLES_TEST_NETWORK"), "true"),
    "Skipping network tests. Set CDCMEASLES_TEST_NETWORK=true to run."
  )

  weekly <- get_measles_data("weekly", verbose = FALSE)
  yearly <- get_measles_data("yearly", verbose = FALSE)

  # One of them should be available
  if (!is.null(weekly)) {
    expect_s3_class(weekly, "data.frame")
    expect_true("cases" %in% names(weekly))
  }

  if (!is.null(yearly)) {
    expect_s3_class(yearly, "data.frame")
    expect_true("year" %in% names(yearly))
    expect_true("cases" %in% names(yearly))
  }
})

test_that("get_current_year_summary returns expected structure", {
  skip_if_not(
    identical(Sys.getenv("CDCMEASLES_TEST_NETWORK"), "true"),
    "Skipping network tests. Set CDCMEASLES_TEST_NETWORK=true to run."
  )

  summary <- get_current_year_summary(verbose = FALSE)

  if (!is.null(summary)) {
    expect_type(summary, "list")
    expect_true("year" %in% names(summary))
    expect_true("total_cases" %in% names(summary))
    expect_true("data_type" %in% names(summary))
  }
})
