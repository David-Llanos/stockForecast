rm(list=ls())
library(pacman)
p_load(data.table, foreach, zoo,  caret, lubridate, quantmod, DataCombine, reshape, 
       QuantTools, BatchGetSymbols, randomForest, caretEnsemble, shiny)


# Global ------------------------------------------------------------------
df.SP500 <- GetSP500Stocks()
tickers <- df.SP500$Tickers

first.date <- Sys.Date() -366
last.date <- Sys.Date()-1

cacheFolder= 'C:/Users/drlla/Documents/DavidAlejandro/stockForecast/cacheData/'



shinyServer(function(input, output) {
    

# batchData ---------------------------------------------------------------

    batchData<-reactive({
        start<-Sys.time()
        l.out <- BatchGetSymbols(tickers = tickers,
                                 first.date = first.date,
                                 last.date = last.date,
                                 freq.data = 'daily',
                                 do.complete.data = T,
                                 do.fill.missing.prices=T,
                                 cache.folder= cacheFolder)
        
        dt=as.data.table(l.out[["df.tickers"]])
        dc=dcast.data.table(dt, ref.date~ticker,
                            value.var=c('price.low','price.high','price.open', 'price.close','price.adjusted', 'volume'))
        
        (end<-Sys.time()-start)
        
    })

    output$distPlot <- renderPlot({

        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })

})
