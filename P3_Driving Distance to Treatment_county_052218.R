######################################################
# Program: P3_Driving Distance to Treatment_county_052218
# Author: Marni Epstein
# Date: March 2021
# Description: This program returns the driving distance and time from county centroids to treatment, using the Google API
######################################################

install.packages("gmapsdistance")
devtools::install_github("rodazuero/gmapsdistance@058009e8d77ca51d8c7dbc6b0e3b622fb7f489a2")

library(gmapsdistance)
library(rgeos)
library(rgdal)
library(tidyverse)
library(ggmap)
library(maps)
library(mapdata)
library(USAboundaries)
library(extrafont)
library(plyr)
library(Cairo)
library(haven)

Sys.setenv(R_GSCMD="C:/Program Files (x86)/gs/gs9.22/bin/gswin32c.exe")

source('https://raw.githubusercontent.com/UrbanInstitute/urban_R_theme/master/urban_theme_windows.R')

# Set API key
set.api.key("XXXXXXXXXXXXXXXXXXXXXXX") # Set API key. Previously used "Urban CHCF NAS API" (connected to Marni's credit card)

setwd("D:/Users/MEpstein/Box Sync/2017 OUD NAS CHCF/3 Data/SAMHSA OTP provider locations/Created datafiles")

# Read in test file with counties and 10 closest lat/longs for treatment centers
data <- read_csv("cty_preg.csv") ## CHANGE file name

# Concatenate lat/longs to the format that gmapsdistance wants
data <- data %>%
  #Create variable in format lat+long to use with gmapsdistance
  mutate(latlong1 = paste(latitude1,"+",longitude1, sep = "")) %>%
  mutate(latlong2 = paste(latitude2,"+",longitude2, sep = "")) %>%
  mutate(latlong3 = paste(latitude3,"+",longitude3, sep = "")) %>%
  mutate(latlong4 = paste(latitude4,"+",longitude4, sep = "")) %>%
  mutate(latlong5 = paste(latitude5,"+",longitude5, sep = "")) %>%
  mutate(latlong6 = paste(latitude6,"+",longitude6, sep = "")) %>%
  mutate(latlong7 = paste(latitude7,"+",longitude7, sep = "")) %>%
  mutate(latlong8 = paste(latitude8,"+",longitude8, sep = "")) %>%
  mutate(latlong9 = paste(latitude9,"+",longitude9, sep = "")) %>%
  mutate(latlong10 = paste(latitude10,"+",longitude10, sep = "")) %>%
  mutate(latlong11 = paste(latitude11,"+",longitude11, sep = "")) %>%
  mutate(latlong12 = paste(latitude12,"+",longitude12, sep = "")) %>%
  mutate(latlong13 = paste(latitude13,"+",longitude13, sep = "")) %>%
  mutate(latlong14 = paste(latitude14,"+",longitude14, sep = "")) %>%
  mutate(latlong15 = paste(latitude15,"+",longitude15, sep = "")) %>%
  mutate(latlong16 = paste(latitude16,"+",longitude16, sep = "")) %>%
  mutate(latlong17 = paste(latitude17,"+",longitude17, sep = "")) %>%
  mutate(latlong18 = paste(latitude18,"+",longitude18, sep = "")) %>%
  mutate(latlong19 = paste(latitude19,"+",longitude19, sep = "")) %>%
  mutate(latlong20 = paste(latitude20,"+",longitude20, sep = "")) %>%
  mutate(centroid = paste(clat,"+",clon, sep = ""))

#small <- data %>%
#  top_n(3)
  
###########################################
# Use gmaps distance to calculate distance and time from centroid to each of the 10 closest crow-flies lat/longs.
# Save distance and time in dist1-10 and time1-10
# Note: time is in seconds and distance is in meters.
###########################################


# Function to calculate diving distance between points
mapdrive <- function(x, y) {
  gmapsdistance(origin = x,
                destination = y,
                mode = "driving",
                dep_date = "2018-08-08", 
                dep_time = "12:00:00")
}

