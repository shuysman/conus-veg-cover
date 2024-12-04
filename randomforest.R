library(ranger)
library(terra)
library(tidyverse)

set.seed(255)

aet_winter <- rast("./data/summary_layers/AET/historical/V_1_5_winter_gridmet_historical_AET_2000_2019_winter_means_cropped_units_mm.tif")
cwd_winter <- rast("./data/summary_layers/Deficit/historical/V_1_5_winter_gridmet_historical_Deficit_2000_2019_winter_means_cropped_units_mm.tif")
aet_spring <- rast("./data/summary_layers/AET/historical/V_1_5_spring_gridmet_historical_AET_2000_2019_spring_means_cropped_units_mm.tif")
cwd_spring <- rast("./data/summary_layers/Deficit/historical/V_1_5_spring_gridmet_historical_Deficit_2000_2019_spring_means_cropped_units_mm.tif")
aet_summer <- rast("./data/summary_layers/AET/historical/V_1_5_summer_gridmet_historical_AET_2000_2019_summer_means_cropped_units_mm.tif")
cwd_summer <- rast("./data/summary_layers/Deficit/historical/V_1_5_summer_gridmet_historical_Deficit_2000_2019_summer_means_cropped_units_mm.tif")
aet_fall <- rast("./data/summary_layers/AET/historical/V_1_5_fall_gridmet_historical_AET_2000_2019_fall_means_cropped_units_mm.tif")
cwd_fall <- rast("./data/summary_layers/Deficit/historical/V_1_5_fall_gridmet_historical_Deficit_2000_2019_fall_means_cropped_units_mm.tif")

pet_winter <- rast("./data/summary_layers/PET/historical/V_1_5_winter_gridmet_historical_PET_2000_2019_winter_means_cropped_units_mm.tif")
pet_spring <- rast("./data/summary_layers/PET/historical/V_1_5_spring_gridmet_historical_PET_2000_2019_spring_means_cropped_units_mm.tif")
pet_summer <- rast("./data/summary_layers/PET/historical/V_1_5_summer_gridmet_historical_PET_2000_2019_summer_means_cropped_units_mm.tif")
pet_fall <- rast("./data/summary_layers/PET/historical/V_1_5_fall_gridmet_historical_PET_2000_2019_fall_means_cropped_units_mm.tif")

accumswe <- rast("./data/summary_layers/accumswe/historical/V_1_5_annual_gridmet_historical_accumswe_2000_2019_annual_means_cropped_units_mm.tif")

rain_winter <- rast("./data/summary_layers/rain/historical/V_1_5_annual_gridmet_historical_rain_2000_2019_annual_means_cropped_units_mm.tif")
rain_spring <- rast("./data/summary_layers/rain/historical/V_1_5_spring_gridmet_historical_rain_2000_2019_spring_means_cropped_units_mm.tif")
rain_summer <- rast("./data/summary_layers/rain/historical/V_1_5_summer_gridmet_historical_rain_2000_2019_summer_means_cropped_units_mm.tif")
rain_fall <- rast("./data/summary_layers/rain/historical/V_1_5_fall_gridmet_historical_rain_2000_2019_fall_means_cropped_units_mm.tif")

runoff_winter <- rast("./data/summary_layers/runoff/historical/V_1_5_annual_gridmet_historical_runoff_2000_2019_annual_means_cropped_units_mm.tif")
runoff_spring <- rast("./data/summary_layers/runoff/historical/V_1_5_spring_gridmet_historical_runoff_2000_2019_spring_means_cropped_units_mm.tif")
runoff_summer <- rast("./data/summary_layers/runoff/historical/V_1_5_summer_gridmet_historical_runoff_2000_2019_summer_means_cropped_units_mm.tif")
runoff_fall <- rast("./data/summary_layers/runoff/historical/V_1_5_fall_gridmet_historical_runoff_2000_2019_fall_means_cropped_units_mm.tif")

soil_water_winter <- rast("./data/summary_layers/soil_water/historical/V_1_5_annual_gridmet_historical_soil_water_2000_2019_annual_means_cropped_units_mm.tif")
soil_water_spring <- rast("./data/summary_layers/soil_water/historical/V_1_5_spring_gridmet_historical_soil_water_2000_2019_spring_means_cropped_units_mm.tif")
soil_water_summer <- rast("./data/summary_layers/soil_water/historical/V_1_5_summer_gridmet_historical_soil_water_2000_2019_summer_means_cropped_units_mm.tif")
soil_water_fall <- rast("./data/summary_layers/soil_water/historical/V_1_5_fall_gridmet_historical_soil_water_2000_2019_fall_means_cropped_units_mm.tif")

soil_whc <- rast("./data/soil_whc_conus_1km.tif")

nlcd <- rast("./data/nlcd_resampled_1km_2019.tif")

nlcd <- nlcd %>%
  subst(c(21, 22, 23, 24, 81, 82, 11), NA, raw = TRUE) ### Remove cultivated land types, developed land, open water

stack <- c(aet_winter, cwd_winter,
           aet_spring, cwd_spring,
           aet_summer, cwd_summer,
           aet_fall, cwd_fall,
           pet_winter,
           pet_spring,
           pet_summer,
           pet_fall,
           accumswe,
           rain_winter, rain_spring,
           rain_summer, rain_fall,
           runoff_winter, runoff_spring,
           runoff_summer, runoff_fall,
           soil_water_winter, soil_water_spring,
           soil_water_summer, soil_water_fall,
           soil_whc,
           nlcd
           )

names(stack) <- c("aet_winter", "cwd_winter",
                  "aet_spring", "cwd_spring",
                  "aet_summer", "cwd_summer",
                  "aet_fall", "cwd_fall",
                  "pet_winter",
                  "pet_spring",
                  "pet_summer",
                  "pet_fall",
                  "accumswe",
                  "rain_winter", "rain_spring",
                  "rain_summer", "rain_fall",
                  "runoff_winter", "runoff_spring",
                  "runoff_summer", "runoff_fall",
                  "soil_water_winter", "soil_water_spring",
                  "soil_water_summer", "soil_water_fall",
                  "soil_whc",
                  "nlcd")

data <- as.data.frame(stack, xy = FALSE) ## Can use xy = TRUE if you want to include location as predictor

data <- data[complete.cases(data),]

data$nlcd <- factor(data$nlcd)

head(data)

rf_mod <- ranger(nlcd ~ .,
                 data = data, 
                 num.trees = 500,
                 splitrule = "gini",
                 max.depth = 0,
                 replace = TRUE,
                 probability = FALSE,
                 importance = "impurity",
                 write.forest = TRUE,
                 num.threads = 64)
summary(rf_mod)

print(rf_mod)

importance(rf_mod)

print(rf_mod$confusion.matrix)

saveRDS(rf_mod, file = "rf_mod.RDS", compress = TRUE)


###library(pROC)

## https://stackoverflow.com/questions/60973549/roc-curve-ranger
##ROC_ranger <- pROC::roc(probabilities$BiClass, probabilities$`1`)
