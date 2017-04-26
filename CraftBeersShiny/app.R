#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
        dashboardHeader(
          title = "Craft Beers"
        ),
        
        
      #sidebar content
      dashboardSidebar(
        sidebarMenu(
          menuItem("Brewery Map", tabName = "brew", icon = icon("dashboard")),
          menuItem("Beer Locations", tabName= "beerfinder", icon = icon("th"))
        )
      ),
      
      #body content
      dashboardBody(
        tabItems(
          tabItem(tabName = "brew",
                  fluidRow(
                    box(plotlyOutput("brewerymap", height = 625), width = 8, height = 650),
                    box(plotlyOutput("state", height = 625), width = 4, height = 650)
                  )
          ),
          
          tabItem(tabName = "beerfinder",
                  fluidRow(
                    box(plotlyOutput("beermp", height = 625), width = 8, height = 650),
                    box(plotlyOutput("scatter", height = 475), width = 4, height = 500),
                    box(selectInput("choice", 
                                    label = "Choose from styles of beer", 
                                    choices = list("American IPA", 
                                                   "American Pale Ale (APA)",
                                                   "American Amber / Red Ale", 
                                                   "American Blonde Ale",
                                                   "American Double / Imperial IPA",
                                                   "American Pale Wheat Ale",
                                                   "American Brown Ale"), 
                                    selected = "American IPA"), width = 4)
                  ),
                  fluidRow(
                    box(title = "Getting the Most Out of These Visuals",
                        "Select a style of beer from the dropdown menu to view the locations of breweries that
                        produce that style of beer.  Both the map and the scatterplot comparing the IBU and
                        ABV rating for the selected style are fully interactive.  You can zoom in or out and 
                        hover over any of the points to get more information.", width = 12)
                  )
            )
          )
                
        )
      )
      
  
  
  
  
  
  
  


server <- function(input, output) {
  output$brewerymap <- renderPlotly({
    brewMap
  })
  
  output$state <- renderPlotly({
    states
  })
  
  output$beermp <- renderPlotly({
    choices <- switch(input$choice,
                      "American IPA" = beerMap("American IPA", clr = "Blues"), 
                      "American Pale Ale (APA)" = beerMap("American Pale Ale (APA)", clr = "Greens"),
                      "American Amber / Red Ale" = beerMap("American Amber / Red Ale", clr = "Reds"), 
                      "American Blonde Ale" = beerMap("American Blonde Ale", clr = 
                                                        c("lightgoldenrod1", "lightgoldenrod2", 
                                                          "lightgoldenrod3", "lightgoldenrod4")),
                      "American Double / Imperial IPA" = beerMap("American Double / Imperial IPA", clr = "Purples"),
                      "American Pale Wheat Ale" = beerMap("American Pale Wheat Ale", clr = 
                                                            c("wheat1", "wheat2", "wheat3", "wheat4")),
                      "American Brown Ale" = beerMap("American Brown Ale", clr = 
                                                       c("tan1", "tan2", "chocolate3", "chocolate4")))
  })
  
  output$scatter <- renderPlotly({
    choices <- switch(input$choice,
                      "American IPA" = byStyle("American IPA", clr = "steelblue3"),
                      "American Pale Ale (APA)" = byStyle("American Pale Ale (APA)", clr = "springgreen4"),
                      "American Amber / Red Ale" = byStyle("American Amber / Red Ale", clr = "red3"),
                      "American Blonde Ale" = byStyle("American Blonde Ale", clr = "lightgoldenrod3"),
                      "American Double / Imperial IPA" = byStyle("American Double / Imperial IPA",
                                                                 clr = "purple4"),
                      "American Pale Wheat Ale" = byStyle("American Pale Wheat Ale", clr = "sienna2"),
                      "American Brown Ale" = byStyle("American Brown Ale", clr = "chocolate3")
    )
  })
}

shinyApp(ui, server)
