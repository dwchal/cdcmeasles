# cdcmeasles

An R package to access CDC measles case data.

## Installation

You can install the development version of cdcmeasles from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("dwchal/cdcmeasles")
```

## Usage

The package provides access to two CDC measles datasets:
1. Weekly cases (recent years)
2. Yearly cases (historical data back to the 1980s)

```r
library(cdcmeasles)

# Check if data is available
is_data_available(verbose = TRUE)

# Get weekly data
weekly_data <- get_measles_data("weekly")

# Get yearly data
yearly_data <- get_measles_data("yearly")
```

## Data Sources

The package accesses two official CDC data sources:
- Weekly data: https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json
- Yearly data: https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json

## Data Format

### Weekly Data
- week_start: Start date of the week
- week_end: End date of the week
- cases: Number of reported cases

### Yearly Data
- year: Year of the data
- cases: Number of reported cases
- states_with_cases: Number of states reporting cases
- outbreaks: Information about outbreaks during the year

## License

MIT

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

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Note on Data Access

The CDC occasionally updates their data structure and URLs. If you encounter issues with data access, please check if the CDC has updated their measles data page structure.

## Disclaimer

This package is not officially affiliated with or endorsed by the CDC. The data is provided by the CDC and is made available through this package for ease of access and analysis. 