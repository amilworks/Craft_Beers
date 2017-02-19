#importing necessary libraries
library(dplyr)
library(ggplot2)
library(ggmap)

#importing the breweries and popular beers dataframes that I modified
breweries2 <- read.csv("C://Users/bdaet/Desktop/myProjects/breweries2.csv")
beers_pop <- read.csv("C://Users/bdaet/Desktop/myProjects/popularbeers.csv")

#since I plan to merge the two dataframes and beers_pop already has a "name" column I need to change the names
#column in breweries2 to "brewery" instand
breweries2 <- breweries2 %>%
                  mutate(brewery = name) %>%
                  select(-name, -X)

#merging the dataframes keeping only the breweries that brew at least one of the 6 most common styles of beer
complete <- join(x = beers_pop, y = breweries2,
                  by = "brewery_id", type = "left")

#removing unneccesary columns
complete <- select(complete, -X.1, -X)

#writing a csv file of the new datframe for future use
write.csv(complete, file = "beers&breweries.csv")


#first lets look at which states brew the most beers from our 6 most common styles
by_state <- complete %>%
              group_by(state) %>%
              summarise(avg_ibu = round(mean(ibu), digits = 2),
                        avg_abv = round(mean(abv) * 100, digits = 2),
                        count = n()) %>%
              arrange(desc(count))
head(by_state, n = 20)
                     

#California has produced the most beers from our most popular beers list (78) followed by Colorado (75), 
# Oregon (61), Texas(40), Indiana(36) and Washington (30)

#creating a subset of the dataframe with only the states that produce more than 30 of these beers
top6 <- filter(by_state, count >= 30)
top6$state <- ordered(top6$state, levels = c(" CA", " CO", " OR", " TX", " IN", " WA"))

#creating a bar plot of the number of beers each of these states produced
top6bar <- ggplot(top6, aes(x = state, y = count, col = state)) +
                geom_bar(stat = "identity", alpha = 0.65) +
                xlab("State") +
                ylab("Beers Produced") +
                theme_minimal() +
                theme(legend.position = "none")
ggplotly(top6bar)

#creating a dataframe grouped by both state and style to show how many beers of each of the 6 styles each state
#  produces
by_style <- complete %>%
              filter(state %in% c(" CA", " CO", " OR", " TX", " IN", " WA")) %>%
              group_by(state, style) %>%
              summarise(avg_ibu = round(mean(ibu), digits = 2),
                        avg_abv = round(mean(abv) * 100, digits = 2),
                        count = n()) 

#creating bar plots showing how many beers each state produces of all 6 styles
by_style_bar <- ggplot(by_style, aes(x = state, y = count, fill = style)) +
                    geom_bar(stat = "identity", alpha = 0.65) +
                    facet_wrap(~ style, nrow = 2) +
                    xlab("State") +
                    ylab("Beers Produced") +
                    theme_bw() +
                    theme(legend.position = "none")
ggplotly(by_style_bar)



