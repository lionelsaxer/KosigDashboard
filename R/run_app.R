#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @import RCurl
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {

  # If data file does not exist, download data via API and write data file
  if (!file.exists("data/snbkosiq.csv")) {

    localDataFile <- "data/snbkosiq.csv"
    link <- paste0(
      "https://data.snb.ch/api/cube/snbkosiq/data/csv/de?dimSel=D0(UVJQ,UVQ,",
      "KA,BS,EML,ML,NM,LS,PK,RS,LELJ,LEFJ,UERW,UEG,BERW,EPE,VPE,AI,BI,EPNV,",
      "IERWM,IERWJ)&fromDate=2024-Q1&toDate=2025-Q1"
    )
    download.file(link, method = "curl", destfile = localDataFile)

  }

  # Read data into global environment
  .GlobalEnv$df_ct_base <- readr::read_csv2("data/snbkosiq.csv", skip = 2)

  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}
