# cdcmeasles 0.2.0

## New Features

* Added `get_cdc_urls()` function to view data endpoint URLs
* Added `get_current_year_summary()` for quick summary statistics
* Added `plot_measles_bars()` function for bar chart visualizations
* Added `plot_measles_dashboard()` function for combined visualizations
* Exported `clean_measles_data()` with `remove_na` parameter

## Improvements

* **Fixed dependencies**: Added ggplot2 and rlang to Imports; removed unused dplyr and readr
* **Updated visualizations**: Replaced deprecated `aes_string()` with `.data` pronoun pattern
* **Enhanced `plot_measles_time_series()`**: Added subtitle, line_color, show_points, and point_size parameters
* **Enhanced `plot_measles_state_map()`**: Added customizable colors (low_color, high_color, na_color, border_color)
* **Improved data processing**: Better date and type conversions with sorted output
* **Centralized URLs**: CDC data URLs now managed in single location for easier maintenance
* **Better error handling**: More informative error messages and validation
* **Added timeout parameter** to `get_measles_data()` for network requests

## Documentation

* Comprehensive roxygen2 documentation for all functions
* Added package-level documentation (`?cdcmeasles`)
* Created "Getting Started" vignette
* Improved README with usage examples and function reference
* Added NEWS.md for version tracking

## Testing

* Added testthat test suite for utility functions
* Added testthat test suite for visualization functions
* Network-dependent tests can be enabled via environment variable

## Bug Fixes

* Fixed example script that used non-existent function parameters
* Fixed `is_data_available()` to return named logical vector instead of single logical

---

# cdcmeasles 0.1.0

* Initial release
* Basic data retrieval from CDC endpoints
* Time series and map visualization functions
