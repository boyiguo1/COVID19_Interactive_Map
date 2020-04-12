library(tidyverse)
library(tigris)

# Map Data
us <- states(cb = TRUE, class="sf") %>% 
  filter(!(STUSPS %in% c("HI", "PR", "AK","AS","VI","GU","MP")))
us <- us[order(us$STATEFP),]
write_rds(us, "Data/us_map.rds")

fip_to_state <- us %>% data.frame() %>% 
  transmute(STATEFP, 
            State = NAME)
us_state <- counties(cb = TRUE, class="sf") %>% 
  geo_join(fip_to_state,
           by_sp = "STATEFP",
           by_df = "STATEFP",
           how = "left") %>% 
  split(.$State)
write_rds(us_state, "Data/state_map.rds")

# COVID Data
## Census Data
library(totalcensus)

### run line below if this is first time using totalcensus
set_path_to_census('C:/Users/boyiguo1/Downloads/census_data/')

## State Level Census Data 2018
### Remove "AS" "VI" "GU" "MP"
us_acs5 <- read_acs5year(
  year = 2018,
  states = setdiff(us %>% pull(STUSPS),
          c("AS", "VI", "GU", "MP")),
  table_contents = c(
    "white = B02001_002",
    "black = B02001_003",
    "asian = B02001_005"
  ),
  summary_level = "state"
) %>% 
  mutate(ID = NAME %>% tolower,
         state = NAME,
         pop = population) %>% 
  select(GEOID, ID, NAME, pop, white, black, asian)

write_rds(us_acs5, "Data/state_level_census.rds")

## County Level Census Data 2018
state_acs5 <- read_acs5year(
  year = 2018,
  states = setdiff(us %>% pull(STUSPS),
                   c("AS", "VI", "GU", "MP")),
  table_contents = c(
    "white = B02001_002",
    "black = B02001_003",
    "asian = B02001_005"
  ),
  summary_level = "050"
) %>% mutate(county=(unglue::unglue_data(NAME, "{County}, {State}"))%>% pull(County),
             state=(unglue::unglue_data(NAME, "{County}, {State}")) %>% pull(State)) %>% 
  rename(pop=population) %>% 
  select(GEOID, county, state, pop, white, black, asian)
write_rds(state_acs5, "Data/county_level_census.rds")


