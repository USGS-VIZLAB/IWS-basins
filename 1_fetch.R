source('1_fetch/src/fetch_nhd_data.R')

p1 <- list(
  # Read in electronic supplementary material from this article:
  # https://link.springer.com/article/10.1007/s10661-020-08403-1
  tar_target(
    p1_esm_xlsx,
    '1_fetch/in/10661_2020_8403_MOESM1_ESM.xlsx',
    format = 'file'
  ),
  
  ##### LINDSAY'S ADDITIONS #####
  
  tar_target(p1_proj_str, "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"),
  tar_target(
    # Needed for cropping HUC4
    p1_conus_sf, 
    maps::map("usa", fill = TRUE, plot=FALSE) %>%
      st_as_sf() %>% 
      st_transform(p1_proj_str) %>% 
      st_buffer(0)
  ),
  
  # Load CSV from Hayley
  # Specific to the mapping we need in the IWS basin viz
  tar_target(p0_huc4_mapping_csv, "1_fetch/in/basin_mapping.csv", format = "file"),
  tar_target(p0_huc4_mapping, 
             read_csv(p0_huc4_mapping_csv) %>% 
               select(iws_basin_id = basin_id,
                      huc4 = huc04)
  ),
  
  # Manual basins downloaded as gdb (ALL IN US), unzipped, 
  # and put in the 1_fetch/in folder.
  # https://nrcs.app.box.com/v/gateway/folder/39290322977
  tar_target(
    p1_huc4s_sf,
    st_read("1_fetch/in/wbdhu4_a_us_september2021.gdb") %>% 
      st_transform(p1_proj_str) %>% 
      left_join(p1_huc4_mapping, by = "huc4")
  ),
  
  # Get rivers by basin. Limit stream order
  # to big streams only for now. 
  # Sometimes this fails about that error related to needing
  # a vector but having an sf object passed in. I can get
  # around that by running tar_invalidate(p2_huc4s_sf_grp) first.
  tar_target(
    p1_rivers_sf,
    download_rivers_sf(
      # TODO: FIX THIS. Not ideal ... I do not like this but need to
      # move on. It will not map over the grouped sf or just
      # regular sf object. Keeps throwing that error about
      # needing a vector. I don't think this solution will
      # skip rebuilds for huc4s that haven't changed, so not
      # a good long term solution.
      aoi_sf = p2_huc4s_sf_grp, 
      proj_str = p1_proj_str, 
      streamorder = 6, # TODO: CHANGE THIS MATCH WHAT WE WILL USE
      id_col = "iws_basin_id"),
    pattern = map(p2_huc4s_sf_grp)
  ),
  
  ###### END of Lindsay's additions
  
  # # commented out this code for now, since not yet using any nhd data
  # tar_target(
  #   p1_drb_huc8s, 
  #   c("02040101","02040102","02040103","02040104","02040105",
  #     "02040106","02040201","02040202","02040203","02040204",
  #     "02040205","02040206","02040207","02040301","02040302")),
  # 
  # # Get basin geometry
  # tar_target(p1_drb_sf, get_huc8(id = p1_drb_huc8s) %>% st_union() %>% st_make_valid()),
  # 
  # # Pull flowlines with stream order >= 3
  # tar_target(p1_drb_flowlines_SO3p, get_nhdplus(p1_drb_sf, streamorder = 3)),
  # 
  # # Extract comids for stream >= 3rd order
  # tar_target(p1_SO3p_comids, p1_drb_flowlines_SO3p$comid),
  # 
  # # Pull geometries for all huc8s within the basin
  # # not branching for now, b/c figured we might want to branch over
  # # each of the basins eventually
  # tar_target(p1_drb_hu8s_sf, 
  #            purrr::map(p1_drb_huc8s, function(huc8){ get_huc8(id = huc8) %>% st_make_valid()})),
  # 
  # # Pull flowlines for each huc8 (since too large to call for full basin)
  # # not branching for now, b/c figured we might want to branch over
  # # each of the basins eventually
  # tar_target(p1_drb_flowlines_SO1p,
  #            purrr::map_df(p1_drb_hu8s_sf, function(huc_geom) {get_nhdplus(huc_geom, streamorder = 1)})),
  # 
  # # get NWIS gages (mapping over huc8s)
  # # TODO - fix/check b/c seems to be returning gages outside of the basin...
  # tar_target(p1_drb_gages,
  #            purrr::map_df(p1_drb_hu8s_sf, function(huc_geom) {get_nwis(huc_geom)}))
)