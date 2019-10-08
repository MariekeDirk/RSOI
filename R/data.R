#' Monthly temperature observations from the Netherlands
#'
#' @description This dataset includes monthly mean temperature observations from the Netherlands since 1906. Coordinates are stored
#' as data attributes, with "x" as LON and "y" as LAT in WGS84.
#'
#' @docType data
#'
#' @usage data(TN_observations)
#'
#'
#' @keywords datasets temperature Netherlands
#' @author Marieke Dirksen
#' @examples
#' data(TN_observations)
#' head(TN_observations)
#' head(attr(TN_observations,'x'))
#' head(attr(TN_observations,'y'))
"TN_observations"

#' Reference monthly temperature observations from the Netherlands 1990-2017
#'
#' @description This dataset includes monthly mean temperature observations from the Netherlands from 1990 until 2017. Coordinates are stored
#' as data attributes, with "x" as LON and "y" as LAT in WGS84.
#'
#' @docType data
#'
#' @usage data(TN_reference)
#'
#'
#' @keywords datasets temperature Netherlands reference
#' @author Marieke Dirksen
#' @examples
#' data(TN_reference)
#' head(TN_reference)
#' head(attr(TN_reference,'x'))
#' head(attr(TN_reference,'y'))
"TN_reference"

#' Specification of the grid parameters with time dimension
#'
#' @description Coordinates are stored as data attributes, with "x" as LON and "y" as LAT in WGS84. The time dimension is in months.
#'
#' @docType data
#'
#' @usage data(sp_grid_nl)
#'
#'
#' @keywords datasets grid Netherlands
#' @author Marieke Dirksen
#' @examples
#' data(sp_grid_nl)
#' head(attr(sp_grid_nl,'x'))
#' head(attr(sp_grid_nl,'y'))
#' head(attr(sp_grid_nl,'time'))
"sp_grid_nl"

#' Reference climatology grid 1990-2017
#'
#' @description raster values interpolated with ordinary kriging, based on daily values.
#'
#' @docType data
#'
#' @usage data(ok_NL)
#'
#'
#' @keywords datasets grid Netherlands reference raster
#' @author Marieke Dirksen
#' @examples
#' data(ok_NL)
#' summary(ok_NL)
"ok_NL"
