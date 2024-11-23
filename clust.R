library(terra)
library(mclust)
library(cluster)
library(tidyverse)

set.seed(255)

aet_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_annual_gridmet_historical_AET_1980_1999_annual_means_cropped_units_mm.tif")
cwd_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_annual_gridmet_historical_Deficit_1980_1999_annual_means_cropped_units_mm.tif")
## aet_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_winter_gridmet_historical_AET_1980_1999_winter_means_cropped_units_mm.tif")
## cwd_winter <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_winter_gridmet_historical_Deficit_1980_1999_winter_means_cropped_units_mm.tif")
## aet_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_spring_gridmet_historical_AET_1980_1999_spring_means_cropped_units_mm.tif")
## cwd_spring <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_spring_gridmet_historical_Deficit_1980_1999_spring_means_cropped_units_mm.tif")
## aet_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_summer_gridmet_historical_AET_1980_1999_summer_means_cropped_units_mm.tif")
## cwd_summer <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_summer_gridmet_historical_Deficit_1980_1999_summer_means_cropped_units_mm.tif")
## aet_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_fall_gridmet_historical_AET_1980_1999_fall_means_cropped_units_mm.tif")
## cwd_fall <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_fall_gridmet_historical_Deficit_1980_1999_fall_means_cropped_units_mm.tif")

## https://www.mrlc.gov/downloads/sciweb1/shared/mrlc/metadata/Annual_NLCD_LndCov_2023_CU_C1V0.xml
nlcd <- rast("./nlcd_resampled_1km_1985.tif")

stack <- c(aet_annual, cwd_annual, nlcd)

names(stack) <- c("aet_annual", "cwd_annual", "nlcd")

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

stack_df <- as.data.frame(stack)

stack_df$nlcd <- factor(stack_df$nlcd)

head(stack_df)

summarize(stack_df, aet = mean(aet_annual, na.rm = TRUE), cwd = mean(cwd_annual, na.rm = TRUE), .by = nlcd)

ggplot(data = stack_df) +
  geom_boxplot(aes(y = cwd_annual, x = nlcd))

ggplot(data = stack_df) +
  geom_boxplot(aes(y = aet_annual, x = nlcd))

ggplot(data = stack_df, mapping = aes(x = cwd_annual, y = aet_annual)) +
  stat_density_2d(aes(fill = ..level..), geom = "polygon", colour="white")

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

vec <- rep(NA, ncell(aet_annual))
vec[complete.cases(as.data.frame(aet_annual, na.rm = FALSE))] = mod1$classification
clustering = rast(aet_annual, nlyrs = 1, vals = vec) 

plot(clustering)

idx = sample(1:nrow(stack_df), size = 10000)
head(idx)

sil = silhouette(mod1$classification[idx], dist(stack_df[idx, ]))

summary(sil)

colors = rainbow(n = 6)
plot(sil, border = NA, col = colors, main = "Silhouette Index")
