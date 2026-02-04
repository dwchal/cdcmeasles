#' Plot Measles Cases Over Time
#'
#' Creates a time series plot of measles cases using ggplot2.
#'
#' @param data A data frame containing measles data, typically from
#'   [get_measles_data()].
#' @param date_col Character. Name of the column containing dates.
#'   Default is `"week_start"` for weekly data. Use `"year"` for yearly data.
#' @param cases_col Character. Name of the column containing case counts.
#'   Default is `"cases"`.
#' @param title Character. Plot title. Default is `"Measles Cases Over Time"`.
#' @param subtitle Character. Optional subtitle. Default is `NULL`.
#' @param line_color Character. Color for the line. Default is `"darkred"`.
#' @param show_points Logical. If `TRUE`, adds points to the line plot.
#'   Default is `FALSE`.
#' @param point_size Numeric. Size of points if `show_points = TRUE`.
#'   Default is 2.
#'
#' @return A ggplot object with the time series plot.
#'
#' @examples
#' \dontrun{
#' # Weekly data
#' weekly <- get_measles_data("weekly")
#' plot_measles_time_series(weekly)
#'
#' # Yearly data with customization
#' yearly <- get_measles_data("yearly")
#' plot_measles_time_series(
#'   yearly,
#'   date_col = "year",
#'   title = "Historical Measles Cases",
#'   show_points = TRUE
#' )
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_point theme_minimal labs
#' @importFrom rlang .data sym
#'
#' @export
plot_measles_time_series <- function(data,
                                     date_col = "week_start",
                                     cases_col = "cases",
                                     title = "Measles Cases Over Time",
                                     subtitle = NULL,
                                     line_color = "darkred",
                                     show_points = FALSE,
                                     point_size = 2) {

  # Check if required packages are installed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for this function. Please install it.",
         call. = FALSE)
  }

  # Validate input
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame", call. = FALSE)
  }

  if (nrow(data) == 0) {
    stop("'data' contains no rows", call. = FALSE)
  }

  # Check if required columns exist
  if (!date_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data. Available columns: %s",
                 date_col, paste(names(data), collapse = ", ")),
         call. = FALSE)
  }

  if (!cases_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data. Available columns: %s",
                 cases_col, paste(names(data), collapse = ", ")),
         call. = FALSE)
  }

  # Determine x-axis label based on column
  x_label <- if (date_col == "year") "Year" else "Date"

  # Create the plot using .data pronoun (modern approach)
  p <- ggplot2::ggplot(data, ggplot2::aes(
    x = .data[[date_col]],
    y = .data[[cases_col]]
  )) +
    ggplot2::geom_line(color = line_color, linewidth = 0.8) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = x_label,
      y = "Number of Cases",
      caption = "Source: CDC"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank()
    )

  # Add points if requested
  if (show_points) {
    p <- p + ggplot2::geom_point(color = line_color, size = point_size)
  }

  return(p)
}

#' Plot Measles Cases as Bar Chart
#'
#' Creates a bar chart of measles cases, useful for yearly data or
#' comparing discrete time periods.
#'
#' @param data A data frame containing measles data.
#' @param x_col Character. Name of the column for x-axis (e.g., `"year"`).
#'   Default is `"year"`.
#' @param cases_col Character. Name of the column containing case counts.
#'   Default is `"cases"`.
#' @param title Character. Plot title. Default is `"Measles Cases by Year"`.
#' @param subtitle Character. Optional subtitle. Default is `NULL`.
#' @param fill_color Character. Fill color for bars. Default is `"steelblue"`.
#' @param highlight_recent Logical. If `TRUE`, highlights the most recent
#'   year/period in a different color. Default is `FALSE`.
#' @param highlight_color Character. Color for highlighted bar.
#'   Default is `"darkred"`.
#'
#' @return A ggplot object with the bar chart.
#'
#' @examples
#' \dontrun{
#' yearly <- get_measles_data("yearly")
#' plot_measles_bars(yearly, highlight_recent = TRUE)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_col theme_minimal labs scale_fill_manual
#' @importFrom rlang .data
#'
#' @export
plot_measles_bars <- function(data,
                               x_col = "year",
                               cases_col = "cases",
                               title = "Measles Cases by Year",
                               subtitle = NULL,
                               fill_color = "steelblue",
                               highlight_recent = FALSE,
                               highlight_color = "darkred") {

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for this function. Please install it.",
         call. = FALSE)
  }

  if (!is.data.frame(data)) {
    stop("'data' must be a data frame", call. = FALSE)
  }

  if (!x_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data.", x_col), call. = FALSE)
  }

  if (!cases_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data.", cases_col), call. = FALSE)
  }

  # Sort data by x column
  data <- data[order(data[[x_col]]), ]

  if (highlight_recent) {
    # Create a highlight indicator for the most recent entry
    data$`.highlight` <- FALSE
    data$`.highlight`[nrow(data)] <- TRUE

    p <- ggplot2::ggplot(data, ggplot2::aes(
      x = .data[[x_col]],
      y = .data[[cases_col]],
      fill = .data[[".highlight"]]
    )) +
      ggplot2::geom_col() +
      ggplot2::scale_fill_manual(
        values = c("FALSE" = fill_color, "TRUE" = highlight_color),
        guide = "none"
      )
  } else {
    p <- ggplot2::ggplot(data, ggplot2::aes(
      x = .data[[x_col]],
      y = .data[[cases_col]]
    )) +
      ggplot2::geom_col(fill = fill_color)
  }

  p <- p +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = if (x_col == "year") "Year" else x_col,
      y = "Number of Cases",
      caption = "Source: CDC"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold"),
      panel.grid.minor = ggplot2::element_blank()
    )

  return(p)
}

