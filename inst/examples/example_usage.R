# Example usage of the cdcmeasles package

# Load the package (assuming it's installed)
library(cdcmeasles)

# Check if the CDC data sources are available
is_available <- is_data_available()
if (is_available) {
  # If data is available, get metadata
  metadata <- get_measles_metadata()
  print(metadata)
  
  # Download the measles data
  cat("\nDownloading measles data...\n")
  measles_data <- get_measles_data()
  
  # Print a summary of the data
  cat("\nSummary of measles data:\n")
  print(summary(measles_data))
  print(head(measles_data))
  
  # If applicable, create some visualizations
  # Note: These may need to be adjusted based on the actual structure of the data
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    
    cat("\nCreating visualizations...\n")
    
    # Assuming there are date and cases columns
    if (all(c("date", "cases") %in% names(measles_data))) {
      time_plot <- plot_measles_time_series(measles_data)
      print(time_plot)
    } else {
      cat("Required columns for time series plot not found.\n")
    }
    
    # Assuming there are state and cases columns for the map visualization
    if (all(c("state", "cases") %in% names(measles_data))) {
      if (requireNamespace("maps", quietly = TRUE)) {
        map_plot <- plot_measles_state_map(measles_data)
        print(map_plot)
      } else {
        cat("Package 'maps' is required for the state map visualization.\n")
      }
    } else {
      cat("Required columns for state map not found.\n")
    }
  } else {
    cat("Package 'ggplot2' is required for visualizations.\n")
  }
  
  # Save the data to a CSV file as an example
  output_file <- "measles_data_example.csv"
  cat("\nSaving data to", output_file, "...\n")
  measles_data <- get_measles_data(save_file = TRUE, file_name = output_file)
  cat("Data saved to", output_file, "\n")
  
} else {
  cat("CDC measles data is currently unavailable. Please try again later or check your internet connection.\n")
} 