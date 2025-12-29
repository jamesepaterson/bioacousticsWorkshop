## ---------------------------
##
## Script name: 02_bioacousticsSpeciesClassifiers.R 
##
## Purpose of script: Bioacoustics: Using Species Classifiers in R
##
## Author: James Paterson
##
## Date Created: 2025-12-28
##
## 
## Email: j_paterson@ducks.ca
##
## ---------------------------

## ----birdnetPredictions----------------------------------------------------------------------------------------------------------------
# Load Library
library(birdnetR)
library(tuneR)

# Load recordings (.wav) using tuneR::readWave
marshSounds2 <- tuneR::readWave("marshSounds_2025-06-02_1148.wav")

# Initialize the TFLite BirdNet Model
# This will take some time the first time you run it
# Read more about initializing different versions of birdnet: https://birdnet-team.github.io/birdnetR/articles/birdnetR.html
birdnet_model <- birdnet_model_tflite("v2.4")

# Path to an example audio file
audio_path_marshSounds2 <- file.path(getwd(), "/marshSounds_2025-06-02_1148.wav")

# Predict species in the audio file
predictions_marshSounds2 <- predict_species_from_audio_file(birdnet_model, 
                                                            audio_path_marshSounds2,
                                                            min_confidence = 0.1,
                                                            chunk_overlap_s = 2.5,
                                                            keep_empty = FALSE)

# Print predictions table
head(predictions_marshSounds2)

## ----filterPredictions----------------------------------------------------------------------------------------------------------------

test_birdnet_model <- birdnet_model_meta()

marshSounds2LikelySpecies <- predict_species_at_location_and_time(test_birdnet_model, # a meta version of the model
                                                                  latitude = 50.174801, # I chose the lat and long based on where I recorded
                                                                  longitude = -97.135426,
                                                                  # Integer for week of the year, leaving it blank would produce an annual list
                                                                  week = lubridate::week(as.Date("2025-06-02")),
                                                                  # for min_confidence, the default = 0.03, which might remove uncommon species
                                                                  min_confidence = 0.01) |>
  # I split the label (scientific name and common name) to be able to filter by common_name
  dplyr::mutate(common_name = stringr::str_split(label, 
                                          pattern = "_",
                                          simplify = TRUE)[,2])

# Filter 
predictions_marshSounds2_filtered <- predictions_marshSounds2 |>
  dplyr::filter(common_name %in% marshSounds2LikelySpecies$common_name)

## ----isolateclips---------------------------------------------------------------------------------------------------------------------

# Hold Wave class objects of clips in a list. This is inefficient for large recordings or many files.
# For scaling, I suggest writing clips directly to .wave files, and included code to do that.
detection_clip_list <- list()

# For tracking clip names, you can add a vector in the prediction dataframe birdnetR created
predictions_marshSounds2_filtered$clip_name <- NA

# For each detection from birdnetR...
for(i in 1: nrow(predictions_marshSounds2_filtered)){
# Save just that part of the clip
detection_i_name <- paste0("marshSounds_2025-06-02_1148", "_",
                           predictions_marshSounds2_filtered$common_name[i], "_",
                           predictions_marshSounds2_filtered$start[i], "s")

# Read in just the 3s detection with a 3s buffer on either side.
detection_i_wave <- tuneR::readWave("marshSounds_2025-06-02_1148.wav", 
                                    from = predictions_marshSounds2_filtered$start[i]-3,
                                    # from = ifelse(predictions_marshSounds1$start[i]-4 < 1,
                                    #               1,
                                    #               predictions_marshSounds1$start[i]-4),
                                    units = "seconds",
                                    to = predictions_marshSounds2_filtered$end[i]+3)

detection_clip_list[[i]] <- detection_i_wave
names(detection_clip_list)[i] <- detection_i_name

# Not run, but we could save every clip to be used for human listening verification outside R, keeping original file name and the predicted species
# writeWave(object = detection_i_wave, 
#           # Could put in an output folder or structure clips by site or species, depending on objectives
#           filename = detection_i_name)

# Add details to predictions_marshSounds2
predictions_marshSounds2_filtered$clip_name[i] <- detection_i_name
}

# View spectrogram of the clip with the highest confidence (Bobolink at 81s)
monitoR::viewSpec(detection_clip_list[[136]], # The highest confidence observation is the 136'th row in our table
         ovlp = 90, # window overlap in the Fourier Transform (%)
         spec.col = viridis::viridis(100), # use a viridis colour scale
         main = names(detection_clip_list)[136] # Label the spectrogram table with the detection clip name
)
