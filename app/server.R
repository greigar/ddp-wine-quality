# Wine Quality Shiny Application
# This is the server logic of a Shiny web application.
#
# Data provided by
# https://www.kaggle.com/uciml/red-wine-quality-cortez-et-al-2009.
# More details are available at UCI Machine Learning Repository
# https://archive.ics.uci.edu/ml/datasets/wine+quality
#
# Citation : https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality.names
#
# This dataset is public available for research. The details are described in [Cortez et al., 2009].
# Please include this citation if you plan to use this database:
#
#   P. Cortez, A. Cerdeira, F. Almeida, T. Matos and J. Reis.
# Modeling wine preferences by data mining from physicochemical properties.
# In Decision Support Systems, Elsevier, 47(4):547-553. ISSN: 0167-9236.
#
# Available at: [@Elsevier] http://dx.doi.org/10.1016/j.dss.2009.05.016
# [Pre-press (pdf)] http://www3.dsi.uminho.pt/pcortez/winequality09.pdf
# [bib] http://www3.dsi.uminho.pt/pcortez/dss09.bib
#


library(shiny)      # For Shiny functions
library(tidyverse)  # For dplyr, readr and ggplot functions

#
# Column specification for reading in wine quality datasets
#
col_spec <- cols(
  `fixed acidity`        = col_double(),
  `volatile acidity`     = col_double(),
  `citric acid`          = col_double(),
  `residual sugar`       = col_number(),
  chlorides              = col_double(),
  `free sulfur dioxide`  = col_number(),
  `total sulfur dioxide` = col_double(),
  density                = col_double(),
  pH                     = col_number(),
  sulphates              = col_double(),
  alcohol                = col_number(),
  quality                = col_integer()
)

#
# Function for reading in either the red or white wine data sets
# note fields are delimited with a ';'
#
read_wq_csv <- function(wine_colour) {
  filename      <- paste0("data/winequality-", wine_colour, ".csv")
  w_data        <- read_delim(filename, col_types=col_spec, delim=';')
  w_data
}

# Read in data from CSV
white_wine_data  <- read_wq_csv("white")
red_wine_data    <- read_wq_csv("red")

# Combine the datasets together
wine_data        <- rbind(red_wine_data, white_wine_data)

# Fix the column names to be standard R ones
names(wine_data) <- make.names(names(wine_data))

# Create a linear regression model based on the top three predictors (see presentation documentation)
lm_model_3 <- lm(quality ~ alcohol + volatile.acidity + free.sulfur.dioxide, wine_data)

#
# Create a plot of one of the predictors against quality
#
# aes_string - documentation http://ggplot2.tidyverse.org/reference/aes_.html
#
create_plot <- function(v1, v2, v3, predicted_wine) {
  g <- ggplot(wine_data, aes_string(x = v1, y = "quality", colour = v2)) +
         ggtitle("Predicted Quality based on Alcohol, Volatile Acidity and Free Sulphur Dioxide",
                 paste("Showing linear regression by", v1, "- prediction shown as filled circle"))

  g <- g + geom_smooth(method = lm, formula = y ~ splines::ns(x, 5) )

  g <- g + geom_point(aes_string(x = v1, y = "quality", colour = v2, fill = v3),
                      stroke = 1, shape = 22, size = 1)

  g <- g + geom_point(data= predicted_wine,
                      aes_string(x = v1, y = "quality", colour = v2, fill = v3),
                      stroke = 3, shape = 21, size = 3, show.legend = FALSE)

  g <- g + scale_colour_gradientn(name = paste("Color:", v2), colours = terrain.colors(10)) +
              scale_fill_gradient(name = paste("FIll:",  v3), low = "white",  high = "black")

  g <- g + labs(y = "Quality", x  = v1)

  g <- g + theme(legend.position = "bottom",
                 strip.text.y    = element_blank(),
                 legend.title    = element_text(size = 10))
  g
}


help_text <- HTML("With this application you can explore the effect of three measured chemicals on the predicted quality of wine.
                  Adjust the sliders on the left hand side to explore their effect - you can also press the play button under the alcohol slider.
                  <br />
                  <br />
                  Click on the tabs to explore three plots showing a linear regression line for each chemical.")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  predict_result <- reactive({
    predicted_wine <- data.frame(alcohol             = c(input$alcohol),
                                 volatile.acidity    = c(input$volatile.acidity),
                                 free.sulfur.dioxide = c(input$free.sulfur.dioxide) )

    predicted_wine$quality <- round(predict(lm_model_3, newdata <- predicted_wine))
    predicted_wine
  })

  output$help               <- renderUI({ help_text })
  output$alcohol            <- renderPlot({ create_plot("alcohol",             "volatile.acidity",    "free.sulfur.dioxide", predict_result()) })
  output$volatile.acidity   <- renderPlot({ create_plot("volatile.acidity",    "free.sulfur.dioxide", "alcohol",             predict_result()) })
  output$free.sulfur.dioxide<- renderPlot({ create_plot("free.sulfur.dioxide", "alcohol",             "volatile.acidity",    predict_result()) })
})
