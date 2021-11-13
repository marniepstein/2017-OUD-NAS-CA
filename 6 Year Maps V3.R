######################################################
# Program: 6 Year Maps v3
# Author: Marni Epstein
# Date: March 2021
# Description: This program creates maps by California counties for a number of different measures related to NAS
######################################################


library(rgeos)
library(rgdal)
library(tidyverse)
library(ggmap)
library(maps)
library(mapdata)
library(Hmisc)
library(geofacet)
library(maptool)s
library("ggrepel")

library("stringr")
library("RColorBrewer")
library("grid")
library("gridExtra")
library("mapproj")
library(sp)
library(USAboundaries)
library(extrafont)
library(extrafontdb)
library(plyr)
library(Cairo)

Sys.setenv(R_GSCMD="C:/Program Files (x86)/gs/gs9.22/bin/gswin32c.exe")
source('https://raw.githubusercontent.com/UrbanInstitute/urban_R_theme/master/urban_theme_windows.R')


###########################################
# Read in CA County OUD data
###########################################
data <- read_csv("D:/Users/MEpstein/Box Sync/2017 OUD NAS CHCF/3 Data/CA OSHPD/2 Data and official docs/Created data files/ca_cty.csv")

#########################################
# Add in NAS rates 
#########################################  
data <- data %>%
  #Rate per 1000 births
  mutate(a_brthrt = nas_a / births * 1000) %>%
  mutate(b_brthrt = nas_b / births * 1000) %>%
  mutate(ab_brthrt = nas_ab / births * 1000) %>%
  mutate(a_brt_brthrt = nas_a_brt / births * 1000) %>%
  mutate(b_brt_brthrt = nas_b_brt / births * 1000) %>%
  mutate(ab_brt_brthrt = nas_ab_brt / births * 1000) %>%
  #rate per 1000 newborns
  mutate(a_newbrnrt = nas_a / newborns * 1000) %>%
  mutate(b_newbrnrt = nas_b / newborns * 1000) %>%
  mutate(ab_newbrnrt = nas_ab / newborns * 1000) %>%
  mutate(a_brt_newbrnrt = nas_a_brt / newborns * 1000) %>%
  mutate(b_brt_newbrnrt = nas_b_brt / newborns * 1000) %>%
  mutate(ab_brt_newbrnrt = nas_ab_brt / newborns * 1000) %>%
  #Rate per 1000 women 15-44
  mutate(drug_ed_rt = drug_ed / pop * 1000) %>%
  mutate(drug_ip_rt = drug_ip / pop * 1000) %>%
  #Maternal drug dependency per birth
  mutate(drugdep_rt = drugdep / births * 1000)
  



##########################################
# CA base map
# Following the "Mapping Individual States" section from https://ui-research.github.io/r-at-urban/mapping.html#mapping_individual_states 
##########################################
## Pull in California county map data
ca_county <- map_data("county") %>%
  filter(region == "california")

# pick the state plan coordinate system for California
projection <- state_plane("CA", plane_id = NULL, type = "epsg")

# turn long and lat into spatial coordinates
coordinates(ca_county) <- ~ long + lat

# convert projection to 
# http://spatialreference.org/ref/epsg/wgs-84/
proj4string(ca_county) <- CRS("+init=epsg:4326")

# convert coordinates to the state plane coordinate system for Caliornia
#state <- spTransform(ca_county, CRS(paste0("+init=epsg:", projection)))

# convert spatial points data frame into a tibble
ca_county <- as_tibble(ca_county)

# Map theme
theme_map <- theme(
  axis.text = element_blank(),
  axis.ticks = element_blank(),
  axis.title = element_blank(),
  panel.grid = element_blank(),
  axis.line = element_blank()
)

#blue scale for shading bins
myColors <- c('#cfe8f3', '#73bfe2', '#1696d2','#12719e', '#062635')


## Plot just CA outline, filled in grey
ca_base <- ggplot(data = ca_county, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.2) + 
  geom_polygon(color = "black", fill = 'white') + # black outline of state
  geom_polygon(data = ca_county, color = 'white', fill = '#d2d2d2') + # color is outline, fill is county color
  theme() +
  theme_map
