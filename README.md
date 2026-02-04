# cdcmeasles

<!-- badges: start -->
[![R-CMD-check](https://github.com/dwchal/cdcmeasles/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dwchal/cdcmeasles/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

An R package to access and visualize CDC measles case data.

## Overview

The `cdcmeasles` package provides tools to:

- Download measles case data directly from official CDC JSON endpoints
- Access both weekly (recent) and yearly (historical) case counts
- Create time series plots, bar charts, and choropleth maps
- Check data availability and retrieve metadata

## Installation

Install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("dwchal/cdcmeasles")
```

## Quick Start

```r
library(cdcmeasles)

# Check if data is available
is_data_available(verbose = TRUE)

# Download weekly data (recent cases)
weekly <- get_measles_data("weekly")
head(weekly)

# Download yearly data (historical)
yearly <- get_measles_data("yearly")
head(yearly)

# Get a quick summary of current year
get_current_year_summary()
```

## Visualizations

The package includes several ggplot2-based visualization functions:

```r
# Time series plot
weekly <- get_measles_data("weekly")
plot_measles_time_series(weekly, show_points = TRUE)

# Yearly bar chart
yearly <- get_measles_data("yearly")
plot_measles_bars(yearly, highlight_recent = TRUE)

# Historical time series
plot_measles_time_series(
  yearly,
  date_col = "year",
  title = "Historical Measles Cases"
)
```

For state-level data, create choropleth maps (requires `maps` package):

```r
state_data <- data.frame(
  state = c("california", "texas", "new york"),
  cases = c(50, 30, 45)
)
plot_measles_state_map(state_data)
```

## Data Sources

The package accesses two official CDC data endpoints:

| Type | URL | Description |
|------|-----|-------------|
| Weekly | https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json | Recent weekly case counts |
| Yearly | https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json | Historical annual data |

## Data Format

### Weekly Data

| Column | Type | Description |
|--------|------|-------------|
| `week_start` | Date | Start of reporting week |
| `week_end` | Date | End of reporting week |
| `cases` | Integer | Number of reported cases |

### Yearly Data

| Column | Type | Description |
|--------|------|-------------|
| `year` | Integer | Year of data |
| `cases` | Integer | Total cases for year |
| `states_with_cases` | Integer | States reporting cases |
| `outbreaks` | Character | Outbreak descriptions |

## Functions

### Data Retrieval

- `get_measles_data()` - Download weekly or yearly data
- `is_data_available()` - Check CDC endpoint accessibility
- `get_measles_metadata()` - Get dataset metadata
- `get_cdc_urls()` - View data endpoint URLs
- `get_current_year_summary()` - Quick summary of recent data

### Data Processing

- `clean_measles_data()` - Standardize and clean data

### Visualization

- `plot_measles_time_series()` - Time series line plot
- `plot_measles_bars()` - Bar chart for yearly data
- `plot_measles_state_map()` - US choropleth map
- `plot_measles_dashboard()` - Combined dashboard view

## Dependencies

**Required:**
- httr
- jsonlite
- ggplot2
- rlang

**Optional:**
- maps (for `plot_measles_state_map()`)
- patchwork (for `plot_measles_dashboard()`)

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This package is not officially affiliated with or endorsed by the CDC. The data is provided by the CDC and made available through this package for ease of access and analysis.

## Note on Data Access

The CDC occasionally updates their data structure and URLs. If you encounter issues:

1. Check `is_data_available(verbose = TRUE)` for connectivity
2. Verify URLs with `get_cdc_urls()`
3. Visit the [CDC measles page](https://www.cdc.gov/measles/data-research/index.html) for updates
4. Report issues at https://github.com/dwchal/cdcmeasles/issues
