test_that("pkg_explorer works", {
  
  app <- shinytest2::AppDriver$new(
    test_path("test-apps", "explorer-app"),
    height = 1080,
    width = 1920
    ) |> 
    # Sometimes this app gives a warning about an incomplete final line.
    # it occurs in readLines(p$get_error_file()) within shinytest2 
    # (shinytest2:::app_start_shiny). Not essential as long as the tests pass
    suppressWarnings()
  on.exit(app$stop())
  
  expect_equal(
    app$get_value(output = "src_explorer-is_file"),
    TRUE
  )
  
  app$expect_values(input = "src_explorer-dirtree", screenshot_args = FALSE)

  expect_equal(
    app$get_value(output = "src_explorer-filepath")$html,
    structure("<h5>DESCRIPTION</h5>", html = TRUE, class = c("html", "character"))
  )
  
  ## The text only shows up if it is visible in the UI.
  ## Thus, with different resolution settings this can give different snapshots.
  ## Selecting only first part solves this:
  description_text <- app$get_text(".ace_content .ace_layer.ace_text-layer")
  expect_snapshot(substring(description_text, 1, 1507))

  app$run_js("$('#300 .jstree-ocl').click()")
  app$run_js("$('#301_anchor').click()")
  app$wait_for_idle()
  
  expect_equal(
    app$get_value(output = "src_explorer-filepath")$html,
    structure("<h5>tests/testthat.R</h5>", html = TRUE, class = c("html", "character"))
  )
  # Not much text in this snapshot, thus no need to trim text here:
  app$expect_text(".ace_content .ace_layer.ace_text-layer")
})
