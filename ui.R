#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)
library(tidyverse)

#covid_us <- read_rds("Data/us_covid.rds")
meta_data <- read_rds("Data/meta_data.rds")

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("COVID-19 US/State Map"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            tags$h5("Due to the volume of the data, loading map can take some time. Thanks for your patience."),
            hr(),
            sliderInput("date",
                        label = h5("Choose Date of Interest:"),
                        min = as.Date("2020-03-01"),
                        max = as.Date(meta_data$data_last_date),
                        value = as.Date(meta_data$data_last_date)),
            #tags$br(),
            hr(),
            # Reporting Statistics
            radioButtons("outcome", label = h5("Choose Reported Measure:"), 
                         choices = list("Number of Cases" = "cases",
                                        "Number of Death" = "deaths", 
                                        "Rate of Cases" = "cases_rate",
                                        "Rate of Deaths" = "deaths_rate"),
                         selected = "cases_rate"),
            hr(),
            tags$div(class="header", checked=NA,
                     tags$p("")),
            hr(),
            tags$div(class="header", checked=NA,
            tags$p("The COVID-19 statistics is generated using ",
                   a("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")),
            tags$p("Laste generated at ",
                         meta_data$update_time, " in ", Sys.timezone()," time." )
            ),
            
            hr(),
            tags$div(class="header", checked=NA,
                     tags$p("Due to techinical difficulties, the author regrets not being
                            able to include Alaska, American Samoa, Guam, Hawaii, Northern
                            Mariana Islands, Puerto Rico, Virgin Islands.")),
            hr(),
            tags$div(class="header", checked=NA,
                     tags$p("Created by Boyi Guo at University of Alabama at Birmingham"),
                     tags$p("Department of Biostatistics, School of Public Health"),
                     tags$p("If you have any suggestions or concerns, 
                              please contact author via GitHub @boyiguog1, Twitter @boyiguo1 or boyiguo1 AT uab.edu"))
            
        ),
        mainPanel(
            
            tags$h4("Click on the map to go to the state map."),
            actionButton("toNational", "Back to National Map"),
            plotlyOutput("distPlot")
        )
        
    )
)# End Fluid Page
)# End Shiny UI