ca_base

##############################################
# Format opioid data to merge with county map data
##############################################


## Rename the county variable in the opioid data to subregion and convert to all lowercase in order to merge wtih CA map data
data$subregion <- tolower(data$pcounty)

table(data$nas_a)

data_6yr <- subset(data, mappingdt$period == "2011-2016")
  
## Merge the opioid data frame and the CA county outline maping data frame
mappingdt <- left_join(ca_county, data, by = "subregion")

map_6yr <- subset(mappingdt, mappingdt$period == "2011-2016")

#Keep just county and death rate, so that we can use na.omit and not omit counties with missing values in other variables 
#nasa_map <- select(map_6yr, nas_a, subregion, nas_a, lat, long, group)



#######################################################################
########              6 Year Maps                   ##################
#######################################################################

setwd("D:/Users/MEpstein/Box Sync/2017 OUD NAS CHCF/4 NAS hotspots/6 year maps/Rates")


mapnas <- function(varname, titlelab){
  
  varname <- enquo(varname)
  
  plot <- ca_base + 
    geom_polygon(data = map_6yr, aes_string(fill = quo_name(varname))) + # black borders between counties
    geom_polygon(color = "white", fill = NA) + #white borders
    scale_fill_gradientn(name = "Rate",  
                         colours = c("#cfe8f3", "#73bfe2", "#1696d2", "#0a4c6a", "#000000"),
                         #breaks = c(0, 250, 500, 750, 1000),
                         #labels = c("0", "250", "500", "750", "1000"),
                         #limits = c(0,1000),
                         guide = "colorbar") + #use legend for discrete boxes
    labs(title = titlelab) +
    theme_map +
    theme(legend.position = c(0.8, 0.8), #left/right, up/down
          legend.background = element_rect(linetype = "solid"),
          legend.direction='vertical',
          legend.key.size = unit(.7, "cm"),
          legend.margin = margin(t = .2, b = .2, l = .2, r = .2, unit = "cm"),
          legend.title = element_text(),
          plot.title = element_text(hjust = 0, size=16))
  
  plot
  ggsave(plot, filename = paste(quo_name(varname), ".png"))
  
}

# NAS Rates per 1000 births
mapnas(a_brthrt, "NAS_A per 1,000 Births (ICD 779.5 or P961)")
mapnas(b_brthrt, "NAS_B per 1,000 Births (ICD 760.72 or P04.49)")
mapnas(ab_brthrt, "NAS_AB per 1,000 Births (nas_a or nas_b)")
mapnas(a_brt_brthrt, "NAS_A_BRT per 1,000 Births (nas_a incidence at delivery only)")
mapnas(b_brt_brthrt, "NAS_B_BRT per 1,000 Births (nas_b incidence at delivery only)")
mapnas(ab_brt_brthrt, "NAS_AB_BRT per 1,000 Births \n(nas_a or nas_b incidence at delivery only)")

#NAS Rates per 1000 Newborns
mapnas(a_newbrnrt, "NAS_A per 1,000 Newborns (ICD 779.5 or P961)")
mapnas(b_newbrnrt, "NAS_B per 1,000 Newborns (ICD 760.72 or P04.49)")
mapnas(ab_newbrnrt, "NAS_AB per 1,000 Newborns (nas_a or nas_b)")
mapnas(a_brt_newbrnrt, "NAS_A_BRT per 1,000 Newborns (nas_a incidence at delivery only)")
mapnas(b_brt_newbrnrt, "NAS_B_BRT per 1,000 Newborns (nas_b incidence at delivery only)")
mapnas(ab_brt_newbrnrt, "NAS_AB_BRT per 1,000 Newborns \n(nas_a or nas_b incidence at delivery only)")

#Maternal drug dependnce rates per 1000 women 15-44
mapnas(drug_ed_rt, "ER Visits due to OUD Overdose, per 1000 Women 15-44")
mapnas(drug_ip_rt, "Inpatient Hospitalizations due to OUD Overdose, per 1000 Women 15-44")
mapnas(drugdep_rt, "Maternal Drug Dependency Incidence, per 1000 Births")






