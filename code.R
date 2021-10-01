# Attach libraries
library(dplyr)
library(readr)
library(sound)

# Define a directory where you audio files are (expects .wav files)
sound_directory <- '~/Desktop/sounds'

# Define a directory to save results in
results_directory <- '~/Desktop/results'
if(!dir.exists(results_directory)){
  dir.create(results_directory)
}

# Define function for converting slashes to underscores
convert_name <- function(x){
  gsub('/', '_', x)
}

# Get list of files
sound_files <- dir(sound_directory,
                   recursive = TRUE, 
                   full.names = TRUE,
                   include.dirs = TRUE,
                   pattern = '.wav')


# If there are any files in the results directory, remove them from the list of sounds to label
already_done <- dir(results_directory)
sound_files_underscored <- convert_name(sound_files)
sound_files <- sound_files[!sound_files_underscored %in% already_done]

# Define audio stuff
setWavPlayer(findWavPlayer()[1])

# Loop through each file, listen, and label
for(i in 1:length(sound_files)){
  s <- sound_files[i]
  
  if(file.exists(s)){
    out <- 4
    counter <- 0
    while(out == 4){
      counter <- counter + 1
      message(i, ' of ', length(sound_files))
      play(s, stay=FALSE, command=WavPlayer())
      out <- menu(c('Cough',
                    'Non-cough',
                    'Ambiguous',
                    'Play again'),
                  title = 'Was this a cough sound?')
    }
    tf <- c('Cough', 'Non-cough', 'Ambiguous')
    
    done <- tibble(file = result_name,
                   full_path = s,
                   label = tf[out],
                   timestamp = Sys.time())
    result_name <- convert_name(s)
    result_path <- file.path(results_directory, result_name)
    saveRDS(object = done,
            file = file.path(results_directory, result_name))
    message('Saved results to ', result_path)
  }
}

# Having labelled every sound, now read in results and write a csv of all labels
results_files <- dir(results_directory, full.names = FALSE)
out_list <- list()
for(i in 1:length(results_files)){
  this_file <- results_files[i]
  this_path <- file.path(results_directory, this_file)
  this_result <- readRDS(file = this_path)
  out_list[[i]] <- this_result
}
results <- bind_rows(out_list)
write_csv('labels.csv')
