source("src/librerias.R")
source("src/funciones.R")
load("data_tidy/datos.RData")
load("data/mapa.RData")

# Cargamos los datos

# Barra lateral ----
# ·······························································································
sidebar <-  dashboardSidebar(
  # tags$head(
  #   tags$style(HTML(".sidebar {
  #                   height: 85vh; overflow-y: auto;
  #                   }"
  #              ) # close HTML       
  #   )            # close tags$style
  #   ), 
  sidebarMenu(id = "sidebarmenu",
              menuItem("Filter Data", tabName = "tab0", startExpanded = FALSE,
              selectInput('year', 'Year', unique(datos$year),multiple=TRUE, selectize=TRUE),
              selectInput('month', 'Month', unique(datos$month),multiple=TRUE, selectize=TRUE),
              dateRangeInput("dates", label = "Date range", start = "2015-01-01", end = "2017-12-31"),
              selectInput('calification', 'Calification', unique(datos$calification),multiple=TRUE, selectize=TRUE),
              selectInput('type', 'Type', unique(datos$type),multiple=TRUE, selectize=TRUE),
              selectInput('points', 'Points', unique(datos$points),multiple=TRUE, selectize=TRUE)),
              menuItem("Options", tabName = "tab1", startExpanded = FALSE,
                conditionalPanel("input.tabset1 === 'Map'",
                  numericInput("top", "Locations with more than X fines:", 10, min = 1, max = 10000),
                  selectInput('separar', 'Compare by', c("Nothing","Year", "Calification", "Month", "Points"), multiple=FALSE, selectize=TRUE),
                  radioButtons("map_type", "Map type: ", c("Points", "Heat map", "Both"))
              ),
              conditionalPanel("input.tabset1 === 'Summary'",
                               radioButtons("serie", "Time serie", c("Nº Cases", "Euros collected"))
              
              ))
  )
)


pagina.1 <- tabPanel("Map",
                     height   = "80vh",
                     plotOutput(outputId = "mapa",
                                width    = "100%",
                                height   = "76vh",
                                click    = "plot_click",
                                brush    = "plot_brush"))

pagina.2 <- tabPanel("Summary", 
                     height   = "80vh",
                     sidebarLayout(
                       sidebarPanel(
                         width = 3,
                         selectInput('capas', 'Levels', c("Year", "Calification", "Points", "Type"), multiple=TRUE, selectize=TRUE, selected = c("Year", "Calification"))
                       ),
                                 mainPanel(
                                   
                                   sunburstOutput(outputId = "sunburst",
                                                  width    = "100%",
                                                  height   = "38vh"))
                       
                       ),
                     dygraphOutput("dygraph",
                                   height = "38vh")
)
                     

# Cuerpo ----
# ·······························································································
body <- dashboardBody(
  fluidPage(
    useShinyalert(),  # Set up shinyalert
    tabBox(width  = 12,
           id     = "tabset1",
    pagina.1,
    pagina.2
    )
  )
)

# Ejecucion ----
# ·······························································································
dashboardPage(
    dashboardHeader(title = "R Contest"),
    sidebar,
    body
)


