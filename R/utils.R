# CDC Measles Data URLs (centralized for easy maintenance)
.cdc_urls <- list(

  weekly = "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json",
  yearly = "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json",
  info = "https://www.cdc.gov/measles/data-research/index.html"
)

#' Get CDC Measles Data URLs
#'
#' Returns the URLs used by this package to access CDC measles data.
#' Useful for debugging or checking if URLs have changed.
#'
#' @return A named list containing the data URLs.
#'
#' @examples
#' get_cdc_urls()
#'
#' @export
get_cdc_urls <- function() {
  .cdc_urls
}

#' Check if CDC Measles Data is Available
#'
#' Tests connectivity to CDC measles data endpoints. This is useful to verify
#' that the CDC data sources are accessible before attempting to download data.
#'
#' @param verbose Logical. If `TRUE`, prints detailed messages during checks.
#'   Default is `FALSE`.
#'
#' @return A named logical vector indicating availability of each data source
#'   (weekly and yearly). Returns `TRUE` for sources that are accessible and
#'   contain data, `FALSE` otherwise.
#'
#' @examples
#' \dontrun{
#' # Quick check
#' is_data_available()
#'
#' # Detailed check with messages
#' is_data_available(verbose = TRUE)
#' }
#'
#' @importFrom httr GET status_code content
#'
#' @export
is_data_available <- function(verbose = FALSE) {
  results <- c(weekly = FALSE, yearly = FALSE)

  for (type in c("weekly", "yearly")) {
    url <- .cdc_urls[[type]]
    if (verbose) {
      message(sprintf("Checking %s data URL: %s", type, url))
    }

    tryCatch({
      response <- httr::GET(url, httr::timeout(10))
      if (httr::status_code(response) == 200) {
        content <- httr::content(response, "text", encoding = "UTF-8")
        if (nchar(content) > 0) {
          results[[type]] <- TRUE
          if (verbose) {
            message(sprintf("  [OK] %s data is available", type))
          }
        }
      } else if (verbose) {
        message(sprintf("  [FAILED] %s data URL returned status code: %d",
                        type, httr::status_code(response)))
      }
    }, error = function(e) {
      if (verbose) {
        message(sprintf("  [ERROR] Checking %s data: %s", type, e$message))
      }
    })
  }

  if (!any(results) && verbose) {
    message("\nNo data sources are currently available.")
    message("Please check ", .cdc_urls$info, " for the latest information.")
  }

  return(results)
}

#' Get Metadata for CDC Measles Dataset
#'
#' Returns metadata about the CDC measles dataset including source information,
#' data URLs, and expected data structure.
#'
#' @return A list containing:
#' \describe{
#'   \item{source}{The data source (CDC)}
#'   \item{info_url}{URL to the CDC measles data information page}
#'   \item{data_urls}{Named list of data endpoint URLs}
#'   \item{description}{Brief description of the data}
#'   \item{weekly_columns}{Expected columns in weekly data}
#'   \item{yearly_columns}{Expected columns in yearly data}
#'   \item{last_checked}{Date when this metadata was retrieved}
#' }
#'
#' @examples
#' meta <- get_measles_metadata()
#' print(meta$data_urls)
#'
#' @export
get_measles_metadata <- function() {
  list(
    source = "Centers for Disease Control and Prevention (CDC)",
    info_url = .cdc_urls$info,
    data_urls = list(
      weekly = .cdc_urls$weekly,
      yearly = .cdc_urls$yearly
    ),
    description = "Measles case data reported to CDC, available in weekly and yearly aggregations.",
    weekly_columns = c("week_start", "week_end", "cases"),
    yearly_columns = c("year", "cases", "states_with_cases", "outbreaks", "outbreaks_count"),
    update_frequency = "Weekly updates during active reporting; check CDC website for details",
    last_checked = Sys.Date()
  )
}

