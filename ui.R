# DEMO

library(shiny)
library(shinydashboard)
library(leaflet)
library(DT)


shinyUI(dashboardPage(
    
    skin = 'black',
    dashboardHeader(title = 'WattaBase'),
    dashboardSidebar(
        width = 250,
        tags$img(src = 'logo_.png', width="100%", height="100%"),
        htmlOutput('sideBtext')
    ),
    dashboardBody(
        tags$head(tags$style('#sideBtext{font-size: 16px; margin-left: 0.5em; margin-right: 0.5em}')),
        tags$head(tags$style(HTML(".skin-black .main-sidebar {background-color:  #002060}"))
                  ),

        titlePanel(
            h1("MARKET INTELLIGENCE FOR AUCTIONS", style = "font-weight: 500; color:#00008B; text-align: center;")
            ),
        
            h4(' This page gives an overview of various data of onshore wind projects that have received an environmental permit 
            in France in 2019. In the boxes below selection criteria can be 
            entered for the minimum number of turbines turbine output (MW), and date to filter the data. The criteria are handled as 
               OR. The graphs on this page are adapted accordingly.',
               br(),
               br()),
            h2(' THIS IS A DEMO AND ONLY CONTAINS DATA OF PROJECTS PERMITTED IN 2019', style = "font-weight: 500; 
               text-align: center; color: red;",
               br(),
               br()),
        
        column(
            numericInput('min_nrTur', 'Number of turbines greater than', 1, min = 1, max = NA, value = 1),
            width = 4
        ),
        
        column(
            numericInput('min_turCap', 'Turbine output(MW) greater than', 1, min = 1, max = NA, value = 1),
            width = 4
        ),
        
        column(
            dateInput('date_ap', 'Show as from date(yyyy-mm-dd)', value = '2019-01-01', format = 'yyyy-mm-dd'),
            width = 4,
            tags$style(HTML(".datepicker {z-index:99999 !important;}"))
        ),
        
        #actionButton("update_charts", label = "Update", width = "100%"),
        
        #ROW GENERAL AVERAGED DATA
        fluidRow(
            h2(" 1. General overview", style = "font-weight: 400; color: #00008B"),
            
            column(
                h4('Volume:'),
                textOutput('total_volume'),
                tags$head(tags$style("#total_volume{color: black;
                                 font-size: 25px;
                                font-style: bold;
                                     color: red;}")
                ),
                width = 3
            ),
            
            column(
                h4('Projects:'),
                textOutput('projects'),
                tags$head(tags$style("#projects{color: black;
                                 font-size: 25px;
                                     font-style: bold;
                                     color: red;}")
                ),
                width = 3
            ),
            
            column(
                h4('Average parc output:'),
                textOutput('avParcP'),
                tags$head(tags$style("#avParcP{color: black;
                                 font-size: 25px;
                                     font-style: bold;
                                     color: red;}")
                ),
                width = 3
            ),
            
            column(width = 3
            )
        ),
            
        fluidRow(
            column(
                h4('Average turbine output:'),
                textOutput('avTurP'),
                tags$head(tags$style("#avTurP{color: black;
                                 font-size: 25px;
                                     font-style: bold;
                                     color: red;}"),
                ),
                width = 3
            ),
            
            column(
                h4('Average hub height:'),
                textOutput('avHheight'),
                tags$head(tags$style("#avHheight{color: black;
                                 font-size: 25px;
                                     font-style: bold;
                                     color: red;}")
                ),
                width = 3
            ),
            
            column(
                h4('Average total height:'),
                textOutput('avTheight'),
                tags$head(tags$style("#avTheight{color: black;
                                 font-size: 25px;
                                     font-style: bold;
                                     color: red;}")
                ),
                width = 3
            ),
            
            column(
                h4('Average rotor diameter:'),
                textOutput('avRdiam'),
                tags$head(tags$style("#avRdiam{color: black;
                                 font-size: 25px;
                                     font-style: bold;
                                     color: red;}")
                ),
                width = 3
            )
        ),
        
        #ROW DISTRIBUTION PER MONTH
        
        fluidRow(
            h2(" 2. Approved projects per month", style = "font-weight: 400; color: #00008B"),
            
            h4('The barplot below shows the distribution of approved volume (MW) per month since the chosen date above',
               style = 'margin-left: 1em;',
               br(),
               br()),
            box(status = 'primary', plotOutput('PperMonth'), width = 12)
        ),
        
        #ROW HISTOGRAMS OUTPUTS AND DIMENSIONS
        fluidRow(
            h2(" 3. Turbine and parc outputs", style = "font-weight: 400; color: #00008B"),
            
            column(
                h4('The histogram below shows the distribution of the turbine unit outputs (MW). 
                   The frequency is the number of projects per interval',
                   br(),
                   br()),
                box(status = 'primary', plotOutput('TurPmax'), width = NULL),
                downloadButton('dl_hist_turCap', 'Dowload data turbine capacity'),
                width = 6
            ),
            column(
                h4('The histogram below shows the distribution of the maximum parc outputs (MW).
                   The frequency is the number of projects per interval',
                   br(),
                   br()),
                box(status = 'primary', plotOutput('ParcPmax'), width = NULL),
                width = 6
            )
        ),
        
        #third row
        fluidRow(
            h2(" 4. Turbine dimensions", style = "font-weight: 400; color: #00008B"),
            
            column(
                h4('The histogram below shows the distribution of the rotor diameter (m). 
                   The frequency is the number of projects per interval',
                   br(),
                   br()),
                box(status = 'primary', plotOutput("histRotor"), width = NULL),
                width = 4
            ),
            column(
                h4('The histogram below shows the distribution of the total turbine height (m) until the tip of the blade. 
                   The frequency is the number of projects per interval',
                   br(),
                   br()),
                box(status = 'primary', plotOutput("histHtot"), width = NULL),
                width = 4
            ),
            column(
                h4('The histogram below shows the distribution of the turbine hub height (m). 
                   The frequency is the number of projects per interval',
                   br(),
                   br()),
                box(status = 'primary', plotOutput("histHub"), width = NULL),
                width = 4
            )
        ),
        
        #fourth row
        fluidRow(
            h2('5. Scatter plot with parameters of choice', style = "font-weight: 400; color: #00008B"),
            h4('In the interactive scatter plot below one can choose between multiple parameters for both axes. 
               In addition, a parameter can be chosen for the bubble size. The different parameters that can be selected are:',
               style = 'margin-left: 1em;'),
            h4('- Rotor diameter (D_rotor)', br(),
               '- Total turbine height (H_total)', br(),
               '- Hub height (H_hub)', br(),
               '- Turbine output (unit_capacity)', br(),
               '- Total parc output (Pmax_parc)', br(),
               '- Average windspeed (avs)', br(),
               '- Numbre of turbines (nr_machine)', style = 'margin-left: 2em;',
               br(),
               br()),
            
            column(
                selectInput("x_axis", "Choose x axis parameter", choices = NULL),
                width = 4),
            column(
                selectInput("y_axis", "Choose y axis parameter", choices = NULL),
                width = 4),
            column(
                selectInput("point_size", "Choose parameter that defines the bubble size", choices = NULL),
                width = 4)
        ),
        
        fluidRow(
            
            box(status = 'primary', plotOutput("scatterplot"), width = 12)
        )
    )
    )
)