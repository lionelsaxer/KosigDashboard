#' help UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_help_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("links"))
}

#' help Server Functions
#'
#' @noRd
mod_help_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    output$links <- renderUI({
      shiny::tagList(
        tags$h4("Hier ein paar nützliche Links, falls du Hilfe benötigst:"),
        tags$ul(
          tags$li(tags$a(
            href = "https://mastering-shiny.org/", target = "_blank",
            "Mastering Shiny"
          )),
          tags$li(tags$a(
            href = "https://r4ds.hadley.nz/", target = "_blank",
            "R for Data Science"
          )),
          tags$li(tags$a(
            href = "https://engineering-shiny.org/index.html", target = "_blank",
            "Engineering Production-Grade Shiny Apps"
          )),
          tags$li(tags$a(
            href = "https://adv-r.hadley.nz/", target = "_blank", "Advanced R"
          ))
        )
      )
    })

  })
}

## To be copied in the UI
# mod_help_ui("help_1")

## To be copied in the server
# mod_help_server("help_1")
