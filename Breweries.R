#importing breweries dataset from kaggle
breweries <- read.csv("C://Users/bdaet/Downloads/breweries.csv")

#importing the dplyr library to aggregate data
library(dplyr)
library(ggplot2) #importing ggplot2 and ggmap libraries for geographical visualizations
library(ggmap)

#creating a brewery_id column to more easily merge the breweries dataframe with the craft beers dataframe later on
breweries$brewery_id <- breweries$X
breweries <- select(breweries, -X)

summary(breweries)


#getting the longitude and latitude for all the cities in the dataframe
breweries$city <- as.character(breweries$city)   #to use the geocode command the input must be a character
lonlat <- geocode(breweries$city)

#adding the longitude and latitude info to the dataframe
breweries <- data.frame(breweries, lonlat) 


US <- get_map(location = "United States", zoom = 4, scale = 1)
map <- ggmap(US, base_layer = ggplot(breweries, aes(lon, lat))) +
          geom_point(color = "red")
map

