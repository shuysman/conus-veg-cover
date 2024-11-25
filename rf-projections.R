library(terra)
library(ranger)
library(tidyverse)
library(tidyterra)
library(FedData)

#### RCP8.5 Projections
rf_mod <- readRDS("./rf_mod.RDS")

nlcd_2023 <- rast("./nlcd_resampled_1km_2023.tif")
### Developed land types, or other unusable land types to mask from predictions.
dev_mask <- filter(nlcd_2023, values(nlcd_2023) %in% c(11, 21, 22, 23, 24, 81, 82))


aet_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_AET_units_mm.tif")
aet_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_AET_units_mm.tif")
aet_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_AET_units_mm.tif")
aet_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_AET_units_mm.tif")

cwd_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_Deficit_units_mm.tif")
cwd_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_Deficit_units_mm.tif")
cwd_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_Deficit_units_mm.tif")
cwd_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_Deficit_units_mm.tif")

accumswe <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/accumswe/rcp85/ensembles/ensemble_2070_2099_annual_rcp85_accumswe_units_mm.tif")

rain_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_rain_units_mm.tif")
rain_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_rain_units_mm.tif")
rain_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_rain_units_mm.tif")
rain_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_rain_units_mm.tif")

runoff_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_runoff_units_mm.tif")
runoff_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_runoff_units_mm.tif")
runoff_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_runoff_units_mm.tif")
runoff_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_runoff_units_mm.tif")#### RCP8.5 Projections
aet_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_AET_units_mm.tif") #
aet_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_AET_units_mm.tif")
aet_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_AET_units_mm.tif")
aet_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_AET_units_mm.tif")

cwd_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_Deficit_units_mm.tif")
cwd_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_Deficit_units_mm.tif")
cwd_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_Deficit_units_mm.tif")
cwd_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_Deficit_units_mm.tif")

accumswe <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/accumswe/rcp85/ensembles/ensemble_2070_2099_annual_rcp85_accumswe_units_mm.tif")

rain_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_rain_units_mm.tif")
rain_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_rain_units_mm.tif")
rain_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_rain_units_mm.tif")
rain_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/rain/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_rain_units_mm.tif")

runoff_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_runoff_units_mm.tif")
runoff_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_runoff_units_mm.tif")
runoff_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_runoff_units_mm.tif")
runoff_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/runoff/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_runoff_units_mm.tif")

soil_water_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/rcp85/ensembles/ensemble_2070_2099_winter_rcp85_soil_water_units_mm.tif")
soil_water_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/rcp85/ensembles/ensemble_2070_2099_spring_rcp85_soil_water_units_mm.tif")
soil_water_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/rcp85/ensembles/ensemble_2070_2099_summer_rcp85_soil_water_units_mm.tif")
soil_water_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/soil_water/rcp85/ensembles/ensemble_2070_2099_fall_rcp85_soil_water_units_mm.tif")

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
           soil_water_summer, soil_water_fall
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
                  "soil_water_summer", "soil_water_fall")

stack <- mask(stack, dev_mask, inverse = TRUE)


### Issue with terra::predict using ranger models
### https://github.com/rspatial/terra/issues/1448
pr <- function(mdl, ...) predict(mdl, ...)$predictions
pred <- predict(stack, rf_mod, fun = pr, na.rm = TRUE)

names(pred) = c("Class")

cols <- dplyr::filter(pal_nlcd(), pal_nlcd()$Class %in% cats(pred)[[1]]$class)

ggplot()+
  geom_spatraster(data = pred) +
  scale_fill_manual(values = cols$Color)

ggplot() +
        geom_spatraster(data = mask(nlcd_2023, dev_mask, inverse = TRUE))

### Area of each category
expanse(pred, unit = "km", byValue = TRUE)
expanse(mask(nlcd_2023, dev_mask, inverse = TRUE), unit = "km", byValue = TRUE)



### Code to use if you don't run terra::predict, i.e., if you need xy values if location is included as a predictor and don't want ot make a layer for the spatraster stack
## data <- as.data.frame(stack, xy = TRUE)

## data <- data[complete.cases(data),]

## pred <- predict(rf_mod, data = data)

## vec <- rep(NA, ncell(stack$aet_fall))
## vec[complete.cases(as.data.frame(stack$aet_fall, na.rm = FALSE))] <- pred$prediction

## cover_types <- rast(aet_fall, nlyrs = 1, vals = vec) 
