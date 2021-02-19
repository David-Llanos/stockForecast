rm(list=ls())
library(pacman)
p_load(data.table, foreach, zoo,  caret, lubridate, quantmod, DataCombine, reshape, 
       QuantTools, BatchGetSymbols, randomForest, caretEnsemble, shiny)



# Global ------------------------------------------------------------------




# SibeBar -----------------------------------------------------------------

shinyUI(fluidPage(

    titlePanel("Forecast Stock Prices"),

    sidebarLayout(
        sidebarPanel(
            
            selectInput('stock', 'Select Stock',
                        choices = c('a','b','c'), 
                        selected='a'),
            sliderInput("horizon",
                        "Days ahead:",
                        min = 1,
                        max = 20,
                        value = 5)
        ),


# MainPanel ---------------------------------------------------------------

        
        mainPanel(
            plotOutput("distPlot")
        )
    )
))
