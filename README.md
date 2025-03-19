# cdcmeasles

## Overview

`cdcmeasles` is an R package designed to download and analyze measles data from the Centers for Disease Control and Prevention (CDC). It provides easy access to public health data related to measles cases in the United States.

This package is inspired by the `cdcfluview` package, which provides similar functionality for influenza data. `cdcmeasles` simplifies the process of downloading, cleaning, and visualizing measles data for public health research and education.

## Installation

You can install the development version of `cdcmeasles` from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("yourusername/cdcmeasles")
```

## Usage

### Basic Usage

```r
library(cdcmeasles)

# Check if CDC data is available
is_data_available()

# Get metadata about the dataset
get_measles_metadata()

# Download the latest measles data
measles_data <- get_measles_data()

# Save the data to a CSV file
measles_data <- get_measles_data(save_file = TRUE, file_name = "my_measles_data.csv")
```

### Data Visualization

The package includes functions for visualizing measles data:

```r
library(cdcmeasles)

# Download the data
data <- get_measles_data()

# Create a time series plot of measles cases
plot_measles_time_series(data)

# Create a map of measles cases by state (if state-level data is available)
plot_measles_state_map(data)
```

## Data Source

The data is sourced directly from the CDC website:
https://www.cdc.gov/measles/data-research/index.html

## Dependencies

The package depends on:
- httr
- jsonlite
- utils
- dplyr
- readr

For visualization:
- ggplot2
- maps

## License

This package is released under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Note on Data Access

The CDC occasionally updates their data structure and URLs. If you encounter issues with data access, please check if the CDC has updated their measles data page structure.

## Disclaimer

This package is not officially affiliated with or endorsed by the CDC. The data is provided by the CDC and is made available through this package for ease of access and analysis. 