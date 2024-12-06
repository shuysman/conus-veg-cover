### Visualization of veg distribution by cover type

library(terra)
library(tidyverse)
library(ggridges)
library(ggalt)


set.seed(255)



nlcd <- rast("./data/nlcd_resampled_1km_2019.tif") %>%
  filter(! values(.) %in% c(11, 21, 22, 23, 24, 81, 82))

aet_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/AET/historical/V_1_5_annual_gridmet_historical_AET_2000_2019_annual_means_cropped_units_mm.tif") %>% mask(nlcd)
cwd_annual <- rast("/media/smithers/shuysman/data/nps_gridded_wb/summary_layers/Deficit/historical/V_1_5_annual_gridmet_historical_Deficit_2000_2019_annual_means_cropped_units_mm.tif") %>% mask(nlcd)

stack <- c(aet_annual, cwd_annual, nlcd)

names(stack) <- c("aet_annual", "cwd_annual", "nlcd")

stack_df <- as.data.frame(stack)

stack_df$nlcd <- factor(stack_df$nlcd)

head(stack_df)

ggplot(data = stack_df, mapping = aes(x = cwd_annual, y = aet_annual, color = nlcd)) +
  geom_encircle()

ggplot(data = stack_df, mapping = aes(y = nlcd, x = aet_annual)) +
  geom_density_ridges()

ggplot(data = stack_df, mapping = aes(y = nlcd, x = cwd_annual)) +
  geom_density_ridges()

ggplot(data = stack_df, mapping = aes(x = cwd_annual, y = aet_annual, fill = nlcd), alpha = 0.5) +
  geom_bin2d()

#### 
plot_func <- function(df, name) {
  ggplot(data = df, aes(x = cwd_annual, y = aet_annual)) +
    geom_bin2d(bins = 32) +
    scale_fill_viridis_c(limits = c(1000, NA)) +
    xlim(0, 1500) +
    ylim(0, 1500) +
    ggtitle(name) +
    xlab("Annual CWD") +
    ylab("Annual AET") +
    guides(fill = "none") +
    theme_bw() +
    theme(plot.title = element_text(size = 14))
}

nested_stack <- stack_df %>% 
  group_by(nlcd) %>% 
  nest() %>% 
  mutate(plots = map2(data, nlcd, plot_func)) 

plt <- gridExtra::grid.arrange(grobs = nested_stack$plots, top = "Density of pixels vs '00-'19 Annual AET/CWD")
ggsave("img/projected_cover_change.png", plot = plt, width = 10, height = 10)
####
