library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(randomForest)

# Load Dataset
netflix <- read.csv(
  "netflix_titles.csv",
  stringsAsFactors = FALSE
)

# Fill missing ratings
netflix$rating[is.na(netflix$rating)] <- "Unknown"

# Prepare model data
model_data <- netflix[, c("type", "release_year", "rating")]
model_data <- na.omit(model_data)

model_data$type <- as.factor(model_data$type)
model_data$rating <- as.factor(model_data$rating)

# Train Random Forest model
set.seed(123)

model <- randomForest(
  type ~ release_year + rating,
  data = model_data
)

# Recommendation function
recommend_content <- function(title_name) {

  idx <- which(netflix$title == title_name)

  if (length(idx) == 0) {
    return("Title not found")
  }

  same_type <- netflix[
    netflix$type == netflix$type[idx],
  ]

  sample(
    same_type$title,
    min(5, nrow(same_type))
  )
}

# UI
ui <- dashboardPage(

  dashboardHeader(
    title = "Netflix Dashboard"
  ),

  dashboardSidebar(
    sidebarMenu(

      menuItem(
        "Overview",
        tabName = "overview"
      ),

      menuItem(
        "Analytics",
        tabName = "analytics"
      ),

      menuItem(
        "AI Prediction",
        tabName = "prediction"
      ),

      menuItem(
        "Recommendation",
        tabName = "recommendation"
      )
    )
  ),

  dashboardBody(

    tabItems(

      # Overview Page
      tabItem(
        tabName = "overview",

        fluidRow(

          valueBox(
            value = nrow(netflix),
            subtitle = "Total Content"
          ),

          valueBox(
            value = sum(netflix$type == "Movie"),
            subtitle = "Movies"
          ),

          valueBox(
            value = sum(netflix$type == "TV Show"),
            subtitle = "TV Shows"
          )
        )
      ),

      # Analytics Page
      tabItem(
        tabName = "analytics",

        fluidRow(

          box(
            width = 6,
            plotlyOutput("typePlot")
          ),

          box(
            width = 6,
            plotlyOutput("yearPlot")
          )
        ),

        fluidRow(

          box(
            width = 12,
            dataTableOutput("table")
          )
        )
      ),

      # Prediction Page
      tabItem(
        tabName = "prediction",

        fluidRow(

          box(
            width = 6,

            numericInput(
              "year_input",
              "Release Year",
              value = 2020
            ),

            selectInput(
              "rating_input",
              "Rating",
              choices = unique(netflix$rating)
            ),

            actionButton(
              "predict_btn",
              "Predict"
            )
          ),

          box(
            width = 6,
            textOutput("prediction_output")
          )
        )
      ),

      # Recommendation Page
      tabItem(
        tabName = "recommendation",

        fluidRow(

          box(
            width = 6,

            selectInput(
              "title_input",
              "Select Title",
              choices = netflix$title
            ),

            actionButton(
              "recommend_btn",
              "Recommend"
            )
          ),

          box(
            width = 6,
            verbatimTextOutput("recommend_output")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output) {

  output$typePlot <- renderPlotly({

    type_count <- as.data.frame(
      table(netflix$type)
    )

    plot_ly(
      data = type_count,
      x = ~Var1,
      y = ~Freq,
      type = "bar"
    )
  })

  output$yearPlot <- renderPlotly({

    year_count <- as.data.frame(
      table(netflix$release_year)
    )

    plot_ly(
      data = year_count,
      x = ~Var1,
      y = ~Freq,
      type = "scatter",
      mode = "lines"
    )
  })

  output$table <- renderDataTable({
    datatable(netflix)
  })

  observeEvent(input$predict_btn, {

    new_data <- data.frame(
      release_year = input$year_input,
      rating = factor(
        input$rating_input,
        levels = levels(model_data$rating)
      )
    )

    pred <- predict(
      model,
      newdata = new_data
    )

    output$prediction_output <- renderText({
      paste("Prediction:", pred)
    })

  })

  observeEvent(input$recommend_btn, {

    rec <- recommend_content(
      input$title_input
    )

    output$recommend_output <- renderPrint({
      rec
    })

  })

}

shinyApp(
  ui = ui,
  server = server
)
