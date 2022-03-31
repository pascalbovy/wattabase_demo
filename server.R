# DEMO

library(shiny)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(lubridate)
library(DT)

# LOAD NECESSARY DATA
df_wind <- read_csv("data/db_wind_accepted.csv") #, locale(encoding = "latin1"))

df_wind <- df_wind %>% 
  mutate(date_AE = as_date(date_AE, format = '%d-%m-%y'))

df_month <- read_csv('data/db_wind_month.csv')

cols = c('date_AE', 'dep_nr', 'region', 'avs', 'nr_machine', 'unit_capacity', 'Pmax_parc', 
         'H_total', 'H_hub', 'D_rotor')

#df <- df_wind %>%
  #select(cols) %>%
  #filter(date_AE >= "2020-01-01") #%>%

#regions = unique(df$region)


# SHINY SERVER CODE
shinyServer(function(input, output, session) {
  
  df_filter <- reactive(
    df_wind %>%
    filter(nr_machine > input$min_nrTur | unit_capacity > input$min_turCap, date_AE >= input$date_ap) # OR or AND?!
    )
  
  #SIDEBAR
  output$sideBtext <- renderUI({
    HTML(paste(
      br(),
      br(),
      'This dashboard gives an overview of outputs and dimensions of wind parcs that are 
      eligible to participate in auctions.', 
      br(),
      br(),
      'Contact:',
      br(),
      'pal@acajoo-advisory.com'
      
      )
         )
  })
  
  # GENERAL OVERVIEW
  #First row with numerical summary of various indicators (#projects, volume, etc.)
  output$total_volume <- renderText({
    
    vol <- df_filter() %>%
      drop_na(Pmax_parc) %>%
      summarize(volume = sum(Pmax_parc))
    
    c(as.integer(vol), 'MW')
    
  })
  
  output$projects <- renderText({
    
    proj_count <- df_filter() %>%
      summarize(n = n())
    
    as.integer(proj_count)
    
  })
  
  output$avParcP <- renderText({
    
    avParcMW <- df_filter() %>%
      drop_na(Pmax_parc) %>%
      summarize(mean(Pmax_parc))
    
    c(as.integer(avParcMW), 'MW')
    
  })
  
  #Second row
  output$avTurP <- renderText({
    
    avTurMW <- df_filter() %>%
      drop_na(unit_capacity) %>%
      summarize(mean(unit_capacity))
    
    c(round(as.numeric(avTurMW), 1), 'MW')
  })
  
  output$avHheight <- renderText({
    
    avHub <- df_filter() %>%
      drop_na(H_hub) %>%
      summarize(mean(H_hub))
    
    c(as.integer(avHub), 'm')
  })
  
  output$avTheight <- renderText({
    
    avTotal <- df_filter() %>%
      drop_na(H_total) %>%
      summarize(mean(H_total))
    
    c(as.integer(avTotal), 'm')
  })
  
  output$avRdiam <- renderText({
    
    avDiam <- df_filter() %>%
      drop_na(D_rotor) %>%
      summarize(mean(D_rotor))
    
    c(as.integer(avDiam), 'm')
  })
    
  #PLOT DISTRIBUTION PER MONTH
  # https://statisticsglobe.com/aggregate-daily-data-to-month-year-intervals-in-r
  # https://ro-che.info/articles/2017-02-22-group_by_month_r
  output$PperMonth <- renderPlot({
    
    
    df_month %>%
      filter(year_month >= '2019-01-01') %>%
      filter(unit_capacity >= input$min_turCap |  nr_machine >= input$min_nrTur, date_AE >= input$date_ap) %>%
      group_by(year_month) %>%
      summarise(volume = sum(Pmax_parc)) %>%
      ggplot(aes(x=year_month, y=volume)) +geom_col(fill = 'palegreen3', width = 18) +
      theme(text = element_text(size=16)) + theme(axis.text.x = element_text(angle=90)) + scale_x_date(date_breaks = "1 months") +
      coord_cartesian(ylim = c(0, 400)) + xlab('Month') + ylab('Volume (MW)')
    
  })
  
  # PLOTS OUTPUT AND DIMENSIONS
    output$TurPmax <- renderPlot({
      
      unit_cap <- df_filter() %>%
        select(unit_capacity) %>%
        drop_na()
      
      #histogram plot
      unit_cap_ <- as.numeric(unlist(unit_cap)) 
      bins <- seq(min(unit_cap_), max(unit_cap_), length.out = 6) 
      hist_uc <- hist(unit_cap_, main = 'Histogram of turbine output', breaks = bins, col = 'dodgerblue2', 
           border ='white', xlab = "output (MW)")
      
      #table for download
      turbine_cap_lower <- hist_uc$breaks[1:5]
      turbine_cap_upper <- hist_uc$breaks[2:6]
      frequency <- hist_uc$counts
      df_hist_turCap <- data.frame(turbine_cap_lower, turbine_cap_upper, frequency)
      
      output$dl_hist_turCap <- downloadHandler(
        filename = 'turbine_capacity.csv',
        content = function(file){
          write.csv(df_hist_turCap, file)
        }
      )
      
    })
    
    output$ParcPmax <- renderPlot({
      
      parc_cap <- df_filter() %>%
        select(Pmax_parc) %>%
        drop_na()
      
      parc_cap_ <- as.numeric(unlist(parc_cap)) 
      bins <- seq(min(parc_cap), max(parc_cap), length.out = 6) 
      hist(parc_cap_, main = 'Histogram parc output', breaks = bins, 
           col = 'dodgerblue3', border ='white', xlab = "Parc capacity (MW)")
      
    })
    
    # D_rotor histogram
    output$histRotor <- renderPlot({
        
        rotor <- df_filter() %>%
            select(D_rotor) %>%
            drop_na()
        
        Diameter <- as.numeric(unlist(rotor))
        bins <- seq(min(Diameter), max(Diameter), length.out = 7)
        hist(Diameter, breaks = bins, col = 'salmon1', border ='white', xlab = "Rotor diameter (m)")
    })
    
    #H_total histogram
    output$histHtot <- renderPlot({
        
        htotal <- df_filter() %>%
            select(H_total) %>%
            drop_na()
        
        Total_height <- as.numeric(unlist(htotal))
        bins <- seq(min(Total_height), max(Total_height), length.out = 7) 
        hist(Total_height, breaks = bins, col = 'salmon2', border ='white', xlab = "Total turbine height (m)")
    })
    
    # H hub histogram
    output$histHub <- renderPlot({
        
        hhub <- df_filter() %>%
            select(H_hub) %>%
            drop_na()
        
        Hub_height <- as.numeric(unlist(hhub))
        bins <- seq(min(Hub_height), max(Hub_height), length.out = 7)
        hist(Hub_height, breaks = bins, col = 'salmon3', border ='white', xlab = "Turbine hub height (m)")
    })
    
    # PLOT OUTPUTS FIRST PAGE THIRD ROW
    
    updateSelectInput(session,
                      "x_axis",
                      choices = c('D_rotor', 'H_total', 'H_hub', 'unit_capacity', 'Pmax_parc', 
                                  'avs', 'nr_machine'))
    
    updateSelectInput(session,
                      "y_axis",
                      choices = c('D_rotor', 'H_total', 'H_hub', 'unit_capacity', 'Pmax_parc', 
                                  'avs', 'nr_machine'))
    
    updateSelectInput(session,
                      "point_size",
                      choices = c('D_rotor', 'H_total', 'H_hub', 'unit_capacity', 'Pmax_parc', 
                                  'avs', 'nr_machine'))
    
    output$scatterplot <- renderPlot({
        
        df_filter() %>% 
            select(input$x_axis, input$y_axis, input$point_size, region) %>%
            drop_na() %>%
            ggplot(aes(x = get(input$x_axis), y = get(input$y_axis))) + 
            geom_point(aes(colour = region, size = get(input$point_size)), alpha = 0.5) + 
            guides(colour = guide_legend(override.aes = list(size=8))) +
            scale_size(range = c(1, 10), name = input$point_size) + 
            xlab(input$x_axis) + ylab(input$y_axis) +
            theme(text = element_text(size=15))
      #theme_classic() + 
            
    })
})