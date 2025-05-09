#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    # Leave this function for adding external resources
    # golem_add_external_resources(),
    # Your application UI logic
    bslib::page_navbar(
      theme = bslib::bs_theme(version = 5, bootswatch = "lux"),
      title = "KoSig Dashboard",

      bslib::navset_card_pill(
        bslib::nav_panel(
          title = "Zeitreihen",
          mod_zeitreihen_ui("zeitreihen")
        ),
        bslib::nav_panel(
          title = "Hilfe",
          mod_help_ui("help")
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "KosigDashboard"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
