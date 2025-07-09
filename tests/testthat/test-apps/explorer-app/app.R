library(riskassessment)

pkg_name <- "dplyr"
pkg_version <- "1.1.2"
pkg_tarball <- paste0(pkg_name, "_", pkg_version, ".tar.gz")
tarball_dir <- "tarballs"
app_path <- "."

if(rlang::is_interactive()){
  app_path <- testthat::test_path("test-apps/explorer-app")
  tarball_dir <- file.path(app_path, tarball_dir)
}
app_tar_loc <- file.path(tarball_dir, pkg_tarball)

# delete app DB if exists to ensure clean test
app_db_loc <- file.path(app_path, "dplyr.sqlite")
if (file.exists(app_db_loc)) {
  file.remove(app_db_loc)
}

if (!dir.exists(tarball_dir)) {
  dir.create(tarball_dir)
}
if (!file.exists(file.path(tarball_dir, pkg_tarball))) {
  download.file(
    "https://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_1.1.2.tar.gz",
    app_tar_loc,
    mode = "wb"
  )
}

app_src_loc <- file.path(app_path, "source")
if (!dir.exists(app_src_loc)) {
  untar(app_tar_loc, exdir = app_src_loc)
}

ui <- fluidPage(
  riskassessment:::golem_add_external_resources(),
  tabsetPanel(
    id = "tabs",
    tabPanel(
      "src_expl_tab",
      riskassessment:::mod_pkg_explorer_ui("src_explorer")
    ),
    tabPanel(
      "fn_expl_tab",
      riskassessment:::mod_code_explorer_ui("fn_explorer")
    )
  )
)

server <- function(input, output, server) {
  shinyOptions(golem_options = list(assessment_db_name = paste0(pkg_name, ".sqlite")))
  selected_pkg <- list(name = reactiveVal(pkg_name), version = reactiveVal(pkg_version))
  pkgarchive <- reactiveVal(archive::archive(app_tar_loc) |>
                              dplyr::arrange(tolower(path)))
  user <- reactiveValues(
    name = "tester",
    role = "admin"
  )
  credential_config <- riskassessment:::get_db_config("credentials", config = "default")
  riskassessment:::mod_pkg_explorer_server("src_explorer", selected_pkg,
                                           pkgarchive = pkgarchive,
                                           user = user,
                                           credentials = credential_config,
                                           tarball_dir = tarball_dir
                                           )
  
  riskassessment:::mod_code_explorer_server("fn_explorer", selected_pkg,
                                            pkgarchive = pkgarchive,
                                            user = user,
                                            credentials = credential_config)
}

shinyApp(ui, server) |> 
  # Sometimes this app gives a warning about an incomplete final line.
  # it occurs in readLines(p$get_error_file()) within shinytest2 
  # (shinytest2:::app_start_shiny). Not essential as long as the tests pass
  suppressWarnings()

