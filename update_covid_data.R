library(tidyverse)

# Create COVID Data
# COVID-19 Data
nyt <- "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv"


us_acs5 <- read_RDS("Data/state_level_census.rds")
state_acs5 <- read_RDS("Data/county_level_census.rds")


us_covid <- read_csv(nyt) %>% 
  mutate(ID = state %>% tolower) %>% 
  group_by(ID, date) %>% 
  summarize(deaths = sum(deaths), cases = sum(cases),
  ) %>% ungroup %>% 
  left_join(us_acs5, by="ID") %>%
  mutate(cases_rate = cases / pop * 10000,
         deaths_rate = deaths / pop * 10000)

us_covid_sum <- us_covid %>% 
  group_by(ID) %>% 
  summarise(
    sum_cases = max(cases), 
    sum_deaths = max(deaths),
    sum_cases_rate = plyr::round_any(max(cases_rate),0.01),
    sum_deaths_rate = plyr::round_any(max(deaths_rate),0.01),
    pop = max(pop)
  )

saveRDS(us_covid, "Data/us_covid.rds")
saveRDS(us_covid_sum, "Data/us_covid_summary.rds")


state_covid <- read_csv(nyt) %>% 
  mutate(ID = county %>% tolower,
         state_l = state %>% tolower,
         GEOID = paste0("05000US", fips)) %>% 
  filter(!is.na(fips)) %>% 
  left_join(state_acs5, by = "GEOID") %>%
  mutate(cases_rate = cases / pop * 10000,
         deaths_rate = deaths / pop * 10000)


state_covid_sum <- state_covid %>% 
  group_by(ID, state_l) %>% 
  summarise(
    sum_cases = max(cases), 
    sum_deaths = max(deaths),
    sum_cases_rate = plyr::round_any(max(cases_rate),0.01),
    sum_deaths_rate = plyr::round_any(max(deaths_rate),0.01),
    pop = max(pop)
    )

saveRDS(state_covid, "Data/state_covid.rds")
saveRDS(state_covid_sum, "Data/state_covid_summary.rds")