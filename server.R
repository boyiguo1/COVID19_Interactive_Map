#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyjs)
library(tidyverse)
library(sf)
library(maps)
library(plotly)
library(unglue)

us <- st_as_sf(maps::map("state",fill=TRUE, plot =FALSE)) %>% 
    mutate(ID_old = ID %>% as.character())

us_state <- st_as_sf(maps::map("county",fill=TRUE, plot =FALSE)) %>% 
    mutate(state = unglue_data(ID%>% as.character(), "{State},{County}") %>% pull(State),
           county = unglue_data(ID%>% as.character(), "{State},{County}") %>% pull(County),
           ID_old = ID %>% as.character(),
           ID = county) %>% 
    split(.$state)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # covid <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")
    # al_covid <- covid %>% filter(state == "Alabama") %>% 
    #     transmute(date, cases, 
    #               county = county %>% tolower)
    # 
    

    
    state_level <- reactiveVal(FALSE)
    current_state <- reactiveVal(NULL)
    clicked_region <-reactiveVal(NULL)
   
    geo_dat <- reactive({
        # message("Chaning Map Data;")
        # message(state_level())
        # message(is.null(current_state()))
        # js$resetClick()
        if(is.null(current_state())) us
        else
            us_state[[current_state()]]

    })
    # input$date
     
        
    output$distPlot <- renderPlotly(
        plot_ly(geo_dat(), split=~ID, color = I("gray90"),
                hoveron = "fills",
                hoverinfo = "text",
                #text = ~paste("num of cases: ", cases, "\n Number of Death", 
                #              cases-10),
                showlegend = FALSE)
    )
    
    observeEvent(input$toNational, {
        
        # message("State Level value is ", state_level())
        # message("if Current State is NULL", is.null(current_state()))
        # message("Back to National")
        # js$resetClick()
        # message("reset State Click")
        state_level(FALSE)
        current_state(NULL)
        clicked_region(NULL)
        # message(state_level())
        # message(is.null(current_state()))
    })
    
    observeEvent(event_data("plotly_click"),{
   # output$clickText <- renderPrint({
        # message('clicked')
        d <- event_data("plotly_click")
        if(!is.null(d)) {
            # message("Click State Trigered")
            # message("Currnet State is:", current_state())
            # message("if is on State Level ", state_level())
            
            if(state_level()){
                if(!is.null(current_state()))
                tmp_stat_dat <- us_state[[current_state()]]
                tmp_stat_dat$ID[d$curveNumber+1]
            }
            else{ # National Level
                # Find State Name
                tmp_stat <- us$ID[d$curveNumber+1]
                
                # Update reactive data
                current_state(tmp_stat)
                state_level(TRUE)
                #js$resetClick()
                
                # return State Name
                current_state()

            }
        }
    })
    
})
