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
        choices = quarter_range,
        selected = c(quarter_range[1], quarter_range[length(quarter_range)])
      ),
      shiny::selectizeInput(
        inputId = ns("question_selector"), label = "Frage",
        choices = .GlobalEnv$df_varmap$Variable
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
      .GlobalEnv$df_varmap$Code[
        grep(input$question_selector, .GlobalEnv$df_varmap$Variable, fixed = TRUE)
      ]
    })

    # Define reactive for time period
    period <- reactive(input$period_selector)

    # Plot
    output$plot_out <- plotly::renderPlotly({

      # Define base plot
      p <- .GlobalEnv$df_ct_base %>%
        dplyr::mutate(
          Quarter_date = lubridate::yq(Quarter)
        ) %>%
        dplyr::filter(Quarter >= period()[1] & Quarter <= period()[2]) %>%
        ggplot2::ggplot(
          ggplot2::aes(x = Quarter, y = !!dplyr::sym(question()))
        ) +
        ggplot2::geom_line(color = "blue", linewidth = .75) +
        ggplot2::geom_hline(yintercept = 0, linetype = "dashed") +
        zoo::scale_x_yearqtr(format = "%Y Q%q") +
        ggplot2::theme_minimal()

      # If it is a likert variable we plot
      if (!question() %in% c("LELJ", "LEFJ", "EPNV", "IERWM", "IERWJ")) {
        p_out <- p +
          ggplot2::scale_y_continuous(limits = c(-1.5, 1.5)) +
          ggplot2::labs(x = "", y = "")

      } else if (question() == "IERWM") {
        p_out <- p +
          ggplot2::scale_y_continuous(limits = c(-2, 4)) +
          ggplot2::labs(x = "", y = "%")

      } else {
        p_out <- p +
          ggplot2::scale_y_continuous(limits = c(-1.5, 3)) +
          ggplot2::labs(x = "", y = "%")
      }

      plotly::ggplotly(p_out)

    })

  })
}

## To be copied in the UI
# mod_zeitreihen_ui("zeitreihen_1")

## To be copied in the server
# mod_zeitreihen_server("zeitreihen_1")
