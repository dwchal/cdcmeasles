# =============================================================================
# Example Usage of the cdcmeasles Package
# =============================================================================
# This script demonstrates how to use the cdcmeasles package to access,
# analyze, and visualize CDC measles case data.

# Load the package
library(cdcmeasles)

# -----------------------------------------------------------------------------
# 1. Check Data Availability
# -----------------------------------------------------------------------------
# Before downloading data, check if the CDC endpoints are accessible

cat("Checking CDC data availability...\n")
availability <- is_data_available(verbose = TRUE)
print(availability)

# If no data is available, exit early
if (!any(availability)) {
  stop("CDC measles data is currently unavailable. Please try again later.")
}

# -----------------------------------------------------------------------------
# 2. Get Package Metadata
# -----------------------------------------------------------------------------
# Retrieve information about the data sources

cat("\n--- Package Metadata ---\n")
metadata <- get_measles_metadata()
print(metadata)

# View the data URLs
cat("\nData URLs:\n")
print(get_cdc_urls())

# -----------------------------------------------------------------------------
# 3. Download Weekly Data
# -----------------------------------------------------------------------------
# Weekly data contains recent case counts by week

cat("\n--- Downloading Weekly Data ---\n")
weekly_data <- get_measles_data("weekly", verbose = TRUE)

if (!is.null(weekly_data)) {
  cat("\nWeekly data summary:\n")
  print(summary(weekly_data))
  cat("\nFirst few rows:\n")
  print(head(weekly_data))
  cat("\nData dimensions:", nrow(weekly_data), "rows x", ncol(weekly_data), "columns\n")
}

# -----------------------------------------------------------------------------
# 4. Download Yearly Data
# -----------------------------------------------------------------------------
# Yearly data contains historical case counts with outbreak information

cat("\n--- Downloading Yearly Data ---\n")
yearly_data <- get_measles_data("yearly", verbose = TRUE)

if (!is.null(yearly_data)) {
  cat("\nYearly data summary:\n")
  print(summary(yearly_data))
  cat("\nFirst few rows:\n")
  print(head(yearly_data))
}

# -----------------------------------------------------------------------------
# 5. Get Current Year Summary
# -----------------------------------------------------------------------------
# Quick summary of the most recent data

cat("\n--- Current Year Summary ---\n")
current_summary <- get_current_year_summary(verbose = TRUE)
if (!is.null(current_summary)) {
  cat("Year:", current_summary$year, "\n")
  cat("Total cases:", current_summary$total_cases, "\n")
  cat("Data type:", current_summary$data_type, "\n")
}

# -----------------------------------------------------------------------------
# 6. Create Visualizations
# -----------------------------------------------------------------------------
# The package provides several visualization functions

if (requireNamespace("ggplot2", quietly = TRUE)) {
  cat("\n--- Creating Visualizations ---\n")

  # Time series plot of weekly data
  if (!is.null(weekly_data) && nrow(weekly_data) > 0) {
    cat("Creating weekly time series plot...\n")
    p1 <- plot_measles_time_series(
      weekly_data,
      title = "Weekly Measles Cases",
      subtitle = "Recent CDC data",
      show_points = TRUE
    )
    print(p1)
  }

  # Time series plot of yearly data
  if (!is.null(yearly_data) && nrow(yearly_data) > 0) {
    cat("Creating yearly time series plot...\n")
    p2 <- plot_measles_time_series(
      yearly_data,
      date_col = "year",
      title = "Historical Measles Cases",
      subtitle = "Annual CDC data"
    )
    print(p2)

    # Bar chart of yearly data
    cat("Creating bar chart...\n")
    p3 <- plot_measles_bars(
      yearly_data,
      title = "Measles Cases by Year",
      highlight_recent = TRUE
    )
    print(p3)
  }

  # State map (requires maps package and state-level data)
  if (requireNamespace("maps", quietly = TRUE)) {
    # Create example state data for demonstration
    # (The CDC weekly/yearly data doesn't include state breakdown)
    cat("Creating example state map...\n")
    example_state_data <- data.frame(
      state = c("california", "texas", "new york", "florida", "ohio",
                "washington", "arizona", "michigan", "illinois", "georgia"),
      cases = c(45, 32, 28, 22, 18, 15, 12, 10, 8, 5)
    )
    p4 <- plot_measles_state_map(
      example_state_data,
      title = "Example: Measles Cases by State",
      subtitle = "(Demonstration with synthetic data)"
    )
    print(p4)
  }

} else {
  cat("\nNote: Install 'ggplot2' package for visualization capabilities.\n")
}

# -----------------------------------------------------------------------------
# 7. Save Data to CSV (Optional)
# -----------------------------------------------------------------------------
# You can save the downloaded data for offline analysis

if (!is.null(weekly_data)) {
  output_file <- "measles_weekly_data.csv"
  cat("\nSaving weekly data to", output_file, "...\n")
  write.csv(weekly_data, output_file, row.names = FALSE)
  cat("Data saved successfully.\n")
}

if (!is.null(yearly_data)) {
  output_file <- "measles_yearly_data.csv"
  cat("Saving yearly data to", output_file, "...\n")
  write.csv(yearly_data, output_file, row.names = FALSE)
  cat("Data saved successfully.\n")
}

# -----------------------------------------------------------------------------
# 8. Clean Data (Optional)
# -----------------------------------------------------------------------------
# Apply additional cleaning if needed

if (!is.null(weekly_data)) {
  cat("\n--- Cleaning Data ---\n")
  clean_data <- clean_measles_data(weekly_data, remove_na = TRUE)
  cat("Cleaned data has", nrow(clean_data), "rows\n")
}

cat("\n=== Example complete ===\n")
