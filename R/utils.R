#' Check if CDC Measles Data is Available
#'
#' This function checks if the CDC measles data URLs are accessible.
#'
#' @param verbose Logical. If TRUE, prints detailed messages during checks. Default is FALSE.
#' @return Logical. TRUE if at least one data source is available, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#' is_data_available()
#' is_data_available(verbose = TRUE)
#' }
#'
#' @importFrom httr GET status_code
#'
#' @export
is_data_available <- function(verbose = FALSE) {
  urls <- list(
    weekly = "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json",
    yearly = "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json"
  )
  
  data_available <- FALSE
  
  for (type in names(urls)) {
    url <- urls[[type]]
    if (verbose) {
      message(sprintf("Checking %s data URL: %s", type, url))
    }
    
    tryCatch({
      response <- httr::GET(url)
      if (httr::status_code(response) == 200) {
        content <- httr::content(response, "text")
        if (nchar(content) > 0) {
          data_available <- TRUE
          if (verbose) {
            message(sprintf("%s data is available", type))
          }
        }
      } else if (verbose) {
        message(sprintf("%s data URL returned status code: %d", 
                       type, httr::status_code(response)))
      }
    }, error = function(e) {
      if (verbose) {
        message(sprintf("Error checking %s data: %s", type, e$message))
      }
    })
  }
  
  if (!data_available && verbose) {
    message("No data sources are currently available")
    message("Please check https://www.cdc.gov/measles/cases-outbreaks.html")
    message("for the latest information about measles cases")
  }
  
  return(data_available)
}

#' Clean Measles Data
#'
#' This function cleans and formats the raw measles data from CDC.
#'
#' @param data A data frame of raw measles data from CDC.
#'
#' @return A cleaned data frame.
#'
#' @importFrom dplyr mutate select filter
#'
#' @keywords internal
clean_measles_data <- function(data) {
  # This function will need to be customized based on the actual structure
  # of the CDC measles data, which may vary
  
  tryCatch({
    # Basic cleaning operations
    # 1. Convert column names to lowercase
    names(data) <- tolower(names(data))
    
    # 2. Try to convert date columns to proper date format
    # (Exact column names will depend on the actual data structure)
    if ("date" %in% names(data)) {
      data$date <- as.Date(data$date)
    } else if ("week" %in% names(data) && "year" %in% names(data)) {
      # Some CDC data uses week/year format
      # This would need custom handling
    }
    
    # 3. Convert numeric columns to numeric type
    # (Again, exact columns depend on the data structure)
    numeric_cols <- names(data)[sapply(data, is.character) & 
                               grepl("cases|count|number", names(data))]
    
    for (col in numeric_cols) {
      data[[col]] <- as.numeric(data[[col]])
    }
    
    return(data)
  }, error = function(e) {
    warning("Error cleaning data: ", e$message, "\nReturning original data.")
    return(data)
  })
}

#' Get Metadata for CDC Measles Dataset
#'
#' This function returns metadata about the CDC measles dataset.
#'
#' @return A list containing metadata about the dataset.
#'
#' @examples
#' \dontrun{
#' get_measles_metadata()
#' }
#'
#' @export
get_measles_metadata <- function() {
  list(
    source = "Centers for Disease Control and Prevention (CDC)",
    url = "https://www.cdc.gov/measles/data-research/index.html",
    description = "Measles case data reported to CDC",
    update_frequency = "Varies, check CDC website for details",
    last_checked = Sys.Date()
  )
}

#' Get measles case data from CDC
#'
#' @description
#' Downloads and processes measles case data from the CDC website.
#' The function can retrieve either weekly or yearly data.
#'
#' @param type Character. Either "weekly" or "yearly" to specify which dataset to retrieve.
#' @param verbose Logical. If TRUE, prints detailed messages during download. Default is FALSE.
#' @return A data frame containing measles case data, or NULL if download fails.
#' @export
get_measles_data <- function(type = c("weekly", "yearly"), verbose = FALSE) {
  type <- match.arg(type)
  
  urls <- list(
    weekly = "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json",
    yearly = "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json"
  )
  
  url <- urls[[type]]
  
  if (verbose) {
    message(sprintf("Attempting to download %s data from: %s", type, url))
  }
  
  tryCatch({
    response <- httr::GET(url)
    if (httr::status_code(response) == 200) {
      json_data <- jsonlite::fromJSON(httr::content(response, "text"))
      
      # Convert to data frame
      df <- as.data.frame(json_data, stringsAsFactors = FALSE)
      
      # Convert columns based on data type
      if (type == "weekly") {
        df$week_start <- as.Date(df$week_start)
        df$week_end <- as.Date(df$week_end)
        df$cases <- as.numeric(df$cases)
      } else {
        # Yearly data conversions
        df$year <- as.numeric(df$year)
        df$cases <- as.numeric(df$cases)
        df$states_with_cases <- as.numeric(df$states_with_cases)
        # Keep outbreaks columns as character as they contain mixed data
      }
      
      if (verbose) {
        message(sprintf("Successfully processed %s data", type))
      }
      return(df)
    } else {
      if (verbose) {
        message(sprintf("Failed to download data: HTTP status code %d", 
                       httr::status_code(response)))
      }
    }
  }, error = function(e) {
    if (verbose) {
      message(sprintf("Error downloading data: %s", e$message))
    }
  })
  
  return(NULL)
} 