geocodedrive <- function(latlong, timevar, distvar) eval.parent(substitute({

  results <- map2_df(data$centroid, latlong, ~mapdrive(.x, .y))
  timevar <- results$Time
  distvar <- results$Distance
}))

geocodedrive(data$latlong1, data$time1, data$dist1)
geocodedrive(data$latlong2, data$time2, data$dist2)
geocodedrive(data$latlong3, data$time3, data$dist3)
geocodedrive(data$latlong4, data$time4, data$dist4)
geocodedrive(data$latlong5, data$time5, data$dist5)
geocodedrive(data$latlong6, data$time6, data$dist6)
geocodedrive(data$latlong7, data$time7, data$dist7)
geocodedrive(data$latlong8, data$time8, data$dist8)
geocodedrive(data$latlong9, data$time9, data$dist9)
geocodedrive(data$latlong10, data$time10, data$dist10)
geocodedrive(data$latlong11, data$time11, data$dist11)
geocodedrive(data$latlong12, data$time12, data$dist12)
geocodedrive(data$latlong13, data$time13, data$dist13)
geocodedrive(data$latlong14, data$time14, data$dist14)
geocodedrive(data$latlong15, data$time15, data$dist15)
geocodedrive(data$latlong16, data$time16, data$dist16)
geocodedrive(data$latlong17, data$time17, data$dist17)
geocodedrive(data$latlong18, data$time18, data$dist18)
geocodedrive(data$latlong19, data$time19, data$dist19)
geocodedrive(data$latlong20, data$time20, data$dist20)


## Save times for the 3 closest facilities

#keep only county name and time variables
timevars <- data %>%
  select(time1, time2, time3, time4, time5, time6, time7, time8, time9, time10, time11, time12, time13, time14, time15, time16, time17, time18, time19, time20)

#sort columns by time value
sorted <- apply(timevars, 1, sort) # the 1 means sort rows. 2 would mean sort by column.

is.matrix(sorted)

#create new variables for the 3 lowest times
data <- data %>%
  mutate(lowtime1 = as.numeric(sorted[1,])) %>%
  mutate(lowtime2 = as.numeric(sorted[2,])) %>%
  mutate(lowtime3 = as.numeric(sorted[3,]))




#Create new variables for the distances that correspond to the lowest times. 

lowdist <- function(newvar, lowvar) eval.parent(substitute({

  newvar <- ifelse(lowvar == data$time1, data$dist1,
                        ifelse(lowvar == data$time2, data$dist2,
                        ifelse(lowvar == data$time3, data$dist3,                 
                        ifelse(lowvar == data$time4, data$dist4,
                        ifelse(lowvar == data$time5, data$dist5, 
                        ifelse(lowvar == data$time6, data$dist6,
                        ifelse(lowvar == data$time7, data$dist7,
                        ifelse(lowvar == data$time8, data$dist8,
                        ifelse(lowvar == data$time9, data$dist9,
                        ifelse(lowvar == data$time10, data$dist10, 
                        ifelse(lowvar == data$time11, data$dist11, 
                        ifelse(lowvar == data$time12, data$dist12,
                        ifelse(lowvar == data$time13, data$dist13,
                        ifelse(lowvar == data$time14, data$dist14,
                        ifelse(lowvar == data$time15, data$dist15,
                        ifelse(lowvar == data$time16, data$dist16,
                        ifelse(lowvar == data$time17, data$dist17,
                        ifelse(lowvar == data$time18, data$dist18,
                        ifelse(lowvar == data$time19, data$dist19, 
                        ifelse(lowvar == data$time20, data$dist20, 0))))))))))))))))))))


}))

lowdist(data$lowdist1, data$lowtime1)
lowdist(data$lowdist2, data$lowtime2)
lowdist(data$lowdist3, data$lowtime3)

