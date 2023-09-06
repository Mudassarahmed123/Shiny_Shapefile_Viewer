library(shiny)
library(leaflet)
library(rgdal)
library(shinyjs)
library(dplyr)

ui <- fluidPage(
  shinyjs::useShinyjs(),
  tags$head(
    tags$style(HTML(
      "
      body {
      background-color: #f8f8f8;
      font-family: Arial, sans-serif;
      }
      
      .container {
      background-color: #ffffff;
      border: 1px solid #e0e0e0;
      border-radius: 5px;
      padding: 20px;
      margin-top: 20px;
      box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.1);
      }
      
      .btn-primary {
      background-color: #007BFF;
      border-color: #007BFF;
      }
      .btn-primary:hover, .btn-primary:focus {
      background-color: #0056b3;
      border-color: #0056b3;
      }
      
      .panel-title {
      font-size: 24px;
      font-weight: bold;
      margin-bottom: 20px;
      color: #333;
      }
      
      .input-label {
      font-size: 18px;
      font-weight: bold;
      color: #333;
      }
      
      .info-table table {
      background-color: #fff;
      border: 1px solid #ccc;
      border-radius: 5px;
      padding: 15px;
      box-shadow: 0px 0px 8px 0px rgba(0,0,0,0.2);
      }
      
      /* Custom CSS for the logo */
      .top-right-logo {
      position: absolute;
      top: 10px;
      right: 10px;
      width: 100px; /* Adjust the width as needed */
      }
      "
    ))
  ),
  titlePanel("Shapefile Viewer"),
  div(
    class = "top-right-logo",
    img(src = "/Users/mudassarahmad/Downloads/task-GRAS/Model/logo.png")
  ),
  sidebarLayout(
    sidebarPanel(
      selectInput("step", "Risk Assessment Step:",
                  c("Step1: Geolocations", "Step2: Deforestation verification", "Step3: Due-diligence")
      ),
      
      # Page 1 - Shapefile Upload
      # Only show this panel if the step type is Step1: Geolocations
      conditionalPanel(
        condition = "input.step == 'Step1: Geolocations'",
        fileInput("shapefile", "Upload Shapefile", accept = c('.kml', '.gpkg')),
        actionButton("plotButton", "Plot Shapefile", class = "btn-primary")
      ),
      
      # Page 2 - Chart Configuration
      conditionalPanel(
        condition = "input.step == 'Step1: Geolocations' && input.plotButton > 0",
        selectInput("xField", "Select X-axis Variable:", c("")),
        selectInput("yField", "Select Y-axis Variable:", c("")),
        actionButton("createChartButton", "Create Chart", class = "btn-primary")
      )
    ),
    mainPanel(
      # Page 2 - Map Visualization
      conditionalPanel(
        condition = "input.step == 'Step1: Geolocations' && input.plotButton > 0",
        leafletOutput("map", width = "100%", height = "500px"),
        h4("Map Visualization", class = "panel-title")
      ),
      # Page 3 - Chart Display
      conditionalPanel(
        condition = "input.step == 'Step1: Geolocations' && input.createChartButton > 0",
        h4("Chart Display", class = "panel-title"),
        plotOutput("chart")
      ),
      # Move the table under the panel
      div(
        h4("Shapefile Info", class = "panel-title"),
        tableOutput("shapefileInfo"), class = "info-table"
      )
    )
  )
    )

server <- function(input, output, session) {
  # Reactive value to store the uploaded shapefile
  shapefileData <- reactiveValues(data = NULL)
  
  observeEvent(input$plotButton, {
    inFile <- input$shapefile
    
    if (is.null(inFile))
      return()
    
    shp <- readOGR(inFile$datapath, stringsAsFactors = FALSE)
    shapefileData$data <- shp
    
    # Update selectInput options with column names
    updateSelectInput(session, "xField", choices = c("", colnames(shp@data)))
    updateSelectInput(session, "yField", choices = c("", colnames(shp@data)))
    
    output$map <- renderLeaflet({
      leaflet() %>%
        addProviderTiles("Esri.WorldImagery") %>%
        addPolygons(
          data = shp, 
          fillOpacity = 0.25, 
          color = "yellow",
          popup = paste("Layer:", shp$layer, "<br>",
                        "Area:", shp$Area)
        )
    })
    
    output$shapefileInfo <- renderTable({
      data.frame(
        "Number of Polygons" = nrow(shp),
        "Number of Attributes" = ncol(shp@data),
        check.names = FALSE
      )
    })
  })
  
  observeEvent(input$createChartButton, {
    if (!is.null(shapefileData$data)) {
      xField <- input$xField
      yField <- input$yField
      if (xField != "" && yField != "") {
        chartData <- shapefileData$data@data %>%
          group_by_at(c(xField, yField)) %>%
          summarize(AreaSum = sum(Area))
        
        output$chart <- renderPlot({
          barplot(chartData$AreaSum, names.arg = chartData[[xField]],
                  xlab = xField, ylab = yField, col = "#007BFF")
        })
      }
    }
  })
}

shinyApp(ui, server)
