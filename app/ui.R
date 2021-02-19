rm(list=ls())
library(pacman)
p_load(data.table, foreach, zoo,  caret, lubridate, quantmod, DataCombine, reshape, 
       QuantTools, BatchGetSymbols, randomForest, caretEnsemble, shiny, plotly, DT)



# Global ------------------------------------------------------------------

df.SP500 <- GetSP500Stocks()
tickers <- df.SP500$Tickers


# SideBar -----------------------------------------------------------------

shinyUI(fluidPage(
    
    titlePanel('Forecast Stock Prices'),
    
    sidebarLayout(
        sidebarPanel(width =2,
            
            selectInput('stock', 'Select Stock',
                        choices = sort(tickers), 
                        selected='GE'),
            sliderInput('horizon',
                        'Days ahead:',
                        min = 1,
                        max = 20,
                        value = 5)
           
        ),
        

        
        
        # MainPanel ---------------------------------------------------------------
        mainPanel(
            
            tabsetPanel(type = "tabs",
                        tabPanel("Plot", 
                                 dataTableOutput('storedDataTable')
                                 ),
                        tabPanel("Summary", 
                                 verbatimTextOutput("summary")
                                 ),
                        tabPanel("Update", 
                                 actionButton(inputId= 'update', label = 'Update Data')
                                 )
            )
            
            
        )
    )
)
)
