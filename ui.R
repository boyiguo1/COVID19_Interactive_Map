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
    titlePanel("County Level Map"),

    # Sidebar with a slider input for number of bins
    fluidPage(
        # useShinyjs(),
        # extendShinyjs(text = "shinyjs.resetClick = function() { Shiny.onInputChange('.clientValue-plotly_click-A', 'null'); }"),
        # # Show a plot of the generated distribution
        mainPanel(
            sliderInput("date",
                        "Date:",
                        min = as.Date("2020-03-01"),
                        max = as.Date(Sys.Date()),
                        value = as.Date(Sys.Date())),
            actionButton("toNational", "Back to National Map"),
            plotlyOutput("distPlot")#,
            #verbatimTextOutput("clickText")
        )

    )
))
