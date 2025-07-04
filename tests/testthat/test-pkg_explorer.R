test_that("pkg_explorer works", {
  
  app <- shinytest2::AppDriver$new(
    test_path("test-apps", "explorer-app"),
    height = 1080,
    width = 1920
    )

  expect_equal(
    app$get_value(output = "src_explorer-is_file"),
    TRUE
  )
  
  app$expect_values(input = "src_explorer-dirtree", screenshot_args = FALSE)

  expect_equal(
    app$get_value(output = "src_explorer-filepath")$html,
    structure("<h5>DESCRIPTION</h5>", html = TRUE, class = c("html", "character"))
  )
  app$expect_text(".ace_content .ace_layer.ace_text-layer")

  app$run_js("$('#300 .jstree-ocl').click()")
  app$run_js("$('#301_anchor').click()")
  app$wait_for_idle()
  
  expect_equal(
    app$get_value(output = "src_explorer-filepath")$html,
    structure("<h5>tests/testthat.R</h5>", html = TRUE, class = c("html", "character"))
  )
  app$expect_text(".ace_content .ace_layer.ace_text-layer")
})
