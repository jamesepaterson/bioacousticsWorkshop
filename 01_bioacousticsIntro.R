## ---------------------------
##
## Script name: 01_bioacousticsIntro.R 
##
## Purpose of script: Introduction to bioacoustics in R
##
## Author: James Paterson
##
## Date Created: 2025-09-28
##
## 
## Email: j_paterson@ducks.ca
##
## ---------------------------

library(tuneR)
library(monitoR)

# We'll load a short recording of a Black-throated Green Warbler (btnw) vocalization, 
# which is included in the monitoR package
data(btnw)

# Look at contents
btnw

# View spectrogram
viewSpec(btnw,
         ovlp = 90,
         spec.col = viridis::viridis(100))

# Load the WAV file using tuneR::readWave
marshSounds <- readWave("marshSounds_2025-06-02_1144.wav")

# View properties
marshSounds

# View spec at specific times and shorter page length
viewSpec(marshSounds, 
         start.time = 14, # start at second 14
         page.length = 4, # 5 seconds
         ovlp = 90, # window overlap in the Fourier Transform (%)
         spec.col = viridis::viridis(100) # use a viridis colour scale
         )

# viewSpec(marshSounds,
#          start.time = 14,
#          page.length = 5,
#          spec.col = viridis::viridis(100),
#          annotate = TRUE # can be used to draw bounding boxes and label vocalizations
#          )

# Read annotations file
marshSoundsAnnotations <- read.csv("TMPannotations.csv")

# Annotation table has rows for detections with start/end time, min/max frequency, and name (label)
marshSoundsAnnotations
