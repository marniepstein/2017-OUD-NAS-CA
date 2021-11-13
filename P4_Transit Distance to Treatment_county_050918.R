######################################################
# Program: P4_Transit Distance to Treatment_county_050918
# Author: Marni Epstein
# Date: March 2021
# Description: This program returns the transit distance and time from county centroids to treatment, using the Google API
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
set.api.key("XXXXXXXXXXXXXXXXXXXXXXX") # Set API key.

setwd("D:/Users/MEpstein/Box Sync/2017 OUD NAS CHCF/3 Data/SAMHSA OTP provider locations/Created datafiles")

# Read in test file with counties and 10 closest lat/longs for treatment centers
data <- read_csv("cty_ip.csv") ## CHANGE file name

# Create empty variables to order the lat/longs by closest driving distance
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

small <- data %>%
  top_n(200)
  
###########################################
# Use gmaps distance to calculate distance and time from centroid to each of the 10 closest crow-flies lat/longs.
# Save distance and time in dist1-10 and time1-10
# Note: time is in seconds and distance is in meters.
###########################################


# Function to calculate diving distance between points
maptransit <- function(x, y) {
  gmapsdistance(origin = x,
                destination = y,
                mode = "transit",
                dep_date = "2018-06-6", 
                dep_time = "12:00:00")
}

geocodetransit <- function(latlong, timevar, distvar) eval.parent(substitute({

  results <- map2_df(data$centroid, latlong, ~maptransit(.x, .y))
  timevar <- results$Time
  distvar <- results$Distance
}))

geocodetransit(data$latlong1, data$time1, data$dist1)
geocodetransit(data$latlong2, data$time2, data$dist2)
geocodetransit(data$latlong3, data$time3, data$dist3)
geocodetransit(data$latlong4, data$time4, data$dist4)
geocodetransit(data$latlong5, data$time5, data$dist5)
geocodetransit(data$latlong6, data$time6, data$dist6)
geocodetransit(data$latlong7, data$time7, data$dist7)
geocodetransit(data$latlong8, data$time8, data$dist8)
geocodetransit(data$latlong9, data$time9, data$dist9)
geocodetransit(data$latlong10, data$time10, data$dist10)
geocodetransit(data$latlong11, data$time11, data$dist11)
geocodetransit(data$latlong12, data$time12, data$dist12)
geocodetransit(data$latlong13, data$time13, data$dist13)
geocodetransit(data$latlong14, data$time14, data$dist14)
geocodetransit(data$latlong15, data$time15, data$dist15)
geocodetransit(data$latlong16, data$time16, data$dist16)
geocodetransit(data$latlong17, data$time17, data$dist17)
geocodetransit(data$latlong18, data$time18, data$dist18)
geocodetransit(data$latlong19, data$time19, data$dist19)
geocodetransit(data$latlong20, data$time20, data$dist20)

## if time is missing, code it as 999999
data <- data %>%
  mutate(time1 = ifelse(is.na(time1), 999999, time1)) %>%
  mutate(time2 = ifelse(is.na(time2), 999999, time2)) %>%
  mutate(time3 = ifelse(is.na(time3), 999999, time3)) %>%
  mutate(time4 = ifelse(is.na(time4), 999999, time4)) %>%
  mutate(time5 = ifelse(is.na(time5), 999999, time5)) %>%
  mutate(time6 = ifelse(is.na(time6), 999999, time6)) %>%
  mutate(time7 = ifelse(is.na(time7), 999999, time7)) %>%
  mutate(time8 = ifelse(is.na(time8), 999999, time8)) %>%
  mutate(time9 = ifelse(is.na(time9), 999999, time9)) %>%
  mutate(time10 = ifelse(is.na(time10), 999999, time10)) %>%
  mutate(time11 = ifelse(is.na(time11), 999999, time11)) %>%
  mutate(time12 = ifelse(is.na(time12), 999999, time12)) %>%
  mutate(time13 = ifelse(is.na(time13), 999999, time13)) %>%
  mutate(time14 = ifelse(is.na(time14), 999999, time14)) %>%
  mutate(time15 = ifelse(is.na(time15), 999999, time15)) %>%
  mutate(time16 = ifelse(is.na(time16), 999999, time16)) %>%
  mutate(time17 = ifelse(is.na(time17), 999999, time17)) %>%
  mutate(time18 = ifelse(is.na(time18), 999999, time18)) %>%
  mutate(time19 = ifelse(is.na(time19), 999999, time19)) %>%
  mutate(time20 = ifelse(is.na(time20), 999999, time20)) 

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
                        ifelse(lowvar == data$time19, data$dist19, #0)))))))))))))))))))
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
                   ifelse(lowvar == data$time19, 19, #0)))))))))))))))))))
                   ifelse(lowvar == data$time20, 20, 0))))))))))))))))))))
}))

