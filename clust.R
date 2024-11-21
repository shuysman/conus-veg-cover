library(terra)
library(mclust)

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


stack <- c(aet_annual, cwd_annual)

names(stack) <- c("aet_annual", "cwd_annual")

##stack <- c(aet_winter, cwd_winter,
           ## aet_spring, cwd_spring,
           ## aet_summer, cwd_summer,
           ## aet_fall, cwd_fall)

## names(stack) <- c(
##         "aet_winter", "cwd_winter",
##         "aet_spring", "cwd_spring",
##         "aet_summer", "cwd_summer",
##         "aet_fall", "cwd_fall"
## )

stack_df <- as.data.frame(stack, na.rm = FALSE)

head(stack_df)

subset <- sample(1:nrow(stack_df), 10000)
BIC <- mclustBIC(stack_df, initialization = list(subset = subset))

saveRDS(BIC, "BIC_annual.RDS", compress = TRUE)

BIC <- readRDS("BIC_annual.RDS")

plot(BIC)

mod1 <- Mclust(stack_df, x = BIC)
summary(mod1, parameters = TRUE)

plot(mod1, what = "classification")

saveRDS(mod1, "mod1_annual.RDS", compress = TRUE)

mod1 <- readRDS("mod1_annual.RDS")


new_rast <- rast(matrix(mod1$classification, nrow = nrow(aet_annual), ncol = ncol(aet_annual)),
  #nrows = nrow(aet_annual),
  #ncols = ncol(aet_annual),
  extent = ext(aet_annual),
  crs = crs(aet_annual))
  #resolution = res(aet_annual))


plot(new_rast)
