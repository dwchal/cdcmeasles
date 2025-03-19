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
  # The CDC website for measles data is https://www.cdc.gov/measles/data-research/index.html
  # Try multiple possible URL patterns for CDC measles data
  
  # List of potential URLs to try
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
  
  # Try each URL in sequence
  for (url in urls) {
    message(paste("Trying URL:", url))
    
    success <- tryCatch({
      # Download the data
      response <- httr::GET(url)
      
      # Check if the request was successful
      if (httr::status_code(response) == 200) {
        # Parse the CSV data
        data_content <- httr::content(response, as = "text", encoding = "UTF-8")
        
        # Check if the content is valid 
        if (grepl("^\\s*$", data_content)) {
          message("URL returned empty content, trying next URL.")
          next
        }
        
        tryCatch({
          measles_data <- readr::read_csv(data_content, show_col_types = FALSE)
          
          # Check if we got a valid data frame
          if (nrow(measles_data) == 0) {
            message("URL returned empty data frame, trying next URL.")
            next
          }
          
          # Save data if requested
          if (save_file) {
            utils::write.csv(measles_data, file = file_name, row.names = FALSE)
            message(paste("Data saved to", file_name))
          }
          
          message("Successfully downloaded CDC measles data.")
          return(measles_data)
        }, error = function(e) {
          message(paste("Error parsing CSV from", url, ":", e$message))
          return(FALSE)
        })
      } else {
        message(paste("URL returned status code:", httr::status_code(response)))
        return(FALSE)
      }
    }, error = function(e) {
      message(paste("Error accessing", url, ":", e$message))
      return(FALSE)
    })
    
    if (is.data.frame(success)) {
      return(success)
    }
  }
  
  # If we've tried all URLs and none worked
  # Try to use the blob URL if provided
  message("All standard URLs failed. Attempting to use direct blob URL...")
  blob_url <- "blob:https://www.cdc.gov/2d032dd5-e5c3-437d-9bb2-59bb5ea8cb2d"
  
  message("Note: Blob URLs are typically temporary and may not work directly.")
  message("Please visit https://www.cdc.gov/measles/data-research/index.html")
  message("and download the data manually if automatic download fails.")
  
  # If all attempts fail, provide a helpful error message
  stop(paste(
    "Failed to download CDC measles data from all known sources.",
    "Please check the CDC website at https://www.cdc.gov/measles/data-research/index.html",
    "for the latest data structure or download the data manually."
  ))
} 