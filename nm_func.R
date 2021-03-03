### Using laGP package to get the Gaussian Process solution
nm_func <- function(X, Y, XX){
  # first stage model using neareast neighbour
  print("... initating with nn")
  md = aGP(X, Y, XX, method="nn", verb=0)

  # refine with Active Learning Cohn (ALC)
  # which minimizes predictive variance
  print("... refining with alc")
  alc.md <<- aGP(X, Y, XX, method="alc", d=md$mle$d, verb=0)

}
