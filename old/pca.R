library(terra)
library(plotly)

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

## stack <- c(##aet_annual, cwd_annual,
##            aet_winter, cwd_winter,
##            aet_spring, cwd_spring,
##            aet_summer, cwd_summer,
##            aet_fall, cwd_fall)


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

pca <- princomp(stack)

plot(pca)

pca_predict3 <- function(model, data, ...) {
  ## Restrict PCA to the first n components
  predict(model, data, ...)[,1:3]
}

pci <- predict(stack, pca, fun=pca_predict3)
plot(pci)

stack_df <- as.data.frame(pci)

head(stack_df)


ggplot(data = stack_df, mapping = aes(x = Comp.1, y = Comp.2)) +
  geom_bin2d(bins = 64)

ggplot(data = stack_df, mapping = aes(x = Comp.1, y = Comp.2)) +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", colour="white")

scatterplot3d(stack_df$Comp.1, stack_df$Comp.2, stack_df$Comp.3)

stack_df$cluster <- factor(kmeans(stack_df, 8)$cluster)

p <- plot_ly(stack_df, x=~Comp.1, y=~Comp.2, 
             z=~Comp.2, color=~cluster)
