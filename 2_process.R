source('2_process/src/munge_nhd_data.R')
source('2_process/src/munge_basin_metrics.R')

p2 <- list(
  tar_target(
    p2_esm_sheets,
    readxl::excel_sheets(p1_esm_xlsx)
  ),
  tar_target(
    p2_basin_mapping,
    parse_basin_mapping(p1_esm_xlsx, p2_esm_sheets[2], range="A5:F208"),
  ),
  tar_target(
    p2_basin_mapping_csv,
    {
    out_file <- '2_process/out/basin_mapping.csv'
    if(!dir.exists(dirname(out_file))) dir.create(dirname(out_file), recursive=TRUE)
    p2_basin_mapping %>% select(basin_id, huc04) %>% write_csv(file=out_file)
    return(out_file)
    }
  ),
  tar_target(
    p2_basin_chars,
    parse_basin_data(p1_esm_xlsx, p2_esm_sheets[4], range="A4:AL167")
  ),
  tar_target(
    p2_variable_defs,
    parse_basin_defs(p1_esm_xlsx, p2_esm_sheets[5], range="A3:E41")
  ),
  tar_target(
    p2_basin_ranks,
    parse_basin_data(p1_esm_xlsx, p2_esm_sheets[6], range="A5:Q168")
  ),
  tar_target(
    p2_basin_wateruse_csv,
    get_raw_and_percentile_values(p2_basin_chars, p2_basin_ranks, 
                                  variable='tot_wu', units='mgd', 
                                  out_file='2_process/out/basin_water_use.csv'),
    format = 'file'
  ),
  
  ##### LINDSAY'S ADDITIONS #####
  tar_target(
    p1_huc4s_simp_sf,
    p1_huc4s_sf %>% 
      st_intersection(p1_conus_sf) %>% 
      rmapshaper::ms_simplify(0.01)
  ),
  # If I don't do this first, I get an error about needing a vector
  # not an sfc multipolygon. Mysterious :(
  # Though, it may have something to do with slice?
  # slice(p1_huc4s_simp_sf, 40) breaks with that error.
  tar_target(
    p2_huc4s_sf_grp,
    p1_huc4s_simp_sf %>%
      group_by(iws_basin_id) %>% 
      tar_group(),
    iteration = "group"
  ),
  tar_target(
    p2_iws_basin_river_miles,
    p1_rivers_sf %>% 
      st_drop_geometry() %>% 
      group_by(id_custom) %>% 
      summarize(total_miles = sum(lengthkm)) %>% 
      rename(iws_basin_id = id_custom)
  )
  ###### END of Lindsay's additions
  
  # TODO - add target to push the final data csv(s) to S3
)