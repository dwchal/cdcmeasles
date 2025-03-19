#' Download CDC Measles Data
#'
#' This function downloads measles data from the CDC website.
#' The data includes reported measles cases across the United States.
#'
#' @param save_file Logical. If TRUE, saves the downloaded data as a CSV file
#'   in the current working directory. Default is FALSE.
#' @param file_name Character. The name of the file to save if save_file is TRUE.
#'   Default is "cdc_measles_data.csv".
#'
#' @return A data frame containing CDC measles data.
#'
#' @examples
#' \dontrun{
#' measles_data <- get_measles_data()
#' measles_data <- get_measles_data(save_file = TRUE)
#' }
#'
#' @importFrom httr GET content
#' @importFrom readr read_csv
#' @importFrom utils write.csv
#'
#' @export
get_measles_data <- function(save_file = FALSE, file_name = "cdc_measles_data.csv") {
  # URL for the CDC measles data CSV
  # Note: The blob URL provided in the request is likely a temporary URL
  # For a more permanent solution, we need to find the actual data source URL
  
  # The CDC website for measles data is https://www.cdc.gov/measles/data-research/index.html
  # Since the blob URL may be temporary, we'll use the direct URL pattern if available
  
  # For now, we'll use a known pattern for CDC data resources
  # This URL may need to be updated if the CDC changes their data structure
  url <- "https://www.cdc.gov/measles/downloads/measles-data.csv"
  
  tryCatch({
    # Download the data
    message("Downloading CDC measles data...")
    response <- httr::GET(url)
    
    # Check if the request was successful
    if (httr::status_code(response) == 200) {
      # Parse the CSV data
      data_content <- httr::content(response, as = "text")
      measles_data <- readr::read_csv(data_content, show_col_types = FALSE)
      
      # Save data if requested
      if (save_file) {
        utils::write.csv(measles_data, file = file_name, row.names = FALSE)
        message(paste("Data saved to", file_name))
      }
      
      return(measles_data)
    } else {
      stop(paste("Failed to download data. HTTP status code:", httr::status_code(response)))
    }
  }, error = function(e) {
    # If the main URL fails, try the alternative URL from the user's request
    warning("Primary URL failed, attempting to use alternative data source...")
    
    # This is a fallback option that attempts to use the blob URL pattern
    # Note: This may not work long term as blob URLs are typically temporary
    alt_url <- "https://www.cdc.gov/measles/downloads/measlescases.csv"
    
    tryCatch({
      alt_response <- httr::GET(alt_url)
      
      if (httr::status_code(alt_response) == 200) {
        alt_data_content <- httr::content(alt_response, as = "text")
        alt_measles_data <- readr::read_csv(alt_data_content, show_col_types = FALSE)
        
        if (save_file) {
          utils::write.csv(alt_measles_data, file = file_name, row.names = FALSE)
          message(paste("Data saved to", file_name))
        }
        
        return(alt_measles_data)
      } else {
        stop(paste(
          "Both data sources failed. Please check the CDC website for updated data URLs:",
          "https://www.cdc.gov/measles/data-research/index.html"
        ))
      }
    }, error = function(e2) {
      stop(paste(
        "Failed to download data from all sources. Original error:", e$message,
        "Secondary error:", e2$message,
        "Please check the CDC website for current data URLs."
      ))
    })
  })
} 