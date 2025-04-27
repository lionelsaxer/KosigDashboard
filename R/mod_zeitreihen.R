#' zeitreihen UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS
#' @importFrom magrittr %>%
mod_zeitreihen_ui <- function(id) {
  ns <- NS(id)

  quarter_range <- unique(zoo::as.yearqtr(.GlobalEnv$df_ct_base$Quarter))

  bslib::page_sidebar(
    sidebar = bslib::sidebar(
      shinyWidgets::sliderTextInput(
        inputId = ns("period_selector"), label = "Zeitspanne",
        choices = quarter_range, selected = c(quarter_range[1], quarter_range[4])
      ),
      shiny::selectizeInput(
        inputId = ns("question_selector"), label = "Frage",
        choices = .GlobalEnv$df_variable_mapping$Variable
      ),
      width = 400
    ),
    bslib::card(
      plotly::plotlyOutput(ns("plot_out"))
    )
  )
}

#' zeitreihen Server Functions
#'
#' @noRd
mod_zeitreihen_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    # Map question labels to variable name as reactive expression
    question <- reactive({
      .GlobalEnv$df_varmap$Variable[
        grep(input$question_selector, .GlobalEnv$df_varmap$Code, fixed = TRUE)
      ]
    })

    # Define reactive for time period
    period <- reactive(input$period_selector)

    # Plot
    output$plot_out <- plotly::renderPlotly({
      p <- .GlobalEnv$df_ct_base %>%
        dplyr::mutate(
          quarter_date = lubridate::yq(quarter)
        ) %>%
        dplyr::filter(quarter >= period()[1] & quarter <= period()[2]) %>%
        ggplot2::ggplot(
          ggplot2::aes(x = quarter_date, y = !!dplyr::sym(question()))
        ) +
        ggplot2::geom_line(color = "blue") +
        ggplot2::scale_x_date() +
        ggplot2::theme_minimal()

      plotly::ggplotly(p)
    })

  })
}

## To be copied in the UI
# mod_zeitreihen_ui("zeitreihen_1")

## To be copied in the server
# mod_zeitreihen_server("zeitreihen_1")
