# General tests, common to all chunks

context("chunks")

test_that("errors on unknown command", {
  chunklist <- find_chunks()

  for(ch in chunklist$name) {
    cl <- call(ch, "THISMAKESNOSENSE")
    expect_error(eval(cl), info = ch)
  }
})

test_that("handles DECLARE_INPUTS", {
  chunklist <- find_chunks()

  for(ch in chunklist$name) {
    cl <- call(ch, driver.DECLARE_INPUTS)
    inputs <- eval(cl)
    expect_true(is.null(inputs) |  # might be no inputs
                  is.character(inputs) & is.vector(inputs), info = ch)
  }
})

test_that("handles DECLARE_OUTPUTS", {
  chunklist <- find_chunks()

  for(ch in chunklist$name) {
    cl <- call(ch, driver.DECLARE_OUTPUTS)
    inputs <- eval(cl)
    #kbn 2020-09-25 Updating this test so that the test won't fail on chunks with null inputs.
    expect_true(is.null(inputs) |is.character(inputs) & is.vector(inputs), info = ch)
  }
})

test_that("errors if required data not available", {
  chunkdeps <- chunk_inputs()

  for(ch in unique(chunkdeps$name)) {
    cl <- call(ch, driver.MAKE, empty_data())
    expect_error(eval(cl), info = ch)
  }
})

test_that("doesn't use forbidden calls", {
  chunklist <- find_chunks()

  for(ch in unique(chunklist$name)) {
    fn <- getFromNamespace(ch, ns = "gcamdata")
    chk <- screen_forbidden(fn)
    if(length(chk > 0)) {
        infostr <- paste("Forbidden functions called in ", ch, ":  \n",
                         paste("[", chk[,1], "]", chk[,2], collapse = "\n"))
    }
    else {
        infostr <- NULL
    }
    expect_equal(chk, character(),   # should be no matches
                 info = infostr)
  }
})

test_that("chunk names are correct", {

  files_to_rename <- data.frame(orig_file_name = list.files("../../R/", full.names = TRUE)) %>%
    filter(grepl("zchunk", orig_file_name))
  expect_true(nrow(files_to_rename) == 0)

})

