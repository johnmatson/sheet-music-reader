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
Our sheet music reader is implemented using MATLAB, and we have contained the entire system to a single “.m” file. For each section, we will provide the MATLAB source code, explain the processing that is taking place, and display the processing as it is executed on "music1.jpg", if possible.
### Initial Setup
#### Source Code
```matlab
% image constants
STD_WIDTH = 1700;
MIN_STAVE_WIDTH = 400;
MIN_NOTE_RADIUS = 6;
CLEF_WIDTH = 100;
END_WIDTH = 10;
BOUND_HEIGHT = 40;
PIXEL_SKIPS = 5;
 
% music constants
FS = 4e3;
BPM = 100;
NOTE_LENGTH = BPM/60/4;
VOLUME = 0.1;
NOTES_BELOW = 4;
NOTES_ABOVE = 4;
NOTE_FREQS = [  220.00 246.94 261.63 293.66 329.63 349.23 ...
                392.00 440.00 493.88 523.25 587.33 659.25 ...
                698.46 783.99 880.00 987.77 1046.50 ];
 
I = imread("Test Images/music1.jpg");
```
#### Explanation
We begin by defining a number of constants. The use of these constants will be shown in the following sections. We then read our image into the MATLAB workspace using the imread function.
#### Result - Unprocessed Image

### Point Processing
#### Source Code
```matlab
I_gray = rgb2gray(I); % convert to greyscale
I_bin = imbinarize(I_gray); % threshold convert to binary image
I_inv = imcomplement(I_bin); % invert image so data is true
```
#### Explanation
Before we start looking at the image data itself, we need to pre-process the image. We start by using the rgb2gray function to convert the image from RGB to grayscale colour space, which simplifies our processing by eliminating irrelevant colour data. Next, we threshold our image to create a binary matrix using imbinarize. This function performs a sort of automatic thresholding, using Otsu’s method, to choose the threshold value that creates the most separation between the data above and below the threshold point. Finally, we invert our binary image using the imcomplement function so that the actual printing of the sheet music is “true”, while the background is “false”.
#### Result

### Point Processing
#### Source Code
```matlab

```
#### Explanation
#### Result
