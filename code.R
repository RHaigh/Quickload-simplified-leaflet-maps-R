library(tidyverse)
library(rbin)
library(sf)
library(Rcpp)
library(rgdal)
library(data.table)

# Load in chosen boundaries from shapefile - example used is healthboard boundaries available from: https://data.gov.uk/dataset/27d0fe5f-79bb-4116-aec9-a8e565ff756a/nhs-health-boards
boundaries <- readOGR(dsn="./SG_NHS_HealthBoards_2019", layer="SG_NHS_HealthBoards_2019")

# Simplify the geometric boundaries using ms_simplify from the rmapshaper package
boundaries_simplified <- dz_boundaries %>%
  rmapshaper::ms_simplify(keep = 0.05)

# Convert eastings and northing to lat and long
wgs84 = '+proj=longlat +datum=WGS84'
boundaries_simplified <- spTransform(boundaries_simplified, CRS(wgs84))

# Save this simplified shapefile for later use as an RDS object to the same geodatabase folder
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

# In order to colour these polygon boundaries, you need to merge this shapefile object with a dataframe that has the same values in at least one column
# We will use the Scottish cases of Covid19 from the last 24 hours
scot_cases <- read.csv("./scot_covid_update.csv")

# Merge simplified map boundaries and dataframe based on common column
map <- merge(boundaries_simplified, scot_cases, by.x = "HBName", 
             by.y = "Area", all.x = FALSE, duplicateGeoms = TRUE)

# We can automate calculation of bins with rbin package functions or manually input them
bins_breaks <- c(0, 50, 100, 150, 200, 300, 400, Inf)

# Choose our palette from the existing list of CSS palettes
pal <- colorBin("YlOrRd", domain = table, bins = bins_breaks)

# Choose labels, using html if you like
labels <- sprintf(
  "<strong>%s</strong><br/>%s",
  paste0("Health Board: ", map$HBName), paste0("Confirmed Cases ", Sys.Date(), ": ", map$TotalCases)
) %>% lapply(htmltools::HTML)

# Finally run leaflet function to create map
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