### Check which of the 10 crow-flies distance was the closest driving time
closest <- function(newvar, lowvar) eval.parent(substitute({
  
  newvar <- ifelse(lowvar == data$time1, 1,
                   ifelse(lowvar == data$time2, 2,
                   ifelse(lowvar == data$time3, 3,                 
                   ifelse(lowvar == data$time4, 4,
                   ifelse(lowvar == data$time5, 5, 
                   ifelse(lowvar == data$time6, 6,
                   ifelse(lowvar == data$time7, 7,
                   ifelse(lowvar == data$time8, 8,
                   ifelse(lowvar == data$time9, 9,
                   ifelse(lowvar == data$time10, 10, 
                   ifelse(lowvar == data$time11, 11, 
                   ifelse(lowvar == data$time12, 12,
                   ifelse(lowvar == data$time13, 13,
                   ifelse(lowvar == data$time14, 14,
                   ifelse(lowvar == data$time15, 15,
                   ifelse(lowvar == data$time16, 16,
                   ifelse(lowvar == data$time17, 17,
                   ifelse(lowvar == data$time18, 18,
                   ifelse(lowvar == data$time19, 19,
                   ifelse(lowvar == data$time20, 20, 0))))))))))))))))))))
}))

closest(data$closest1, data$lowtime1)
closest(data$closest2, data$lowtime2)
closest(data$closest3, data$lowtime3)

table(data$closest1)
table(data$closest2)
table(data$closest3)


##BUP ONLY
## Save the treatID of the closest facilities to merge later
treatid <- function(newvar, lowvar) eval.parent(substitute({
  
  newvar <- ifelse(lowvar == data$time1, data$treatid1,
                   ifelse(lowvar == data$time2, data$treatid2,
                   ifelse(lowvar == data$time3, data$treatid3,                 
                   ifelse(lowvar == data$time4, data$treatid4, 
                   ifelse(lowvar == data$time5, data$treatid5, 
                   ifelse(lowvar == data$time6, data$treatid6, 
                   ifelse(lowvar == data$time7, data$treatid7, 
                   ifelse(lowvar == data$time8, data$treatid8, 
                   ifelse(lowvar == data$time9, data$treatid9, 
                   ifelse(lowvar == data$time10, data$treatid10, 
                   ifelse(lowvar == data$time11, data$treatid11, 
                   ifelse(lowvar == data$time12, data$treatid12,
                   ifelse(lowvar == data$time13, data$treatid13,
                   ifelse(lowvar == data$time14, data$treatid14,
                   ifelse(lowvar == data$time15, data$treatid15,
                   ifelse(lowvar == data$time16, data$treatid16,
                   ifelse(lowvar == data$time17, data$treatid17,
                   ifelse(lowvar == data$time18, data$treatid18,
                   ifelse(lowvar == data$time19, data$treatid19,
                   ifelse(lowvar == data$time20, data$treatid20, 0))))))))))))))))))))
}))

#treatid(data$closetreatid1, data$lowtime1)
#treatid(data$closetreatid2, data$lowtime2)
#treatid(data$closetreatid3, data$lowtime3)


# Save a copy of the complete geocoded data for the 10 closest facilities
write_csv(data, "Top 10 distances geocded/cty_change_complete_geodrive.csv") # CHANGE file name

#Keep only county and 3 closest time/distance variables
# rename new name = old name
# CHANGE names for each type of treatment location
final <- data %>%
  select(pcounty,
         lowtime1_preg = lowtime1,
         lowtime2_preg = lowtime2,
         lowtime3_preg = lowtime3,
         lowdist1_preg = lowdist1,
         lowdist2_preg = lowdist2,
         lowdist3_preg = lowdist3,
         closest1_preg = closest1,
         closest2_preg = closest2,
         closest3_preg = closest3)

write_csv(final, "cty_preg_geodrive.csv") #CHANGE filename













###################################################################################




















