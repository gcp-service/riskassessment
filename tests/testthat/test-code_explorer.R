test_that("pkg_explorer works", {
  
  app <- shinytest2::AppDriver$new(test_path("test-apps", "explorer-app"))
  on.exit(app$stop())
  
  app$set_inputs(tabs = "fn_expl_tab")
  app$wait_for_value(input = "fn_explorer-test_files")

  expect_equal(
    app$get_values(input = paste("fn_explorer", c("exported_function", "file_type"), sep = "-"))$input,
    list(`fn_explorer-exported_function` = ".data", `fn_explorer-file_type` = "test")
  )
  
  expect_equal(
    app$get_value(input = "fn_explorer-test_files"),
    "test-across.R"
  )
  
  expect_equal(
    app$get_text("#fn_explorer-file_output td.code pre.language-r")[1:10],
    c("# across ------------------------------------------------------------------", 
      "", "test_that(\"across() works on one column data.frame\", {", 
      "  df <- data.frame(x = 1)", "", "  out <- df %>% mutate(across(everything(), identity))", 
      "  expect_equal(out, df)", "})", "", "test_that(\"across() does not select grouping variables\", {"
    )
  )

  app$set_inputs(`fn_explorer-exported_function` = "arrange")
  app$wait_for_idle()
  
  expect_equal(
    app$get_value(input = "fn_explorer-test_files"),
    "test-arrange.R"
  )
  
  app$set_inputs(`fn_explorer-file_type` = "man")
  app$wait_for_idle(1000)
  
  expect_equal(
    app$get_value(input = "fn_explorer-man_files"),
    "arrange.Rd"
  )
  
  app$expect_text("#fn_explorer-file_output div.container")
  
})
