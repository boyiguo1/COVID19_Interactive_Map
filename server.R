#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
# library(sf)
# library(maps)
library(plotly)

# Load Map Data
map_us <- read_rds("Data/us_map.rds")
map_state <- read_rds("Data/state_map.rds")
covid_us <- read_rds("Data/us_covid.rds")
covid_state <- read_rds("Data/state_covid.rds")
smry_us <- read_rds("Data/us_covid_summary.rds")
smry_state <- read_rds("Data/state_covid_summary.rds")


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    state_level <- reactiveVal(FALSE)
    current_state <- reactiveVal(NULL)
    #clicked_region <-reactiveVal(NULL)
   
    geo_dat <- reactive({
        if(is.null(current_state())){
            map_us %>%
                left_join(covid_us %>% filter(date==as.Date("2020-04-10")),
                          by = ("NAME")) %>% 
                filter(!(STUSPS %in% c("HI", "PR", "AK","AS","VI","GU","MP")))
            
        }
        else{
            map_state[[current_state()]] %>% 
                left_join(covid_state %>% 
                              filter(date==as.Date("2020-04-10"), 
                                     state.x==current_state()) %>% 
                              rename(NAME = county.x),
                          by=("NAME")
                          )
        }

    })
     
        
    output$distPlot <- renderPlotly(
        plot_ly(geo_dat(), split=~NAME, color = ~cases,
                hoveron = "fills",
                hoverinfo = "text",
                text = ~paste(NAME, "\n", 
                              "Population: ",pop, "\n",
                              "Cases, total: ",cases, "\n",
                              "Deaths, total: ",deaths, "\n",
                              "Cases, rate: ", cases_rate,"\n",
                              "Deaths, rate: ", deaths_rate,"\n"
                              ),
                showlegend = FALSE)
    )
    
    # Event Handler for Back to National Map Button
    observeEvent(input$toNational, {
        state_level(FALSE)
        current_state(NULL)
        # clicked_region(NULL)
    })
    
    # Event Handler for Clicks on Map
    observeEvent(event_data("plotly_click"),{
        d <- event_data("plotly_click")
        if(!is.null(d)) {
            if(state_level()){
                if(!is.null(current_state()))
                tmp_stat_dat <- map_state[[current_state()]]
                tmp_stat_dat$ID[d$curveNumber+1]
            }
            else{ # National Level
                message(d)
                message("Look HERE!!!!!",d$curveNumber)
                message(map_us$NAME[d$curveNumber+1])
                current_state(map_us$NAME[d$curveNumber+1])
                state_level(TRUE)
                current_state()

            }
        }
    })
    
})
