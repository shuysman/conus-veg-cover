library(tidyverse)
library(terra)
library(tidyterra)
library(FedData)

mask_ids <- c(11, 21, 22, 23, 24, 81, 82)
nlcd_2019 <- rast("./data/nlcd_resampled_1km_2019.tif")
dev_mask <- filter(nlcd_2019, values(nlcd_2019) %in% mask_ids)
current_cover <- mask(nlcd_2019, dev_mask, inverse = TRUE)

pred_mid_45 <- readRDS("./out/predicted-cover_2040-2069_rcp45.RDS")
pred_end_45 <- readRDS("./out/predicted-cover_2070-2099_rcp45.RDS")

pred_mid_85 <- readRDS("./out/predicted-cover_2040-2069_rcp85.RDS")
pred_end_85 <- readRDS("./out/predicted-cover_2070-2099_rcp85.RDS")

stack <- c(pred_mid_45, pred_end_45, pred_mid_85, pred_end_85)

names(stack) <- c("Mid-century RCP4.5",
                  "End-century RCP4.5",
                  "Mid-century RCP8.5",
                  "End-century RCP8.5")

cols_current_cover <- dplyr::filter(pal_nlcd(), ID %in% as.numeric(levels(current_cover)[[1]]$ID))

ggplot() +
  geom_spatraster(data = current_cover) +
  scale_fill_manual(values = cols_current_cover$Color)

cols_pred <- dplyr::filter(pal_nlcd(), ID %in% as.numeric(levels(pred_mid_85)[[1]]$class)) %>%
  tail(-1)

ggplot() +
  geom_spatraster(data = stack) +
  facet_wrap(~lyr) +
  scale_fill_manual(values = cols_pred$Color)

ggplot() +
  geom_spatraster(data = pred_mid_45) +
  scale_fill_manual(values = cols_pred$Color)

