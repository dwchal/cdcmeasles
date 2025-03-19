#' Plot Measles Cases Over Time
#'
#' This function creates a time series plot of measles cases.
#'
#' @param data A data frame containing measles data, typically from get_measles_data().
#' @param date_col Character. Name of the column containing dates. Default is "date".
#' @param cases_col Character. Name of the column containing case counts. Default is "cases".
#' @param title Character. Plot title. Default is "Measles Cases Over Time".
#'
#' @return A ggplot object with the time series plot.
#'
#' @examples
#' \dontrun{
#' data <- get_measles_data()
#' plot_measles_time_series(data)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_line theme_minimal labs
#'
#' @export
plot_measles_time_series <- function(data, 
                                     date_col = "date", 
                                     cases_col = "cases",
                                     title = "Measles Cases Over Time") {
  
  # Check if required packages are installed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is needed for this function to work. Please install it.")
  }
  
  # Check if required columns exist
  if (!date_col %in% names(data)) {
    stop(paste0("Column '", date_col, "' not found in data."))
  }
  
  if (!cases_col %in% names(data)) {
    stop(paste0("Column '", cases_col, "' not found in data."))
  }
  
  # Create the plot
  p <- ggplot2::ggplot(data, ggplot2::aes_string(x = date_col, y = cases_col)) +
    ggplot2::geom_line(color = "darkred") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = title,
      x = "Date",
      y = "Number of Cases",
      caption = "Source: CDC"
    )
  
  return(p)
}

#' Create a Map of US Measles Cases by State
#'
#' This function creates a choropleth map of measles cases by US state.
#'
#' @param data A data frame containing measles data by state.
#' @param state_col Character. Name of the column containing state names/codes. Default is "state".
#' @param cases_col Character. Name of the column containing case counts. Default is "cases".
#' @param title Character. Plot title. Default is "Measles Cases by State".
#'
#' @return A ggplot object with the choropleth map.
#'
#' @examples
#' \dontrun{
#' data <- get_measles_data()
#' # Assuming data has state-level information
#' plot_measles_state_map(data)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_map theme_void scale_fill_viridis_c labs
#'
#' @export
plot_measles_state_map <- function(data,
                                   state_col = "state",
                                   cases_col = "cases",
                                   title = "Measles Cases by State") {
  
  # Check if required packages are installed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is needed for this function to work. Please install it.")
  }
  
  if (!requireNamespace("maps", quietly = TRUE)) {
    stop("Package 'maps' is needed for this function to work. Please install it.")
  }
  
  # Check if required columns exist
  if (!state_col %in% names(data)) {
    stop(paste0("Column '", state_col, "' not found in data."))
  }
  
  if (!cases_col %in% names(data)) {
    stop(paste0("Column '", cases_col, "' not found in data."))
  }
  
  # Get US states map data
  us_states <- maps::map_data("state")
  
  # Ensure state names are lowercase for matching
  data[[state_col]] <- tolower(data[[state_col]])
  
  # Create the map
  p <- ggplot2::ggplot() +
    ggplot2::geom_map(
      data = us_states, map = us_states,
      ggplot2::aes(map_id = region),
      fill = "white", color = "grey70", size = 0.2
    ) +
    ggplot2::geom_map(
      data = data, map = us_states,
      ggplot2::aes_string(map_id = state_col, fill = cases_col),
      color = "grey70", size = 0.2
    ) +
    ggplot2::scale_fill_viridis_c(option = "inferno", name = "Cases") +
    ggplot2::theme_void() +
    ggplot2::labs(
      title = title,
      caption = "Source: CDC"
    )
  
  return(p)
} 