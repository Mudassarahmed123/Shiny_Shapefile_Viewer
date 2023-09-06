# Shiny_Shapefile_Viewer

This is a Shiny web application for visualizing shapefiles. It allows you to upload shapefiles and view them on a map. You can also create charts based on the data in the shapefile.

## Getting Started

To use this application, follow these steps:

1. Choose a "Risk Assessment Step" from the sidebar (Step 1, Step 2, or Step 3).

2. If you select "Step 1: Geolocations," you can upload a shapefile in KML or GPkg format and click "Plot Shapefile" to visualize it on the map.

3. If you proceed to create a chart, select the X-axis and Y-axis variables and click "Create Chart" to generate the chart.

4. Explore the map and charts to analyze your shapefile data.

## Libraries Used

This application is built using the following R packages:

- Shiny
- Leaflet
- rgdal
- shinyjs
- dplyr

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
