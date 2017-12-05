#
# Wine Quality Shiny Application
#
# This is the user-interface definition of a Shiny web application.
# http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Wine Quality Prediction Model"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
       sliderInput("alcohol",             "Alcohol:",              min = 8, max = 14,  value = 11.5, step = 0.5, animate = T),
       sliderInput("volatile.acidity",    "Volatile Acidity:",     min = 0, max = 1.6, value = 0.3),
       sliderInput("free.sulfur.dioxide", "Free Sulphur Dioxide:", min = 1, max = 300, value = 30)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Help",                htmlOutput("help")),
        tabPanel("Alcohol",             plotOutput("alcohol")),
        tabPanel("Volatile Acidity",    plotOutput("volatile.acidity")),
        tabPanel("Free Sulfur Dioxide", plotOutput("free.sulfur.dioxide"))
      )
    )
  )
))
