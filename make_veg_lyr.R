library(tidyverse)
library(terra)
library(FedData)

terraOptions(verbose = TRUE)

aet_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_annual_gridmet_historical_AET_2000_2019_annual_means_cropped_units_mm.tif")
cwd_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_annual_gridmet_historical_Deficit_2000_2019_annual_means_cropped_units_mm.tif")
## aet_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_winter_gridmet_historical_AET_1980_1999_winter_means_cropped_units_mm.tif")
## cwd_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_winter_gridmet_historical_Deficit_1980_1999_winter_means_cropped_units_mm.tif")
## aet_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_spring_gridmet_historical_AET_1980_1999_spring_means_cropped_units_mm.tif")
## cwd_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_spring_gridmet_historical_Deficit_1980_1999_spring_means_cropped_units_mm.tif")
## aet_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_summer_gridmet_historical_AET_1980_1999_summer_means_cropped_units_mm.tif")
## cwd_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_summer_gridmet_historical_Deficit_1980_1999_summer_means_cropped_units_mm.tif")
## aet_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_fall_gridmet_historical_AET_1980_1999_fall_means_cropped_units_mm.tif")
## cwd_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_fall_gridmet_historical_Deficit_1980_1999_fall_means_cropped_units_mm.tif")

## https://www.mrlc.gov/data
## https://www.mrlc.gov/downloads/sciweb1/shared/mrlc/metadata/Annual_NLCD_LndCov_2023_CU_C1V0.xml
##nlcd <- rast("./Annual_NLCD_LndCov_2023_CU_C1V0.tif")
nlcd <- rast("./Annual_NLCD_LndCov_1985_CU_C1V0.tif")

legend <- pal_nlcd()

levels(nlcd) <- legend

nlcd_resampled <- nlcd %>%
  project(aet_annual) %>%
  resample(aet_annual, method = "mode")

levels(nlcd_resampled) <- legend ## I don't why I need to set this twice...

cats(nlcd_resampled)

plot(nlcd_resampled)

writeRaster(nlcd_resampled, "nlcd_resampled_1km_1985.tif", overwrite = TRUE)