#' Create a Map of US Measles Cases by State
#'
#' Creates a choropleth map showing measles cases by US state.
#' Requires the `maps` package to be installed.
#'
#' @param data A data frame containing measles data by state.
#' @param state_col Character. Name of the column containing state names.
#'   Names should match standard US state names (e.g., "california", "new york").
#'   Default is `"state"`.
#' @param cases_col Character. Name of the column containing case counts.
#'   Default is `"cases"`.
#' @param title Character. Plot title. Default is `"Measles Cases by State"`.
#' @param subtitle Character. Optional subtitle. Default is `NULL`.
#' @param low_color Character. Color for low values. Default is `"white"`.
#' @param high_color Character. Color for high values. Default is `"darkred"`.
#' @param na_color Character. Color for states with no data. Default is `"grey90"`.
#' @param border_color Character. Color for state borders. Default is `"grey50"`.
#'
#' @return A ggplot object with the choropleth map.
#'
#' @examples
#' \dontrun{
#' # Create example state data
#' state_data <- data.frame(
#'   state = c("california", "texas", "new york", "florida"),
#'   cases = c(50, 30, 45, 20)
#' )
#' plot_measles_state_map(state_data)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_polygon theme_void labs
#'   scale_fill_gradient coord_fixed
#' @importFrom rlang .data
#'
#' @export
plot_measles_state_map <- function(data,
                                   state_col = "state",
                                   cases_col = "cases",
                                   title = "Measles Cases by State",
                                   subtitle = NULL,
                                   low_color = "white",
                                   high_color = "darkred",
                                   na_color = "grey90",
                                   border_color = "grey50") {

  # Check required packages
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for this function. Please install it.",
         call. = FALSE)
  }

  if (!requireNamespace("maps", quietly = TRUE)) {
    stop("Package 'maps' is required for this function. Please install it.",
         call. = FALSE)
  }

  # Validate input
  if (!is.data.frame(data)) {
    stop("'data' must be a data frame", call. = FALSE)
  }

  if (!state_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data.", state_col), call. = FALSE)
  }

  if (!cases_col %in% names(data)) {
    stop(sprintf("Column '%s' not found in data.", cases_col), call. = FALSE)
  }

  # Get US states map data
  us_states <- ggplot2::map_data("state")

  # Prepare data - ensure state names are lowercase for matching
  plot_data <- data.frame(
    region = tolower(as.character(data[[state_col]])),
    cases = as.numeric(data[[cases_col]]),
    stringsAsFactors = FALSE
  )

  # Merge map data with case data
  map_data <- merge(us_states, plot_data, by = "region", all.x = TRUE)

  # Sort to maintain polygon order
  map_data <- map_data[order(map_data$order), ]

  # Create the map
  p <- ggplot2::ggplot(map_data, ggplot2::aes(
    x = .data$long,
    y = .data$lat,
    group = .data$group,
    fill = .data$cases
  )) +
    ggplot2::geom_polygon(color = border_color, linewidth = 0.2) +
    ggplot2::scale_fill_gradient(
      low = low_color,
      high = high_color,
      na.value = na_color,
      name = "Cases"
    ) +
    ggplot2::coord_fixed(1.3) +
    ggplot2::theme_void(base_size = 12) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      caption = "Source: CDC"
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(hjust = 0.5),
      legend.position = "right"
    )

  return(p)
}

#' Create a Summary Dashboard Plot
#'
#' Creates a combined visualization with multiple panels showing
#' different aspects of the measles data.
#'
#' @param weekly_data Data frame with weekly measles data.
#' @param yearly_data Data frame with yearly measles data. Optional.
#'
#' @return A combined ggplot object (requires patchwork for combining,
#'   otherwise returns the time series plot only).
#'
#' @examples
#' \dontrun{
#' weekly <- get_measles_data("weekly")
#' yearly <- get_measles_data("yearly")
#' plot_measles_dashboard(weekly, yearly)
#' }
#'
#' @export
plot_measles_dashboard <- function(weekly_data, yearly_data = NULL) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Package 'ggplot2' is required for this function.", call. = FALSE)
  }

  # Create time series plot from weekly data
  p1 <- plot_measles_time_series(
    weekly_data,
    title = "Weekly Measles Cases",
    show_points = TRUE
  )

  # If no yearly data or patchwork not available, return just the weekly plot
  if (is.null(yearly_data)) {
    return(p1)
  }

  if (!requireNamespace("patchwork", quietly = TRUE)) {
    message("Install 'patchwork' package to see combined dashboard. ",
            "Returning weekly time series only.")
    return(p1)
  }

  # Create bar chart from yearly data (last 10 years)
  recent_years <- utils::tail(yearly_data[order(yearly_data$year), ], 10)
  p2 <- plot_measles_bars(
    recent_years,
    title = "Cases by Year (Last 10 Years)",
    highlight_recent = TRUE
  )

  # Combine plots using patchwork
  combined <- patchwork::wrap_plots(p1, p2, ncol = 1)

  return(combined)
}
