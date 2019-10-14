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
#' @keywords datasets temperature Netherlands observation
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

#' Reference monthly climatology grid 1990-2017 for Temperature, the Netherlands
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

#' Reference monthly climatology grid 1980-2010 for Precipitation, Indonesia
#'
#' @description raster stack object
#'
#' @docType data
#'
#' @usage data(RR_ref_grid)
#'
#'
#' @keywords datasets grid Indonesia
#' @author Marieke Dirksen
#' @examples
#' data(RR_ref_grid)
#' summary(RR_ref_grid)
"RR_ref_grid"

#' Monthly precipitation observations for Indonesia
#'
#' @description This dataset includes monthly precipitation sums for Indonesia since 1930 until 2000. Coordinates are stored
#' as data attributes, with "x" as LON and "y" as LAT in WGS84.
#' @docType data
#'
#' @usage data(RR_obs)
#'
#'
#' @keywords datasets Indonesia observation precipitation
#' @author Marieke Dirksen
#' @examples
#' data(RR_obs)
#' head(RR_obs)
#' head(attr(RR_obs,'x'))
#' head(attr(RR_obs,'y'))
"RR_obs"

#' Stations with Monthly precipitation observations for Indonesia
#'
#' @description This dataset includes monthly precipitation stations for Indonesia since 1930 until 2000.
#' @docType data
#'
#' @usage data(sp.RR_stations)
#'
#'
#' @keywords datasets Indonesia observation precipitation stations
#' @author Marieke Dirksen
#' @examples
#' library(mapview)
#' data("sp.RR_stations")
#' mapview(sp.RR_stations)
"sp.RR_stations"

