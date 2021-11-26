#' @title Download rivers sf objects from the NHD+ using nhdplusTools
#' @param aoi_sf sf object representing the area of interest to get rivers
#' @param proj_str character string representing the projection. No default.
#' @param streamorder numeric value indicating the size of stream to include
#' in the query. Smaller streamorder = smaller stream in this data.
#' @param id_col column to keep from `aoi_sf` with the new rivers sf to be
#' able to match them together later. Currently only setup to have one
#' unique value per aoi_sf.
download_rivers_sf <- function(aoi_sf, proj_str, streamorder = 3, id_col = NULL) {
  
  rivers_raw <- get_nhdplus(AOI = aoi_sf, streamorder = streamorder)
  
  if(!c("sf") %in% class(rivers_raw)) {
    rivers_out <- NULL
  } else {
    rivers_out <- rivers_raw %>% 
      select(id, comid, streamorde, lengthkm) %>% 
      st_make_valid() %>% 
      st_transform(proj_str)
    
    if(!is.null(id_col)) {
      id_to_add <- unique(aoi_sf[[id_col]])
      rivers_out <- rivers_out %>% 
        mutate(id_custom = id_to_add) %>% 
        relocate(id_custom, .before = geometry)
    }
    
  }
  
  return(rivers_out)
}
