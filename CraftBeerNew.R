library(plyr)
library(dplyr)
library(ggplot2)
library(plotly)

#importing data sets
breweries <- read.csv("C://Users/bdaet/Desktop/myProjects/Craft Beer CSV Files/breweries2.csv")
beers <- read.csv("C://Users/bdaet/Desktop/myProjects/Craft Beer CSV Files/beers.csv")

#preparing breweries data set to join with beers data set
breweries <- mutate(breweries, Brewery = name)
breweries <- select(breweries, -X, -name)

#joining beers and breweries data sets
beersLoc <- join(beers, breweries, by = "brewery_id", type = "left")

#creating extra features for the brewery map
extraFeatures <- beersLoc %>%
                    group_by(Brewery) %>%
                    summarise(Beers_Produced = n(),
                              Average_ABV = round(sum(abv, na.rm = TRUE) / n() * 100, digits = 2))

#adding the extra features to the breweries data set
breweries <- join(breweries, extraFeatures, by = "Brewery", type = "left")

#creating U.S. map for geo plot
g <- list(
  scope = "usa",
  projection = list(type = "albers usa"),
  showland = TRUE,
  landcolor = toRGB("lightskyblue1", alpha = 0.35),
  subunitcolor = toRGB("lightskyblue3"),
  countrycolor = toRGB("grey85"),
  countrywidth = 0.5,
  subunitwidth = 0.5
)

#plotting all breweries on a U.s. map, scaling size to number of beers produced and color to Avg. ABV
brewMap <- plot_geo(breweries, lat = ~lat, lon = ~lon, 
              color = ~Average_ABV, 
              colors = "YlOrRd", 
              size = ~Beers_Produced,
              sizes = c(50, 500),
              alpha = 0.75,
              text = ~paste('Brewery: ', Brewery,
                            '</br> Number of Beers Produced: ', Beers_Produced,
                            '</br> Average ABV: ', Average_ABV)) %>%
              add_markers() %>%
              layout(title = "Map of Breweries in the United States", geo = g)
brewMap

#filtering only beers that have IBU information
ibu <- filter(beersLoc, !is.na(ibu))

#converting abv to a percentage rather than a decimal
ibu$abv = round(ibu$abv * 100, digits = 2)

#creating a scatter plot comparing ibu and abv, size scales to size of beer in ounces
abv_ibu <- ggplot(ibu, aes(x = ibu, y = abv, size = ounces)) +
           geom_point(alpha = 0.65, color = "lightskyblue2") +
           scale_size_continuous(range = c(1, 4)) +
           theme_minimal() +
           xlab("IBU (Bitterness Rating)") +
           ylab("ABV (Alcohol Content)") +
           ggtitle("Correlation Between IBU and ABV in Beer") +
           geom_smooth(method = "loess", col = "darkorange1", fill = "orange2")
            #loess method is local polynomial regression fitting
scatter <- ggplotly(abv_ibu)
scatter

