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
#' @importFrom magrittr %>%
run_app <- function(
  onStart = NULL,
  options = list(),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {

  # Get current quarter
  .GlobalEnv$curr_quarter <- zoo::as.yearqtr(Sys.Date())

  # Compute previous quarter
  .GlobalEnv$prev_quarter <- curr_quarter - .25

  # Convert previous quarter to character with "-"
  .GlobalEnv$prev_quarter_char <-
    stringr::str_replace(as.character(prev_quarter), " ", "-")

  # Define variables for API query
  .GlobalEnv$path_snbkosiq <- paste0(here::here(), "/data/snbkosiq.csv")
  .GlobalEnv$link_root <- paste0(
    "https://data.snb.ch/api/cube/snbkosiq/data/csv/de?dimSel=D0(UVJQ,UVQ,",
    "KA,BS,EML,ML,NM,LS,PK,RS,LELJ,LEFJ,UERW,UEG,BERW,EPE,VPE,AI,BI,EPNV,",
    "IERWM,IERWJ)"
  )

  # If data file does not exist, download data via API and write data file
  if (!file.exists(path_snbkosiq)) {
    link_full <- paste0(
      link_root, "&fromDate=2011-Q1&toDate=", prev_quarter_char
    )
    download.file(link_full, method = "curl", destfile = path_snbkosiq)

    # Fix file
    .GlobalEnv$df_ct_raw <- readr::read_csv2(
      path_snbkosiq, skip = 2, show_col_types = FALSE
    )
    readr::write_csv2(df_ct_raw, path_snbkosiq)
  }

  # Read raw data into global environment
  .GlobalEnv$df_ct_raw <- readr::read_csv2(
    path_snbkosiq, show_col_types = FALSE
  )

  # Get most recent quarter of data file
  .GlobalEnv$max_quarter_raw <- df_ct_raw$Date %>%
    stringr::str_remove("-") %>%
    zoo::as.yearqtr() %>%
    max()

  # Compute subsequent quarter of most recent quarter of data file
  .GlobalEnv$max_quarter_raw_next <- max_quarter_raw + .25
  .GlobalEnv$max_quarter_raw_next_char <-
    stringr::str_replace(as.character(max_quarter_raw_next), " ", "-")

  # If the previous quarter exceeds the most recent quarter in the raw data file
  # kosiq.csv, we download the most recently available data (previous quarter),
  # join it with the historic file and write it to disk
  if (prev_quarter > max_quarter_raw) {
    link_missing <- paste0(
      link_root, "&fromDate=", max_quarter_raw_next_char, "&toDate=",
      prev_quarter_char
    )
    .GlobalEnv$df_ct_raw_missing <- readr::read_csv2(
      link_missing, skip = 2, show_col_types = FALSE
    )
    .GlobalEnv$df_ct_raw <- df_ct_raw %>%
      dplyr::bind_rows(df_ct_raw_missing)
    readr::write_csv2(df_ct_raw, path_snbkosiq)
  }

  # Get variable mapping
  .GlobalEnv$df_varmap <- readr::read_csv(
    paste0(here::here(), "/mappings/variable_mapping.csv"),
    show_col_types = FALSE
  )

  # Clean raw data
  .GlobalEnv$df_ct_base <- df_ct_raw %>%
    tidyr::pivot_wider(id_cols = Date, names_from = D0, values_from = Value) %>%
    dplyr::mutate(
      Quarter = zoo::as.yearqtr(stringr::str_remove(Date, "-")),
      .keep = "unused",
      .before = 1
    ) %>%
    dplyr::mutate(
      across(-Quarter, ~ as.numeric(.))
    )
    # dplyr::rename_with(
    #   ~ df_variable_mapping$Variable[match(., df_variable_mapping$Code)],
    #   .cols = dplyr::all_of(df_variable_mapping$Code)
    # )


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
