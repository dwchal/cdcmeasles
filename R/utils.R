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
  # List of potential URLs to try, matching those in get_measles_data()
  urls <- c(
    # Primary URLs
    "https://www.cdc.gov/measles/downloads/measlescases.csv",
    "https://www.cdc.gov/measles/data-research/measlescases.csv",
    "https://data.cdc.gov/api/views/byrd-z4cn/rows.csv",  # CDC WONDER API pattern
    # Alternative URLs
    "https://www.cdc.gov/measles/downloads/measles-data.csv",
    "https://www.cdc.gov/measles/downloads/measles-cases.csv",
    "https://data.cdc.gov/resource/byrd-z4cn.csv"  # Socrata API pattern
  )
  
  data_available <- FALSE
  
  for (url in urls) {
    if (verbose) message(paste("Checking availability of:", url))
    
    available <- tryCatch({
      response <- httr::GET(url)
      status <- httr::status_code(response)
      
      if (status == 200) {
        # Also check if the response has content
        content <- httr::content(response, as = "text", encoding = "UTF-8")
        if (!grepl("^\\s*$", content)) {
          if (verbose) message(paste("CDC measles data source is available at:", url))
          data_available <- TRUE
          break
        } else {
          if (verbose) message("URL returned empty content.")
        }
      } else {
        if (verbose) message(paste("URL returned status code:", status))
      }
      
      FALSE
    }, error = function(e) {
      if (verbose) message(paste("Error checking", url, ":", e$message))
      FALSE
    })
    
    if (available) {
      return(TRUE)
    }
  }
  
  if (!data_available) {
    if (verbose) {
      message("CDC measles data is currently unavailable from known sources.")
      message("Please check the CDC website at https://www.cdc.gov/measles/data-research/index.html")
      message("for the latest data structure or download the data manually.")
    }
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