################################################################################

context("LD_SCORES")

################################################################################

N <- 500
M <- 100
test <- snp_fake(N, M)
G <- test$genotypes
G[] <- sample(as.raw(0:3), size = length(G), replace = TRUE)

################################################################################

test_that("Same ld scores as with snp_cor()", {

  replicate(10, {

    # random parameters
    ind.row <- sample(N, N / 2)
    ind.col <- sample(M, M / 2)
    size <- sample(20:40, 1)

    corr <- snp_cor(G, ind.row, ind.col, size = size, fill.diag = TRUE)
    ld <- snp_ld_scores(G, ind.row, ind.col, size = size)
    expect_length(ld, length(ind.col))
    expect_equal(ld, Matrix::colSums(corr^2))
  })

})

################################################################################

test_that("Information on position is used in snp_ld_scores()", {

  ld2 <- snp_ld_scores(G, size = 5)
  expect_length(ld2, ncol(G))
  expect_true(all(ld2 > 1))
  ld3 <- snp_ld_scores(G, size = 5, ncores = 2)
  expect_equal(ld3, ld2)

  ld4 <- snp_ld_scores(G, size = 5e3, infos.pos = 1e6 * cols_along(G))
  expect_equal(ld4, ld2)

  ld5 <- snp_ld_scores(G, size = 5e-3, infos.pos = cols_along(G))
  expect_equal(ld5, ld2)

  ld6 <- snp_ld_scores(G, size = 0.5)
  expect_equal(ld6, rep(1, ncol(G)))
})

################################################################################

test_that("bed_ld_scores() works like snp_ld_scores()", {

  bedfile <- snp_writeBed(test, tempfile(fileext = ".bed"))
  obj_bed <- bed(bedfile)
  expect_error(bed_ld_scores(obj.bed = G),
               "'obj.bed' is not of class 'bed'.", fixed = TRUE)
  expect_equal(
    snp_ld_scores(Gna = G, size = 20),
    bed_ld_scores(obj.bed = obj_bed, size = 20)
  )
})

################################################################################
