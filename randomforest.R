library(ranger)
library(terra)
library(tidyverse)

set.seed(255)

aet_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_winter_gridmet_historical_AET_1980_1999_winter_means_cropped_units_mm.tif")
cwd_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_winter_gridmet_historical_Deficit_1980_1999_winter_means_cropped_units_mm.tif")
aet_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_spring_gridmet_historical_AET_1980_1999_spring_means_cropped_units_mm.tif")
cwd_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_spring_gridmet_historical_Deficit_1980_1999_spring_means_cropped_units_mm.tif")
aet_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_summer_gridmet_historical_AET_1980_1999_summer_means_cropped_units_mm.tif")
cwd_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_summer_gridmet_historical_Deficit_1980_1999_summer_means_cropped_units_mm.tif")
aet_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_fall_gridmet_historical_AET_1980_1999_fall_means_cropped_units_mm.tif")
cwd_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_fall_gridmet_historical_Deficit_1980_1999_fall_means_cropped_units_mm.tif")

accumswe <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/accumswe/historical/V_1_5_annual_gridmet_historical_accumswe_1980_1999_annual_means_cropped_units_mm.tif")

rain_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/historical/V_1_5_annual_gridmet_historical_rain_1980_1999_annual_means_cropped_units_mm.tif")
rain_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/historical/V_1_5_spring_gridmet_historical_rain_1980_1999_spring_means_cropped_units_mm.tif")
rain_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/historical/V_1_5_summer_gridmet_historical_rain_1980_1999_summer_means_cropped_units_mm.tif")
rain_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/historical/V_1_5_fall_gridmet_historical_rain_1980_1999_fall_means_cropped_units_mm.tif")

runoff_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/historical/V_1_5_annual_gridmet_historical_runoff_1980_1999_annual_means_cropped_units_mm.tif")
runoff_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/historical/V_1_5_spring_gridmet_historical_runoff_1980_1999_spring_means_cropped_units_mm.tif")
runoff_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/historical/V_1_5_summer_gridmet_historical_runoff_1980_1999_summer_means_cropped_units_mm.tif")
runoff_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/historical/V_1_5_fall_gridmet_historical_runoff_1980_1999_fall_means_cropped_units_mm.tif")

soil_water_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/historical/V_1_5_annual_gridmet_historical_soil_water_1980_1999_annual_means_cropped_units_mm.tif")
soil_water_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/historical/V_1_5_spring_gridmet_historical_soil_water_1980_1999_spring_means_cropped_units_mm.tif")
soil_water_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/historical/V_1_5_summer_gridmet_historical_soil_water_1980_1999_summer_means_cropped_units_mm.tif")
soil_water_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/historical/V_1_5_fall_gridmet_historical_soil_water_1980_1999_fall_means_cropped_units_mm.tif")

nlcd <- rast("./nlcd_resampled_1km_1985.tif")

nlcd <- nlcd %>%
  subst(c(21, 22, 23, 24, 81, 82, 11), NA, raw = TRUE) ### Remove cultivated land types, developed land, open water

stack <- c(aet_winter, cwd_winter,
           aet_spring, cwd_spring,
           aet_summer, cwd_summer,
           aet_fall, cwd_fall,
           accumswe,
           rain_winter, rain_spring,
           rain_summer, rain_fall,
           runoff_winter, runoff_spring,
           runoff_summer, runoff_fall,
           soil_water_winter, soil_water_spring,
           soil_water_summer, soil_water_fall,
           nlcd
           )

names(stack) <- c("aet_winter", "cwd_winter",
                  "aet_spring", "cwd_spring",
                  "aet_summer", "cwd_summer",
                  "aet_fall", "cwd_fall",
                  "accumswe",
                  "rain_winter", "rain_spring",
                  "rain_summer", "rain_fall",
                  "runoff_winter", "runoff_spring",
                  "runoff_summer", "runoff_fall",
                  "soil_water_winter", "soil_water_spring",
                  "soil_water_summer", "soil_water_fall",
                  "nlcd")

data <- as.data.frame(stack)

data <- data[complete.cases(data),]

data$nlcd <- factor(data$nlcd)

head(data)

ind <- sample(2, nrow(data), replace = TRUE, prob = c(0.7, 0.3))
train <- data[ind == 1,]
test <- data[ind == 2,]

rf_mod <- ranger(nlcd ~ ., data = train, 
                 classif.learner = "oob", 
                 num.trees = 500,
                 min.n = 1)
summary(rf_mod)
