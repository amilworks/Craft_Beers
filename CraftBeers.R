#Importing craft beers dataframe from Kaggle
beers <- read.csv("C://Users/bdaet/Downloads/beers.csv")

#Since I plan on comparing the beers IBU (bitterness rating) to their ABV (alcohol content) I need to create
## a subset that only contains beers with a listed IBU rating
beers_ibu <- beers[is.na(beers$ibu) == FALSE,]

#Importing ggplot2 library to create visual representations of the data
library(ggplot2)
library(plotly)

#Scatterplot comparing IBU and ABV
p1 <- ggplot(beers_ibu, aes(x = ibu, y = abv)) +
        geom_point() +
        geom_smooth(method = "loess") +
        xlab("IBU (Bitterness Rating)") +
        ylab("ABV") +
        ggtitle("Correlation Between IBU and ABV in Craft Beers")
p1
ggplotly(p1)

#after using the summary function to look at the style column the most common styles of beer (>50 cases)
# are "American IPA", "American Pale Ale (APA)", "American Amber / Red Ale", "American Double / Imperial IPA", 
#"American Pale Wheat Ale", "American Blonde Ale"

#importing the plyr library to use the count function 
library(plyr)

#finding the different styles of beer that appear more than 50 times in the dataframe
ct <- count(beers_ibu$style)
pop <- ct[ct$freq > 50,]

#creating a subset of the data frame containing only the styles of beer that appeared more than 50 times
#I'm sure there is a more efficient way to create this subset but for now this is the method I'm using
beers_pop <- beers_ibu[beers_ibu$style == pop$x[1] | beers_ibu$style == pop$x[2] | beers_ibu$style == pop$x[3] |
                         beers_ibu$style == pop$x[4] | beers_ibu$style == pop$x[5] | beers_ibu$style == pop$x[6] ,]

#quick histogram plot of the 6 most frequently occuring beer styles from the dataset (only including the beers with
# ibu information given)
mf <- ggplot(beers_pop, aes(x = style, col = style)) +
        geom_bar() +
        xlab("Style of Beer") +
        ggtitle("Most Common Styles of Beer from the List") +
        theme(axis.text.x = element_text(angle = 15), legend.position = "none")
mf

#creating a scatterplot comparing ibu and abv using only the data on the 6 most common beer styles
sp <- ggplot(beers_pop, aes(x = ibu, y = abv, col = style)) +
        geom_point() +
        xlab("IBU") +
        ylab("ABV")
sp
ggplotly(sp)

#creating a grid with individual scatterplots for each of the 6 most common beer styles to reduce clutter
gd <- ggplot(beers_pop, aes(x = ibu, y = abv, col = style)) +
        geom_point() +
        facet_grid(. ~ style) +
        theme(legend.position = "none") +
        xlab("IBU") +
        ylab("ABV")
gd
ggplotly(gd)













