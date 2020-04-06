# Quickload Simplified Maps
Code for GIS analysts demonstrating how to use rmapshaper to simplify polygons for faster loading leaflet maps in R.

Author: Richard Haigh

Date of Intial Upload: 06/04/2020

Written - R Desktop 3.5.2

Environment: RStudio v1.2.1335

Packages: rmapshaper v0.4.3, tidyverse v1.2.1, leaflet v2.0.2, rgdal v1.4-6, sf v0.8-1, Rcpp v1.0.3, data.table v1.12.8

This is intended to be a guide for analysts and statisticians with a mid-level knowledge of R for geospatial imaging. 

Complex polygon boundaries and their supporting shapefiles are extremely detailed and large files. When deploying these to a 
live environment, this can lead to significant loading times. This code will demonstrate how to use the rmapshaper package to 
mathematically simplify the boundaries and compress the base map, similar to zipping a folder. 

Analysts can then simply save the simplified basemap as an .rds object and deploy this to their chosen staging environment. 
This will dramatically decrease map loading times for users. 

Sample data for demonstration purposes is provided via a csv file based on daily covid-19 cases across Scottish healthboards. Boundaries are collected from stats.gov. 
