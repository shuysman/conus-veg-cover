library(tidyverse)
library(terra)
library(tidyterra)
library(FedData)
library(basemaps)

terraOptions(verbose = TRUE)

mask_ids <- c(11, 21, 22, 23, 24, 81, 82)
nlcd_2019 <- rast("./data/nlcd_resampled_1km_2019.tif")
dev_mask <- filter(nlcd_2019, values(nlcd_2019) %in% mask_ids)
current_cover <- mask(nlcd_2019, dev_mask, inverse = TRUE)

pred_mid_45 <- readRDS("./predictions/predicted-cover_2040-2069_rcp45.RDS")
pred_end_45 <- readRDS("./predictions/predicted-cover_2070-2099_rcp45.RDS")

pred_mid_85 <- readRDS("./predictions/predicted-cover_2040-2069_rcp85.RDS")
pred_end_85 <- readRDS("./predictions/predicted-cover_2070-2099_rcp85.RDS")

stack <- c(pred_mid_45, pred_end_45, pred_mid_85, pred_end_85)

names(stack) <- c("Mid-century RCP4.5",
                  "End-century RCP4.5",
                  "Mid-century RCP8.5",
                  "End-century RCP8.5")


### Current and projected cover map

bbox <- extend(current_cover, c(100, 0)) ### Hack to make basemap extent bigger

basemap <- basemap_terra(bbox, map_service = "carto", map_type = "light_no_labels", map_res = 1)

cols_current_cover <- dplyr::filter(pal_nlcd(), ID %in% as.numeric(levels(factor(values(current_cover, na.rm = TRUE, mat = FALSE)))))

ggplot() +
  geom_spatraster_rgb(data = basemap) +
  geom_spatraster(data = current_cover) +
  scale_fill_manual(values = cols_current_cover$Color, na.value = NA) +
  ggtitle("Current CONUS Cover Types") +
  lims(x = c(-14055200, -7318387), y = c(2852744,  6401999)) +
  coord_sf(expand = FALSE) +
  theme_bw() 
ggsave("img/conus_current_veg_cover.png", width = 12, height = 8)

cols_pred <- dplyr::filter(pal_nlcd(), ID %in% as.numeric(levels(pred_mid_85)[[1]]$class))

ggplot() +
  geom_spatraster_rgb(data = basemap) +
  geom_spatraster(data = stack) +
  facet_wrap(~lyr) +
  scale_fill_manual(values = cols_pred$Color, na.value = NA, labels = cols_pred$Class) +
  ggtitle("Projected CONUS Cover Types") +
  lims(x = c(-14055200, -7318387), y = c(2852744,  6401999)) +
  coord_sf(expand = FALSE) +
  theme_bw()
ggsave("img/conus_projected_veg_cover.png", width = 18, height = 10)


#### Areal statistics analysis

current_cover_expanse <- expanse(current_cover, unit = "km", byValue = TRUE) %>%
  rename(Class = value) %>%
  mutate(period = "current")

pred45_cover_expanse <- expanse(subset(stack, c(1,2)), unit = "km", byValue = TRUE) %>%
  mutate(value = as.numeric(value), ## Value is typed as chr so needed for left_join() below
         period = case_match(layer, ## Rename layers to something meaningful
                             1 ~ "Mid-century",
                             2 ~ "End-century")) %>%
  left_join(select(pal_nlcd(), ID, Class), by = join_by(value == ID))
pred85_cover_expanse <- expanse(subset(stack, c(3,4)), unit = "km", byValue = TRUE) %>%
  mutate(value = as.numeric(value), ## Value is typed as chr so needed for left_join() below
         period = case_match(layer, ## Rename layers to something meaningful
                             1 ~ "Mid-century",
                             2 ~ "End-century")) %>%
  left_join(select(pal_nlcd(), ID, Class), by = join_by(value == ID))
pred45_cover_expanse <- bind_rows(
  select(current_cover_expanse, Class, area, period),
  select(pred45_cover_expanse, Class, area, period)
) %>%
  mutate(period = factor(period, levels = c("current", "Mid-century", "End-century")),
         Class = factor(Class, levels = c("Perennial Ice/Snow",
                                          "Barren Land (Rock/Sand/Clay)",
                                          "Deciduous Forest",
                                          "Evergreen Forest",
                                          "Mixed Forest",
                                          "Shrub/Scrub",
                                          "Grassland/Herbaceous",
                                          "Woody Wetlands",
                                          "Emergent Herbaceous Wetlands")))
pred85_cover_expanse <- bind_rows(
  select(current_cover_expanse, Class, area, period),
  select(pred85_cover_expanse, Class, area, period)
) %>%
  mutate(period = factor(period, levels = c("current", "Mid-century", "End-century")),
         Class = factor(Class, levels = c("Perennial Ice/Snow",
                                          "Barren Land (Rock/Sand/Clay)",
                                          "Deciduous Forest",
                                          "Evergreen Forest",
                                          "Mixed Forest",
                                          "Shrub/Scrub",
                                          "Grassland/Herbaceous",
                                          "Woody Wetlands",
                                          "Emergent Herbaceous Wetlands")))

ggplot() +
  geom_line(pred45_cover_expanse, mapping = aes(x = period, y = area, color = Class, group = Class), lwd = 2) +
  geom_line(pred85_cover_expanse, mapping = aes(x = period, y = area, color = Class, group = Class), linetype = 2, lwd = 2) +
  scale_color_manual(values = cols_pred$Color) +
  labs(title = "Projected change in area of cover types",
       subtitle = "Solid = RCP4.5, Dashed = RCP8.5",
       x = "Time Period",
       y = "Area (km²)") +
  theme_bw()
ggsave("img/projected_cover_change.png", width = 8, height = 5)