#' Get Measles Case Data from CDC
#'
#' Downloads and processes measles case data from the CDC website.
#' The function retrieves either weekly or yearly aggregated data.
#'
#' @param type Character. Either `"weekly"` or `"yearly"` to specify which
#'   dataset to retrieve. Weekly data contains recent case counts by week,
#'   while yearly data contains historical counts with outbreak information.
#'   Default is `"weekly"`.
#' @param verbose Logical. If `TRUE`, prints progress messages during download.
#'   Default is `FALSE`.
#' @param timeout Numeric. Request timeout in seconds. Default is 30.
#'
#' @return A data frame containing measles case data with the following columns:
#'
#' For weekly data:
#' \describe{
#'   \item{week_start}{Date. Start of the reporting week.}
#'   \item{week_end}{Date. End of the reporting week.}
#'   \item{cases}{Integer. Number of reported cases.}
#' }
#'
#' For yearly data:
#' \describe{
#'   \item{year}{Integer. The year of the data.}
#'   \item{cases}{Integer. Total cases for the year.}
#'   \item{states_with_cases}{Integer. Number of states reporting cases.}
#'   \item{outbreaks}{Character. Description of outbreaks during the year.}
#'   \item{outbreaks_count}{Integer. Number of outbreaks (if available).}
#' }
#'
#' Returns `NULL` if the download fails.
#'
#' @examples
#' \dontrun
#' # Get weekly data
#' weekly <- get_measles_data("weekly")
#' head(weekly)
#'
#' # Get yearly data with verbose output
#' yearly <- get_measles_data("yearly", verbose = TRUE)
#' summary(yearly)
#' }
#'
#' @importFrom httr GET status_code content timeout
#' @importFrom jsonlite fromJSON
#'
#' @export
get_measles_data <- function(type = c("weekly", "yearly"),
                              verbose = FALSE,
                              timeout = 30) {
  type <- match.arg(type)
  url <- .cdc_urls[[type]]

  if (verbose) {
    message(sprintf("Downloading %s data from: %s", type, url))
  }

  tryCatch({
    response <- httr::GET(url, httr::timeout(timeout))

    if (httr::status_code(response) != 200) {
      if (verbose) {
        message(sprintf("Failed to download data: HTTP status code %d",
                        httr::status_code(response)))
      }
      return(NULL)
    }

    json_text <- httr::content(response, "text", encoding = "UTF-8")
    json_data <- jsonlite::fromJSON(json_text)

    # Convert to data frame
    df <- as.data.frame(json_data, stringsAsFactors = FALSE)

    # Process based on data type
    if (type == "weekly") {
      df <- .process_weekly_data(df, verbose)
    } else {
      df <- .process_yearly_data(df, verbose)
    }

    if (verbose) {
      message(sprintf("Successfully retrieved %d rows of %s data", nrow(df), type))
    }

    return(df)

  }, error = function(e) {
    if (verbose) {
      message(sprintf("Error downloading data: %s", e$message))
    }
    return(NULL)
  })
}

#' Process Weekly Measles Data
#'
#' @param df Data frame of raw weekly data
#' @param verbose Logical for verbose output
#' @return Processed data frame
#' @keywords internal
#' @noRd
.process_weekly_data <- function(df, verbose = FALSE) {
  # Convert date columns
  if ("week_start" %in% names(df)) {
    df$week_start <- as.Date(df$week_start)
  }
  if ("week_end" %in% names(df)) {
    df$week_end <- as.Date(df$week_end)
  }

  # Convert cases to numeric
  if ("cases" %in% names(df)) {
    df$cases <- as.integer(df$cases)
  }

  # Sort by date (most recent first by default)
  if ("week_start" %in% names(df)) {
    df <- df[order(df$week_start, decreasing = TRUE), ]
    row.names(df) <- NULL
  }

  return(df)
}

