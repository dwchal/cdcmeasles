library(jsonlite)
library(tidyverse)
library(patchwork)

# --- Weekly Data ---
weekly_url <- "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesWeekly.json"
weekly_data <- fromJSON(weekly_url)

df_weekly <- as_tibble(weekly_data) %>%
  mutate(
    week_start = as.Date(week_start, format = "%Y-%m-%d"),
    week_end   = as.Date(week_end, format = "%Y-%m-%d"),
    cases      = as.numeric(cases)
  )

# Set Trump's second presidency inauguration date (2025-01-20)
trump_inaug <- as.Date("2025-01-20")
max_cases <- max(df_weekly$cases)

p_weekly <- ggplot(df_weekly, aes(x = week_start, y = cases)) +
  geom_col(fill = "dodgerblue", width = 6) +
  geom_vline(xintercept = trump_inaug, linetype = "dashed", color = "red", size = 1) +
  annotate("text", x = trump_inaug, y = max_cases/2,
           label = "Trump", angle = 90, vjust = -0.5, color = "red") +
  scale_x_date(
    date_breaks = "1 month",
    date_labels = "%b %Y",
    limits = c(min(df_weekly$week_start), as.Date("2025-04-01"))
  ) +
  labs(
    title = "Weekly Measles Cases",
    subtitle = "Data from CDC MeaslesCasesWeekly.json",
    x = "Week Start Date",
    y = "Number of Cases"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(color = "gray85")
  )

# --- Yearly Data ---
yearly_url <- "https://www.cdc.gov/wcms/vizdata/measles/MeaslesCasesYear.json"
yearly_data <- fromJSON(yearly_url)

df_yearly <- as_tibble(yearly_data) %>%
  mutate(
    year = as.integer(year),
    cases = as.numeric(cases)
  ) %>%
  filter(filter == "1985-Present*")

p_yearly <- ggplot(df_yearly, aes(x = factor(year), y = cases)) +
  geom_col(fill = "forestgreen") +
  labs(
    title = "Yearly Measles Cases",
    subtitle = "Data from CDC MeaslesCasesYear.json",
    x = "Year",
    y = "Number of Cases"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 16),
    plot.subtitle = element_text(size = 12),
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.major = element_line(color = "gray85")
  )

# --- Combine the Plots ---
combined_plot <- p_weekly / p_yearly
print(combined_plot)
