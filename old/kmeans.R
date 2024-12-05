library(terra)

## aet_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_annual_gridmet_historical_AET_2000_2019_annual_means_cropped_units_mm.tif") 
## cwd_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_annual_gridmet_historical_Deficit_2000_2019_annual_means_cropped_units_mm.tif")
aet_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_winter_gridmet_historical_AET_1980_1999_winter_means_cropped_units_mm.tif")
cwd_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_winter_gridmet_historical_Deficit_1980_1999_winter_means_cropped_units_mm.tif")
aet_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_spring_gridmet_historical_AET_1980_1999_spring_means_cropped_units_mm.tif")
cwd_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_spring_gridmet_historical_Deficit_1980_1999_spring_means_cropped_units_mm.tif")
aet_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_summer_gridmet_historical_AET_1980_1999_summer_means_cropped_units_mm.tif")
cwd_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_summer_gridmet_historical_Deficit_1980_1999_summer_means_cropped_units_mm.tif")
aet_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_fall_gridmet_historical_AET_1980_1999_fall_means_cropped_units_mm.tif")
cwd_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_fall_gridmet_historical_Deficit_1980_1999_fall_means_cropped_units_mm.tif")

elev <- rast("~/OneDrive/gridMET/metdata_elevationdata.nc") |>
  project(aet_winter) |> 
  resample(aet_winter)

stack <- c(##aet_annual, cwd_annual,
           aet_winter, cwd_winter,
           aet_spring, cwd_spring,
           aet_summer, cwd_summer,
           aet_fall, cwd_fall)

## km_16 <- k_means(stack, centers = 16) #
km_32 <- k_means(stack, centers = 32, maxcell = 1e8)
km_64 <- k_means(stack, centers = 64)
## km_128 <- k_means(stack, centers = 128)

## plot(km)

## plet(km)

## km_re <- project(km, crs("EPSG:4326"))

## plet(km_re)

## writeRaster(km_16, "test_16.tif")
writeRaster(km_32, "test_32.tif", overwrite = TRUE)
writeRaster(km_64, "test_64.tif", overwrite = TRUE)
## writeRaster(km_128, "test_128.tif")



elev_km <- k_means(elev, centers = 32)

autoplot(elev_km)
