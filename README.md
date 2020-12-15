# Sheet Music Reader
**A sheet music reader that quantizes notes and outputs audio based on input images.**

## Usage
The script accepts images in JPEG format. Based on current system functionality, images should adhere to the following conditions. Images must be:
* A single image
* Digital sheet music (not a picture of paper sheet music)
* In C-major
* Have geometrically spaced notes
* Have only one note being played at a time
* Contain only treble notes
* Contain only quarter notes
* Contain notes not more than four tones above or below the treble stave

Included in the project folder are three test images which the script is able to read without issue. These images are enclosed in the "Test Images" folder. The test image that is used to run the script is specified on line 24 of "sheet_music_reader.m".

## Background
Sheet music is highly ubiquitous, and many people have large collections of old sheet music for which there is no digital version. A sheet music reader could digitize and preserve a library of old sheet music. However, the creation of a sheet music reader is not only useful on its own but has the potential to serve as the basis for a number of very useful applications. One can imagine an application that tracks a user’s piano playing against a piece of sheet music, to provide them with an accuracy score and help them improve their playing. This is just one example of the uses of such a system.

## Overview
Our sheet music reader is designed to meet a few specifications. The reader will receive an input image of sheet music and will output audio, playing the notes of the sheet music. We have established a number of constraints on the input image to simplify the problem and allow us to meet our deadlines. These constraints are listed above in the usage section.

If these conditions are met, the system should be able to read the music. The system will be capable of accepting sheet music with multiple staves, images with words and other characters, and music with many notes on the same stave. We will detail our implementation of this algorithm in section 3, examine three examples in section 4, and finally conclude in section 5 by discussing how our system could be improved and expanded in the future.

## Implementation
Our sheet music reader is implemented using MATLAB, and we have contained the entire system to a single “.m” file. For each section, we will provide the MATLAB source code, explain the processing that is taking place, and display the processing as it is executed on "music1.jpg".
### Initial Setup
