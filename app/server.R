rm(list=ls())
library(pacman)
p_load(data.table, foreach, zoo,  caret, lubridate, quantmod, DataCombine, reshape, 
       QuantTools, BatchGetSymbols, randomForest, caretEnsemble, shiny, plotly, DT, forecast)


# Global ------------------------------------------------------------------
df.SP500 <- GetSP500Stocks()
tickers <- df.SP500$Tickers

first.date <- Sys.Date() -366
last.date <- Sys.Date()-1

cacheFolder= 'C:/Users/drlla/Documents/DavidAlejandro/stockForecast/cacheData/'
storedFolder='C:/Users/drlla/Documents/DavidAlejandro/stockForecast/storedData/'
preProcessedFolder='C:/Users/drlla/Documents/DavidAlejandro/stockForecast/preProcessedData/'

shinyServer(function(input, output) {
    

# batchData ---------------------------------------------------------------

    batchData<-eventReactive(input$update,{
        l.out <- BatchGetSymbols(tickers = tickers,
                                 first.date = first.date,
                                 last.date = last.date,
                                 freq.data = 'daily',
                                 do.complete.data = T,
                                 do.fill.missing.prices=T,
                                 cache.folder= cacheFolder)
        
        dt=as.data.table(l.out[["df.tickers"]])
        dc=dcast.data.table(dt, ref.date~ticker,
                            value.var=c('price.low','price.high','price.open',
                                        'price.close','price.adjusted', 'volume'))
        fwrite(dc, paste0(storedFolder,'DataOn_',gsub("-| |:","_", Sys.time()),'.csv' ) )
        
        ###LAGS
        toLag<-names(dc)[2:ncol(dc)] 
        toName = paste(toLag, "L1", sep="_")
        dc[order(ref.date),(toName):= data.table::shift(.SD, 1, type= 'lag'), .SDcols=toLag]
        dc[, (toName):=na.locf(.SD, fromLast = T), .SDcols=toName]
        dc[, (toName):=predict(preProcess(.SD,method="knnImpute"), .SD), .SDcols=toName]
        
        fwrite(dc, paste0(preProcessedFolder,Sys.Date(),'.csv') )
        

    })


# storedData ---------------------------------------------------------------

    storedData<-reactive({
        lastFile=list.files(storedFolder, full.names = T) #### REVIEW
        dc=fread( lastFile ) 
        })
    

# preProcessedData --------------------------------------------------------


    preProcessedData<-reactive({
        lastFile=list.files(preProcessedFolder, full.names = T) #### REVIEW
        dc=fread( lastFile ) 
    })


# storedDataTable ------------------------------------------------------------

    
    
    output$storedDataTable <- renderDataTable({

        dc=preProcessedData()
        selCols<-grep(input$stock,value=T, names(dc))
        selCols2<-append('ref.date',selCols)
        dt=dc[,selCols2, with=F]
        datatable(dt, caption='Stored Data', filter='top')

    })


# ARIMA -------------------------------------------------------------------

    arima<-reactive({
        dc=preProcessedData()
        ltest<-input$horizon
        ltrain<-nrow(dc)-ltest 
        
        #out-of-sample prediction
        y<- paste0('price.close_GE')
        y.ts<- dc[(1:ltrain),y , with=F ]
        ts1 <- ts(y.ts, start= c(2020,1), frequency=360)
        arimaP <- auto.arima(ts1)
        arima.prediction <- as.data.frame(forecast(arimaP, h=ltest))
        arima.pred.point<-as.data.frame(arima.prediction[,1])
        colnames(arima.pred.point)<-"arima"
        arima.pred.point$series<-"prediction"
        arima.pred.point<-data.frame(date= dc[(nrow(dc)-ltest+1):nrow(dc) ,"date"],
                                     arima.pred.point)
        
        #arima forecast 
        y.ts<- dc[,grep("Close",names(dc))]
        ts1 <- ts(y.ts, start= c(year1,month1), frequency=f1)
        arimaF <- auto.arima(ts1)
        arima.forecast <- as.data.frame(forecast(arimaF, h=ltest))
        arima.forecast.point<-as.data.frame(arima.forecast[,1])
        colnames(arima.forecast.point)<-"arima"
        arima.forecast.point$series<-"forecast"
        
        arima.forecast.point<-data.frame(date= seq(as.Date(as.character(dc[nrow(dc), 'date'])) +1, 
                                                   by = as.character(dt.dates[dt.dates$frequency==f1,"by"]), 
                                                   length.out = ltest),
                                         arima.forecast.point)
    })
    
    
    
    
})
