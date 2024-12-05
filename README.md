# Predicting Major Vegetation Types for CONUS using the Climatic Water Balance

Fit random forest models using `ranger` to model current US land cover types. 

2019 NLCD cover types are used as a response (https://www.mrlc.gov/data).

 Climatic water balance inputs from the NPS Gridded Water Balance model (http://screenedcleanedsummaries.s3-website-us-west-2.amazonaws.com/) are used as predictors.  The historical water balance was modeled using the gridMET gridded climate data set as input (https://www.climatologylab.org/gridmet.html).  The projected water balance is modeled using the MACA dataset as input (https://www.climatologylab.org/maca.html).  Because the MACA dataset consists of GCMs downscaled using gridMET, data based on the historical gridMET and projected MACA climate data can be directly compared without bias correction.
 
 ## Files
 
 `make_veg_lyr.R` - Create resampled cover type layer compatible with the 1km NPS gridded water balance cells.  Majority pixel count is used to upscale the 30m NLCD grids.
 `viz_veg_dist.R` - Visualizations of vegetation cover type distributions vs historical water balance variables.
 `randomforest.R` - fit a random forest model to the data.  The associated `sbatch` file can be used to run the script in a `SLURM` environment.
 `rf-projections.R` - Use the random forest model to predict future changes in vegetation cover using ensemble water balance projections for RCP 4.5 and RCP8.5 scenarios.
