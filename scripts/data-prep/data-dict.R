#--------------------------------Data Dictionary-------------------------------#
#-Author: Francisca Castro ------------------------- Created: January 30, 2024-#
#-R Version: 4.3.1 --------------------------------- Revised: January 30, 2024-#

## Load the required packages
pacman::p_load(
  tidyverse,
  arrow,
  haven,
  furrr,
  install = FALSE
)


#------------------------------------------------------------------------------#
#-----------------------Building a Searchable Codebook--------------------------
#------------------------------------------------------------------------------#

#----------------------------------- LAPOP ------------------------------------#

data_dir <- str_c(here::here(), "/data/lapop/merged")

# Import the list of all survey data files in data_dir
lapop_data_files <- tibble(
  # Full file paths for reading
  full_path = list.files(
    path = data_dir,
    pattern = "*.dta",
    full.names = TRUE
  ),
  # File names only for display
  file = basename(list.files(
    path = data_dir,
    pattern = "*.dta",
    full.names = TRUE
  )),
  # Year of each survey
  year = str_remove_all(file, pattern = "[^0-9]")
)

# Load each survey data file
lapop_data <- map(.x = lapop_data_files$full_path, ~ read_dta(.x, encoding = "UTF-8"))

# Build a tibble from the value and variable labels
lapop_data_dicts <- lapop_data_files %>%
  select(file, year) %>%  # Select only the columns you want to keep
  mutate(dictionary = map(
    .x = lapop_data,
    .f =  ~ svy_dict(.x)
  )) %>% 
  # Unnest the dictionary
  unnest(cols = dictionary)

#------------------------------------ WVS ------------------------------------#