#' Process Yearly Measles Data
#'
#' @param df Data frame of raw yearly data
#' @param verbose Logical for verbose output
#' @return Processed data frame
#' @keywords internal
#' @noRd
.process_yearly_data <- function(df, verbose = FALSE) {
  # Convert numeric columns
  numeric_cols <- c("year", "cases", "states_with_cases", "outbreaks_count")
  for (col in numeric_cols) {
    if (col %in% names(df)) {
      df[[col]] <- suppressWarnings(as.integer(df[[col]]))
    }
  }

  # Sort by year (most recent first)
  if ("year" %in% names(df)) {
    df <- df[order(df$year, decreasing = TRUE), ]
    row.names(df) <- NULL
  }

  return(df)
}

#' Clean Measles Data
#'
#' Applies standard cleaning operations to measles data. This function
#' standardizes column names, converts data types, and handles missing values.
#'
#' @param data A data frame of measles data (typically from [get_measles_data()]).
#' @param remove_na Logical. If `TRUE`, removes rows with NA case counts.
#'   Default is `FALSE`.
#'
#' @return A cleaned data frame with standardized column names (lowercase)
#'   and appropriate data types.
#'
#' @examples
#' \dontrun{
#' raw_data <- get_measles_data("weekly")
#' clean_data <- clean_measles_data(raw_data)
#' }
#'
#' @export
clean_measles_data <- function(data, remove_na = FALSE) {
  if (!is.data.frame(data)) {
    stop("Input must be a data frame")
  }

  if (nrow(data) == 0) {
    warning("Input data frame is empty")
    return(data)
  }

  # Standardize column names to lowercase
  names(data) <- tolower(names(data))

  # Convert date columns
  date_cols <- c("week_start", "week_end", "date")
  for (col in date_cols) {
    if (col %in% names(data) && !inherits(data[[col]], "Date")) {
      data[[col]] <- tryCatch(
        as.Date(data[[col]]),
        error = function(e) data[[col]]
      )
    }
  }

  # Convert numeric columns
  numeric_cols <- c("cases", "year", "states_with_cases", "outbreaks_count")
  for (col in numeric_cols) {
    if (col %in% names(data) && !is.numeric(data[[col]])) {
      data[[col]] <- suppressWarnings(as.numeric(data[[col]]))
    }
  }

  # Optionally remove rows with NA cases

if (remove_na && "cases" %in% names(data)) {
    data <- data[!is.na(data$cases), ]
  }

  return(data)
}

#' Get Current Year Measles Summary
#'
#' Convenience function to get a quick summary of measles cases for the
#' current or most recent year in the data.
#'
#' @param verbose Logical. If `TRUE`, prints progress messages. Default is `FALSE`.
#'
#' @return A list containing summary statistics, or NULL if data unavailable:
#' \describe{
#'   \item{year}{The year of the summary}
#'   \item{total_cases}{Total cases reported}
#'   \item{weeks_reported}{Number of weeks with data (for weekly data)}
#'   \item{data_type}{Type of data used for the summary}
#' }
#'
#' @examples
#' \dontrun{
#' summary <- get_current_year_summary()
#' print(summary)
#' }
#'
#' @export
get_current_year_summary <- function(verbose = FALSE) {
  # Try weekly data first
  data <- get_measles_data("weekly", verbose = verbose)

  if (!is.null(data) && nrow(data) > 0) {
    current_year <- max(format(data$week_start, "%Y"), na.rm = TRUE)
    year_data <- data[format(data$week_start, "%Y") == current_year, ]

    return(list(
      year = as.integer(current_year),
      total_cases = sum(year_data$cases, na.rm = TRUE),
      weeks_reported = nrow(year_data),
      data_type = "weekly"
    ))
  }

  # Fall back to yearly data
  data <- get_measles_data("yearly", verbose = verbose)

  if (!is.null(data) && nrow(data) > 0) {
    latest <- data[which.max(data$year), ]
    return(list(
      year = latest$year,
      total_cases = latest$cases,
      states_with_cases = latest$states_with_cases,
      data_type = "yearly"
    ))
  }

  if (verbose) {
    message("Could not retrieve measles data for summary")
  }

  return(NULL)
}
