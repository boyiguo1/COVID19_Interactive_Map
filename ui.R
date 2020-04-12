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

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("COVID-19 US Map by State"),
    # Sidebar with a slider input for number of bins
    fluidPage(

        mainPanel(
            tags$h4("Due to the volume of the data, the loading
                    of the map can take some time. Please be Patient."),
            tags$h4("Click on the map to go to the state map."),
            tags$p("Please choose the date you want to inquire:"),
            sliderInput("date",
                        "Date:",
                        min = as.Date("2020-03-01"),
                        max = as.Date(Sys.Date()-1),
                        value = as.Date(Sys.Date()-1)),
            actionButton("toNational", "National Map"),
            plotlyOutput("distPlot")#,
            #verbatimTextOutput("clickText")
        )

    )
))
