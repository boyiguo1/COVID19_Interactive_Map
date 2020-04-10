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
library(sf)
library(maps)
library(plotly)
library(unglue)
# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    # covid <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")
    # al_covid <- covid %>% filter(state == "Alabama") %>% 
    #     transmute(date, cases, 
    #               county = county %>% tolower)
    # 
    al <- st_as_sf(
        maps::map("county", region="Alabama", fill=TRUE, plot =FALSE) 
    ) %>%  mutate(
        ID.char = ID %>% as.character(),
        county = unglue_data(ID.char, "{State},{County}") %>% pull(County))
    
    output$distPlot <- renderPlotly(
        
        # input$date
        
        plot_ly(al, split=~county, color = I("gray90"),
                hoveron = "fills",
                hoverinfo = "text",
                #text = ~paste("num of cases: ", cases, "\n Number of Death", 
                #              cases-10),
                showlegend = FALSE)
    )
})
