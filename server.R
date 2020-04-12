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
library(tigris)

# Load Map Data
map_us <- read_rds("Data/us_map.rds")
map_state <- read_rds("Data/state_map.rds")
covid_us <- read_rds("Data/us_covid.rds")
covid_state <- read_rds("Data/state_covid.rds")
# smry_us <- read_rds("Data/us_covid_summary.rds")
# smry_state <- read_rds("Data/state_covid_summary.rds")


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    state_level <- reactiveVal(FALSE)
    current_state <- reactiveVal(NULL)
    #clicked_region <-reactiveVal(NULL)
    
    covid_dat <- reactive({
        if(is.null(current_state())){ # At National Map Page
            set_date <- min(input$date, max(covid_us$date))
            message("look_here+++++", set_date)
            covid_us %>% 
                filter(date==as.Date(set_date))
        }
        else{ # At State Map Page
            set_date <- min(input$date, max(covid_state$date))
            message("look_here+++++", set_date)
            covid_state %>% 
                filter(date==as.Date(set_date), 
                       state.x==current_state()) %>% 
                rename(NAME = county.x)
        }
    })
    
   
    geo_dat <- reactive({
        # message("Generate _data")
        # message( map_us%>% head)
        # message("state data")
        # message(map_state %>% head)
        if(is.null(current_state())){
            map_us %>%
                left_join(covid_dat(),
                    #covid_us %>% filter(date==as.Date("2020-04-10")),
                          by = ("NAME"))
            }
        else{
            map_state[[current_state()]] %>% 
                left_join(covid_dat(),
                    # covid_state %>% filter(date==as.Date("2020-04-10"),
                    #                     state.x==current_state()) %>% 
                    #     rename(NAME = county.x),
                          by=("NAME")
                          )
        }

    })
     
        
    output$distPlot <- renderPlotly({
        message("map_us class", map_us %>% class)
        message("map_state class", map_state %>% class)
        message("geo_data class", geo_dat() %>% class)
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
    })
    
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
                # message(d)
                # message("Look HERE!!!!!",d$curveNumber)
                # message(map_us$NAME[d$curveNumber+1])
                current_state(map_us$NAME[d$curveNumber+1])
                state_level(TRUE)
                current_state()

            }
        }
    })
    
})
