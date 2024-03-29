# Quickload Simplified Maps
Code for GIS analysts demonstrating how to use rmapshaper to simplify polygons for faster loading leaflet maps in R.

If you wish to learn more about rendering boundary polygons over basemaps then please read the Custom-Geog-Maps-R repository located on this account. This project is intended as a next step to creating basic leaflet renders for those looking to deploy these maps as part of an interactive app. 

Author: Richard Haigh

Date of Intial Upload: 06/04/2020

Written - R Desktop 3.5.2

Environment: RStudio v1.2.1335

Packages: rmapshaper v0.4.3, tidyverse v1.2.1, leaflet v2.0.2, rgdal v1.4-6, sf v0.8-1, Rcpp v1.0.3, data.table v1.12.8

This is intended to be a guide for analysts and statisticians with a mid-level knowledge of R for geospatial imaging. 

Complex polygon boundaries and their supporting shapefiles are extremely detailed and large files. When deploying these to a 
live environment, this can lead to significant loading times. This code will demonstrate how to use the rmapshaper package to 
mathematically simplify the boundaries and compress the base map, similar to zipping a folder. Simply put, the package removes
the thousands of tiny details within each polygon but keeps the general shape. 

Note that this approach is not suitable if you require complex, street-level analysis for population weighting techniques. This 
tool should only be useed when your maps are simply for high-level, visual analysis. 

Analysts can then simply save the simplified basemap as an .rds object and deploy this to their chosen staging environment. 
This will dramatically decrease map loading times for users. 

Sample data for demonstration purposes is provided via a csv file based on daily covid-19 cases across Scottish healthboards. Boundaries are collected from stats.gov. 
