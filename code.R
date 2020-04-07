library(tidyverse)
library(rbin)
library(sf)
library(Rcpp)
library(rgdal)
library(data.table)

# Load in chosen boundaries from shapefile - example used is healthboard boundaries available from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
boundaries <- readOGR(dsn="./SG_NHS_HealthBoards_2019", layer="SG_NHS_HealthBoards_2019")
# If you are new to shapefiles in R, the dsn is the location of your shapefile folder and the layer is the file ending in .shp

# Simplify the geometric boundaries using ms_simplify from the rmapshaper package
boundaries_simplified <- dz_boundaries %>%
  rmapshaper::ms_simplify(keep = 0.05)

# Convert eastings and northings to lat and long
# This is necessary as leaflet only understands lat and long and otherwise your map will end up in the middle of the Atlantic
wgs84 = '+proj=longlat +datum=WGS84'
boundaries_simplified <- spTransform(boundaries_simplified, CRS(wgs84))

# Save this simplified shapefile for later use as an RDS object to the same geodatabase shapefile folder
writeOGR(obj = boundaries_simplified, 
         
         dsn="./SG_NHS_HealthBoards_2019",
         
         layer = "SG_NHS_HealthBoards_2019_simplified", 
         
         driver = "ESRI Shapefile", 
         
         overwrite_layer = TRUE)

# This RDS file can later be uploaded along with app.R files as part of a shiny app. It is the only file you need to render the leaflet map
# Choose where to save your new rds object
saveRDS(boundaries_simplified, "./SG_NHS_HealthBoards_2019_simplified.rds"))

# When opening your R environment, you can read this in with the following code:
boundaries_simplified <- readRDS("./SG_NHS_HealthBoards_2019_simplified.rds")

# Now we will look at a practical application - shading boundary polygons according to data

# In order to colour polygon boundaries, you need to merge this shapefile object with a dataframe that has the same location values in at least one column
# We will use the Scottish cases of Covid19 by healthboard from the last 24 hours
scot_cases <- read.csv("./scot_covid_update.csv")

# Merge simplified map boundaries and dataframe based on columns with the same values
map <- merge(boundaries_simplified, scot_cases, by.x = "HBName", 
             by.y = "Area", all.x = FALSE, duplicateGeoms = TRUE)
# Your shapefile now has the additional data it needs

# We can automate calculation of bins with the rbin package functions or manually input them for simplicity
bins_breaks <- c(0, 50, 100, 150, 200, 300, 400, Inf)

# Choose our palette from the existing list of CSS palettes
pal <- colorBin("YlOrRd", domain = table, bins = bins_breaks)

# Choose labels, using html if you like
labels <- sprintf(
  "<strong>%s</strong><br/>%s",
  paste0("Health Board: ", map$HBName), paste0("Confirmed Cases ", Sys.Date(), ": ", map$TotalCases)
) %>% lapply(htmltools::HTML)

# Finally run leaflet function to create the map
leaflet(map) %>%
  setView(-3.2008, 55.9452, 5) %>% # Choose lat and long to open on and zoom level
  addProviderTiles(providers$CartoDB.DarkMatter, # Choose background tiles
                   options= providerTileOptions(opacity = 0.99)) %>%
  addPolygons(fillColor = ~pal(map$TotalCases), # Fill polygons based on x
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                dashArray = "",
                fillOpacity = 0.7,
                bringToFront = TRUE), 
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%
  leaflet::addLegend("bottomright", pal = pal, values = ~bins_breaks, # Add legend if desired
                     title = "COVID-19 Tracker",
                     opacity = 1
  )

map




