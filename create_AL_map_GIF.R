library(tidyverse)
library(ggplot2)
library(gganimate)


covid <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")
al_covid <- covid %>% filter(state == "Alabama") %>% 
  transmute(date, cases, 
            subregion = county %>% tolower) %>% 
  #filter(date %in% c("2020-03-01", "2020-04-03")) %>% 
  mutate(date = as.Date(date))

al_map <- map_data("county", region="Alabama") %>% 
  expand_grid(date=as.Date(unique(al_covid$date)))

county_name <- map_data("county", region="Alabama") %>%
  group_by(subregion) %>% 
  summarize(long = mean(long), lat =mean(lat))

dat <- full_join(al_map, al_covid, by=c("subregion", "date")) %>% 
  filter(!is.na(long)) %>% 
  mutate(cases = ifelse(is.na(cases), 0, cases)) %>% 
  mutate(time = as.numeric(date))

  
p <- ggplot(dat,
       aes(x = long, y = lat)) +
  geom_polygon(aes(group=group, fill=cases), color = "black") +
  geom_text(data = county_name, aes(label = subregion))+
  theme_void() +
  scale_fill_gradient(low = "white", high="red") +
  #theme(legend.position = "none") +
  transition_states(date, 1, 1) +
  labs(title = "{next_state}")


animate(p, width = 600, height = 800, renderer = gifski_renderer())
anim_save("covid_AL.gif")

