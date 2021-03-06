#' Methods to extract proximity matrices from random forests
#'
#' Extracts proximity matrices from random forest objects from the party, randomForest, randomForestSRC, or ranger packages
#'
#' @importFrom stats predict
#'
#' @param fit object of class 'RandomForest', 'randomForest', 'rfsrc', or `ranger`
#' @param newdata new data with the same columns as the data used for \code{fit}
#' @param ... arguments to be passed to \code{extract_proximity}
#'
#' @return an n x n matrix where position i, j gives the proportion of times observation i and j are in the same teriminal node across all trees
#'
#' @seealso \code{\link{plot_prox}} for plotting principal components of proximity matrices.
#'
#' @examples
#' library(randomForest)
#' 
#' fit = randomForest(hp ~ ., mtcars, proximity = TRUE)
#' extract_proximity(fit)
#'
#' fit = randomForest(Species ~ ., iris, proximity = TRUE)
#' extract_proximity(fit)
#' @export
extract_proximity = function(fit, newdata) UseMethod("extract_proximity")
#' @export
extract_proximity.randomForest = function(fit, newdata = NULL, ...) {
  if (!is.null(newdata)) {
    pred = predict(fit, newdata = newdata, proximity = TRUE, ...)
    if (!is.null(pred$oob.prox))
      out = pred$oob.prox
    else if (!is.null(pred$prox))
      out = pred$prox
    else stop("not sure what is up") 
  } else {
    if (is.null(fit$proximity))
      stop("call randomForest with proximity or oob.prox = TRUE")
    fit$proximity
  }
}
#' @export
extract_proximity.RandomForest = function(fit, newdata = NULL, ...) {
  party::proximity(fit, newdata, ...)
}
#' @export
extract_proximity.rfsrc = function(fit, newdata = NULL, ...) {
  if (!is.null(newdata)) {
    pred = predict(fit, newdata = newdata, proximity = TRUE, ...)
    pred$prox
  } else {
    if (is.null(fit$proximity))
      stop("call rfsrc with proximity equal to TRUE, \"inbag\", \"oob\", or \"all\"")
    fit$proximity
  }
}

#' @export
extract_proximity.ranger = function(fit, newdata, ...) {
  pred = predict(fit, newdata, type = "terminalNodes")$predictions
  prox = matrix(NA, nrow(pred), nrow(pred))
  ntree = ncol(pred)
  n = nrow(prox)

  for (i in 1:n) {
    for (j in 1:n) {
      prox[i, j] = sum(pred[i, ] == pred[j, ])
    }
  }

  prox / ntree
}
