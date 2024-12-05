library(terra)
library(ranger)
library(tidyverse)
library(tidyterra)
library(glue)
## library(FedData)

options(ranger.num.threads = 64)

mid_century <- list(start_year = 2040, end_year = 2069)
end_century <- list(start_year = 2070, end_year = 2099)
periods <- list(mid_century, end_century)

scenarios <- c("rcp45", "rcp85")

#### RCP8.5 Projections
rf_mod <- readRDS("./rf_mod.RDS")

soil_whc <- rast("./data/soil_whc_conus_1km.tif")
nlcd_2019 <- rast("./data/nlcd_resampled_1km_2019.tif")
### Developed land types, or other unusable land types to mask from predictions.
dev_mask <- filter(nlcd_2019, values(nlcd_2019) %in% c(11, 21, 22, 23, 24, 81, 82))

make_projection <- function(start_year, end_year, scenario) {
  
  aet_winter <- rast(glue("./data/summary_layers/AET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_winter_{scenario}_AET_units_mm.tif"))
  aet_spring <- rast(glue("./data/summary_layers/AET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_spring_{scenario}_AET_units_mm.tif"))
  aet_summer <- rast(glue("./data/summary_layers/AET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_summer_{scenario}_AET_units_mm.tif"))
  aet_fall <- rast(glue("./data/summary_layers/AET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_fall_{scenario}_AET_units_mm.tif"))

  pet_winter <- rast(glue("./data/summary_layers/PET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_winter_{scenario}_PET_units_mm.tif"))
  pet_spring <- rast(glue("./data/summary_layers/PET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_spring_{scenario}_PET_units_mm.tif"))
  pet_summer <- rast(glue("./data/summary_layers/PET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_summer_{scenario}_PET_units_mm.tif"))
  pet_fall <- rast(glue("./data/summary_layers/PET/{scenario}/ensembles/ensemble_{start_year}_{end_year}_fall_{scenario}_PET_units_mm.tif"))

  cwd_winter <- rast(glue("./data/summary_layers/Deficit/{scenario}/ensembles/ensemble_{start_year}_{end_year}_winter_{scenario}_Deficit_units_mm.tif"))
  cwd_spring <- rast(glue("./data/summary_layers/Deficit/{scenario}/ensembles/ensemble_{start_year}_{end_year}_spring_{scenario}_Deficit_units_mm.tif"))
  cwd_summer <- rast(glue("./data/summary_layers/Deficit/{scenario}/ensembles/ensemble_{start_year}_{end_year}_summer_{scenario}_Deficit_units_mm.tif"))
  cwd_fall <- rast(glue("./data/summary_layers/Deficit/{scenario}/ensembles/ensemble_{start_year}_{end_year}_fall_{scenario}_Deficit_units_mm.tif"))

  accumswe <- rast(glue("./data/summary_layers/accumswe/{scenario}/ensembles/ensemble_{start_year}_{end_year}_annual_{scenario}_accumswe_units_mm.tif"))

  rain_winter <- rast(glue("./data/summary_layers/rain/{scenario}/ensembles/ensemble_{start_year}_{end_year}_winter_{scenario}_rain_units_mm.tif"))
  rain_spring <- rast(glue("./data/summary_layers/rain/{scenario}/ensembles/ensemble_{start_year}_{end_year}_spring_{scenario}_rain_units_mm.tif"))
  rain_summer <- rast(glue("./data/summary_layers/rain/{scenario}/ensembles/ensemble_{start_year}_{end_year}_summer_{scenario}_rain_units_mm.tif"))
  rain_fall <- rast(glue("./data/summary_layers/rain/{scenario}/ensembles/ensemble_{start_year}_{end_year}_fall_{scenario}_rain_units_mm.tif"))

  runoff_winter <- rast(glue("./data/summary_layers/runoff/{scenario}/ensembles/ensemble_{start_year}_{end_year}_winter_{scenario}_runoff_units_mm.tif"))
  runoff_spring <- rast(glue("./data/summary_layers/runoff/{scenario}/ensembles/ensemble_{start_year}_{end_year}_spring_{scenario}_runoff_units_mm.tif"))
  runoff_summer <- rast(glue("./data/summary_layers/runoff/{scenario}/ensembles/ensemble_{start_year}_{end_year}_summer_{scenario}_runoff_units_mm.tif"))
  runoff_fall <- rast(glue("./data/summary_layers/runoff/{scenario}/ensembles/ensemble_{start_year}_{end_year}_fall_{scenario}_runoff_units_mm.tif"))

  soil_water_winter <- rast(glue("./data/summary_layers/soil_water/{scenario}/ensembles/ensemble_{start_year}_{end_year}_winter_{scenario}_soil_water_units_mm.tif"))
  soil_water_spring <- rast(glue("./data/summary_layers/soil_water/{scenario}/ensembles/ensemble_{start_year}_{end_year}_spring_{scenario}_soil_water_units_mm.tif"))
  soil_water_summer <- rast(glue("./data/summary_layers/soil_water/{scenario}/ensembles/ensemble_{start_year}_{end_year}_summer_{scenario}_soil_water_units_mm.tif"))
  soil_water_fall <- rast(glue("./data/summary_layers/soil_water/{scenario}/ensembles/ensemble_{start_year}_{end_year}_fall_{scenario}_soil_water_units_mm.tif"))

  

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
             soil_whc
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
                    "soil_whc")

  stack <- mask(stack, dev_mask, inverse = TRUE)


  ### Issue with terra::predict using ranger models
  ### https://github.com/rspatial/terra/issues/1448
  pr <- function(mdl, ...) predict(mdl, ...)$predictions
  pred <- predict(stack, rf_mod, fun = pr, na.rm = TRUE)

  return(pred)
}

for (scenario in scenarios) {
  for (period in periods) {
    pred <- make_projection(period$start_year, period$end_year, scenario)

    filename <- glue("predicted-cover_{period$start_year}-{period$end_year}_{scenario}")
    writeRaster(pred, glue(filename, ".tif"))
    saveRDS(pred, glue(filename, ".RDS"))
  }
}

  ## names(pred) = c("Class")
  
##   cols <- dplyr::filter(pal_nlcd(), pal_nlcd()$Class %in% cats(pred)[[1]]$class)

## ggplot()+
##   geom_spatraster(data = pred) +
##   scale_fill_manual(values = cols$Color)

## ggplot() +
##         geom_spatraster(data = mask(nlcd_2023, dev_mask, inverse = TRUE))

## ### Area of each category
## expanse(pred, unit = "km", byValue = TRUE)
## expanse(mask(nlcd_2019, dev_mask, inverse = TRUE), unit = "km", byValue = TRUE)



### Code to use if you don't run terra::predict, i.e., if you need xy values if location is included as a predictor and don't want ot make a layer for the spatraster stack
## data <- as.data.frame(stack, xy = TRUE)

## data <- data[complete.cases(data),]

## pred <- predict(rf_mod, data = data)

## vec <- rep(NA, ncell(stack$aet_fall))
## vec[complete.cases(as.data.frame(stack$aet_fall, na.rm = FALSE))] <- pred$prediction

## cover_types <- rast(aet_fall, nlyrs = 1, vals = vec) 
