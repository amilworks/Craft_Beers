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
                              Average_ABV = round(mean(abv, na.rm = TRUE) * 100, digits = 2))

#average of the Average_ABV column
ave <- round(mean(extraFeatures$Average_ABV, na.rm = TRUE), digits = 2)

#filling missing values for the Average_ABV column
extraFeatures$Average_ABV[is.na(extraFeatures$Average_ABV)] <- ave


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
                            '</br> Average ABV: ', Average_ABV,
                            '</br> City: ', city)) %>%
              add_markers() %>%
              layout(title = "Map of Breweries in the United States", geo = g)
brewMap

#writing a function to display selected styles of beer on a US map
beerMap <- function(x, clr = "orange2") {
            temp <- filter(beersLoc, style == x)
            temp$abv <- round(temp$abv * 100, digits = 2)
            plt <- plot_geo(temp, lat = ~lat, lon = ~lon,
                     alpha = 0.75,
                     color = ~abv,
                     colors = clr,
                     marker = list(size = 15),
                     text = ~paste('Name: ', name,
                                   '</br> Brewery: ', Brewery,
                                   '</br> ABV: ', abv,
                                   '</br> City: ', city)) %>%
                        
                     add_markers() %>%
                     layout(title = paste('Locations with', x), geo = g)
            plt
            
}

#looking at most common beers to map
beersLoc %>%
  group_by(style) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

beerMap("American IPA", clr = "Blues")
beerMap("American Pale Ale (APA)", clr = "Greens")
beerMap("American Amber / Red Ale", clr = "Reds")
beerMap("American Blonde Ale", clr = c("yellow1", "yellow2", "yellow3", "yellow4"))
beerMap("American Double / Imperial IPA", clr = "Purples")
beerMap("American Pale Wheat Ale", clr = c("wheat1", "wheat2", "wheat3", "wheat4"))
beerMap("American Brown Ale", clr = c("tan1", "tan2", "chocolate3", "chocolate4"))


#filtering only beers that have IBU information
ibu <- filter(beersLoc, !is.na(ibu))

#converting abv to a percentage rather than a decimal
ibu$abv = round(ibu$abv * 100, digits = 2)

byStyle <- function(x, clr = "orange2") {
           temp <- filter(ibu, style == x)
           sct <- ggplot(temp, aes(x = ibu, y = abv)) +
                      geom_point(alpha = 0.65, color = clr, size = 3) +
                      theme_minimal() +
                      xlab("IBU (Bitterness Rating") +
                      ylab("ABV (Alcohol Content") +
                      ggtitle("Comparing IBU and ABV")
           ggplotly(sct)
}

byStyle("American IPA", clr = "steelblue3")

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

#looking at which states produce the most beers
byState <- beersLoc %>%
           group_by(state) %>%
           summarise(Beers_Produced = n(),
                     Average_ABV = round(mean(abv, na.rm = TRUE) * 100, digits = 2),
                     Average_IBU = round(mean(ibu, na.rm = TRUE), digits = 2)) %>%
           arrange(desc(Beers_Produced))

#taking the top 8 states that produce the most beer
top8 <- byState[1:8, ]
top8$state <- ordered(top8$state, levels = top8$state)

top8states <- ggplot(top8, aes(x = state, y = Beers_Produced)) +
              geom_bar(stat = "identity", alpha = 0.50, fill = "orange2") +
              theme_minimal() +
              xlab("State") +
              ylab("Beers Produced") +
              coord_flip() +
              ggtitle("Beers Produced by State")
states <- ggplotly(top8states)
states



