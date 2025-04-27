#' zeitreihen UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS
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

  })
}

## To be copied in the UI
# mod_zeitreihen_ui("zeitreihen_1")

## To be copied in the server
# mod_zeitreihen_server("zeitreihen_1")
