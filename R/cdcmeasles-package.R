#' @keywords internal
"_PACKAGE"

#' cdcmeasles: Access and Visualize CDC Measles Case Data
#'
#' The cdcmeasles package provides tools to access, analyze, and visualize
#' measles case data from the Centers for Disease Control and Prevention (CDC).
#'
#' @section Data Retrieval Functions:
#' \describe{
#'   \item{[get_measles_data()]}{Download weekly or yearly measles data}
#'   \item{[is_data_available()]}{Check if CDC data endpoints are accessible}
#'   \item{[get_measles_metadata()]}{Get metadata about the datasets}
#'   \item{[get_cdc_urls()]}{View the CDC data endpoint URLs}
#'   \item{[get_current_year_summary()]}{Quick summary of recent data}
#' }
#'
#' @section Data Processing Functions:
#' \describe{
#'   \item{[clean_measles_data()]}{Standardize and clean measles data}
#' }
#'
#' @section Visualization Functions:
#' \describe{
#'   \item{[plot_measles_time_series()]}{Create time series line plots}
#'   \item{[plot_measles_bars()]}{Create bar charts of yearly data}
#'   \item{[plot_measles_state_map()]}{Create US choropleth maps}
#'   \item{[plot_measles_dashboard()]}{Create combined dashboard views}
#' }
#'
#' @section Data Sources:
#' The package accesses official CDC data from:
#' \itemize{
#'   \item Weekly: \url{https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json}
#'   \item Yearly: \url{https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json}
#' }
#'
#' @docType package
#' @name cdcmeasles-package
NULL