closest(data$closest1, data$lowtime1)
closest(data$closest2, data$lowtime2)
closest(data$closest3, data$lowtime3)

table(data$closest1)
table(data$closest2)
table(data$closest3)

### Save the latitude of the closest driving distances
closestlat <- function(newvar, lowvar) eval.parent(substitute({
  
  newvar <- ifelse(lowvar == data$time1, data$latitude1, 
                   ifelse(lowvar == data$time2, data$latitude2,
                   ifelse(lowvar == data$time3, data$latitude3,            
                   ifelse(lowvar == data$time4, data$latitude4, 
                   ifelse(lowvar == data$time5, data$latitude5, 
                   ifelse(lowvar == data$time6, data$latitude6, 
                   ifelse(lowvar == data$time7, data$latitude7, 
                   ifelse(lowvar == data$time8, data$latitude8, 
                   ifelse(lowvar == data$time9, data$latitude9, 
                   ifelse(lowvar == data$time10, data$latitude10,
                   ifelse(lowvar == data$time11, data$latitude11,
                   ifelse(lowvar == data$time12, data$latitude12,
                   ifelse(lowvar == data$time13, data$latitude13,
                   ifelse(lowvar == data$time14, data$latitude14,
                   ifelse(lowvar == data$time15, data$latitude15,
                   ifelse(lowvar == data$time16, data$latitude16,
                   ifelse(lowvar == data$time17, data$latitude17,
                   ifelse(lowvar == data$time18, data$latitude18,
                   ifelse(lowvar == data$time19, data$latitude19, # 0))))))))))))))))))) 
                   ifelse(lowvar == data$time20, data$latitude20, 0))))))))))))))))))))
}))

closestlat(data$closelat1, data$lowtime1)
closestlat(data$closelat2, data$lowtime2)
closestlat(data$closelat3, data$lowtime3)


### Save the longitude of the closest driving distances
closestlong <- function(newvar, lowvar) eval.parent(substitute({
  
  newvar <- ifelse(lowvar == data$time1, data$longitude1,
                   ifelse(lowvar == data$time2, data$longitude2,
                   ifelse(lowvar == data$time3, data$longitude3,                 
                   ifelse(lowvar == data$time4, data$longitude4, 
                   ifelse(lowvar == data$time5, data$longitude5, 
                   ifelse(lowvar == data$time6, data$longitude6, 
                   ifelse(lowvar == data$time7, data$longitude7, 
                   ifelse(lowvar == data$time8, data$longitude8, 
                   ifelse(lowvar == data$time9, data$longitude9, 
                   ifelse(lowvar == data$time10, data$longitude10, 
                   ifelse(lowvar == data$time11, data$longitude11, 
                   ifelse(lowvar == data$time12, data$longitude12,
                   ifelse(lowvar == data$time13, data$longitude13,
                   ifelse(lowvar == data$time14, data$longitude14,
                   ifelse(lowvar == data$time15, data$longitude15,
                   ifelse(lowvar == data$time16, data$longitude16,
                   ifelse(lowvar == data$time17, data$longitude17,
                   ifelse(lowvar == data$time18, data$longitude18,
                   ifelse(lowvar == data$time19, data$longitude19, # 0)))))))))))))))))))
                   ifelse(lowvar == data$time20, data$longitude20, 0))))))))))))))))))))
}))

closestlong(data$closelon1, data$lowtime1)
closestlong(data$closelon2, data$lowtime2)
closestlong(data$closelon3, data$lowtime3)



# Save a copy of the complete geocoded data for the 10 closest facilities
write_csv(data, "Top 10 distances geocded/cty_ip_complete_geotransit.csv") # CHANGE file name

#Keep only county and 3 closest time/distance variables
# rename new name = old name
# CHANGE names for each type of treatment location
final <- data %>%
  select(pcounty, 
         lowtime1_trans_ip = lowtime1,
         lowtime2_trans_ip = lowtime2,
         lowtime3_trans_ip = lowtime3,
         lowdist1_trans_ip = lowdist1,
         lowdist2_trans_ip = lowdist2,
         lowdist3_trans_ip = lowdist3,
         closest1_trans_ip = closest1,
         closest2_trans_ip = closest2,
         closest3_trans_ip = closest3,
         closelat1_trans_ip = closelat1,
         closelat2_trans_ip = closelat2,
         closelat3_trans_ip = closelat3,
         closelon1_trans_ip = closelon1,
         closelon2_trans_ip = closelon2,
         closelon3_trans_ip = closelon3)


write_csv(final, "cty_ip_geotransit.csv") #CHANGE filename













###################################################################################




















