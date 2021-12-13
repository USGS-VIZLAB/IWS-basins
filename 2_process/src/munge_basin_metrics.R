# Basic function to read in data from a specific excel sheet
# from specific rows and columns
parse_sheet_data <- function(metrics_file, sheet, range) {
  readxl::read_excel(metrics_file, sheet=sheet, range=range, .name_repair = custom_name_repair)
}

# Function to replace spaces and special characters in column names
custom_name_repair <- function(names) {
  names <- tolower(gsub(" ", "_", names))
  names <- tolower(gsub("\\(", "", names))
  names <- tolower(gsub("\\)", "", names))
  names <- tolower(gsub("\\%", "perc", names))
  names <- tolower(gsub("\\/", "_per_", names))
  return(names)
}

# Parse the sheet that contains the basin id -> huc04 mapping
parse_basin_mapping <- function(metrics_files, sheet, range) {
  raw_data <- parse_sheet_data(metrics_files, sheet, range) %>%
    group_by(basin_id) %>%
    fill(candidate_basin_name) %>%
    fill(candidate_basin_area_km2)
}
add_basin_info <- function(p2_basin_chars, ...){

  vars <- c(...)

  p2_basin_chars %>%
    mutate(across(contains("area_km2"), ~round(.x, 2))) %>%
    select(basin_id,
           basin_name = candidate_basin_name,
           basin_area_km2 = candidate_basin_area_km2,
           vars)
}

# Parse the raw data or percentile rank data
# no special munging happening at the moment,
# just calling the parse sheet data function
parse_basin_data <- function(metrics_file, sheet, range) {
  raw_data <- parse_sheet_data(metrics_file, sheet, range)
}

# Parse the term definition data
# add a column to get the cleaned column names used in the
# raw basin characteristics and basin ranks data
# in case we want to be able to pull units for given variables
parse_basin_defs <- function(metrics_files, sheet, range) {
  raw_data <- parse_sheet_data(metrics_files, sheet, range) %>%
    mutate(param_column = custom_name_repair(variable_name), .before=2)
}

# For a given parameter, pull both the raw and percentile values
# for each basin (limited to variables that are in both dataframes)
get_raw_and_percentile_values <- function(basin_info, basin_chars, basin_ranks, variable, units, out_file, ...) {
  # get names of variables in ranked dataset, since
  # not all basin characteristics have ranked percentile values
  valid_var_names <- colnames(basin_ranks)[6:15]

  # if the variable has a ranked percentile value
  if (variable %in% valid_var_names) {
    basin_chars_subset <- basin_chars %>%
      select(basin_id, variable)

    basin_ranks_subest <- basin_ranks %>%
      select(basin_id, variable)

    data <- basin_info %>%
      left_join(basin_chars %>% select(basin_id, ...)) %>%
      mutate(across(c(...), ~round(.x, 3))) %>%
      left_join(basin_chars_subset, by="basin_id", suffix=c(paste0("_", units), "_percentile")) %>%
      left_join(basin_ranks_subest, by='basin_id', suffix=c(paste0("_", units), "_percentile"))

    if(!dir.exists(dirname(out_file))) dir.create(dirname(out_file), recursive=TRUE)
    readr::write_csv(data, file=out_file)
    return(out_file)
  } else {
    # otherwise, throw an error
    stop('that variable does not have both raw and percentile values')
  }
}
