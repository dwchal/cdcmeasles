#' Check if CDC Measles Data is Available
#'
#' This function checks if the CDC measles data URLs are accessible.
#'
#' @return Logical. TRUE if at least one data source is available, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#' is_data_available()
#' }
#'
#' @importFrom httr GET status_code
#'
#' @export
is_data_available <- function() {
  # Primary URL
  primary_url <- "https://www.cdc.gov/measles/downloads/measles-data.csv"
  # Alternative URL
  alt_url <- "https://www.cdc.gov/measles/downloads/measlescases.csv"
  
  tryCatch({
    # Check primary URL
    primary_status <- httr::status_code(httr::GET(primary_url))
    if (primary_status == 200) {
      message("Primary CDC measles data source is available.")
      return(TRUE)
    }
    
    # Check alternative URL if primary fails
    alt_status <- httr::status_code(httr::GET(alt_url))
    if (alt_status == 200) {
      message("Alternative CDC measles data source is available.")
      return(TRUE)
    }
    
    message("CDC measles data is currently unavailable from known sources.")
    return(FALSE)
  }, error = function(e) {
    message("Error checking data availability: ", e$message)
    return(FALSE)
  })
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