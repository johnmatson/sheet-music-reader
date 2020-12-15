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
![](Readme%20Images/1_unprocessed.png)

### Point Processing
#### Source Code
```matlab
I_gray = rgb2gray(I); % convert to greyscale
I_bin = imbinarize(I_gray); % threshold convert to binary image
I_inv = imcomplement(I_bin); % invert image so data is true
```
#### Explanation
Before we start looking at the image data itself, we need to pre-process the image. We start by using the rgb2gray function to convert the image from RGB to grayscale colour space, which simplifies our processing by eliminating irrelevant colour data. Next, we threshold our image to create a binary matrix using imbinarize. This function performs a sort of automatic thresholding, using Otsu’s method, to choose the threshold value that creates the most separation between the data above and below the threshold point. Finally, we invert our binary image using the imcomplement function so that the actual printing of the sheet music is “true”, while the background is “false”.
#### Result - Binary Image
![](Readme%20Images/2_binary.png)

#### Result - Binary Inverted Image
![](Readme%20Images/3_binary_inverted.png)

### Resizing
#### Source Code
```matlab
% resample image to standard resolution
[M,N] = size(I_inv);
M = round(STD_WIDTH*M/N);
N = STD_WIDTH;
I_inv = imresize(I_inv,[M,N]);
```
#### Explanation
Although this step is not strictly necessary, we found it to be instrumental in effectively processing sheet music images of different resolutions. Some of our subsequent operations rely on assumptions for the approximate number of pixels in certain image elements, such as the tremble clef. For these approximations to be accurate, we must use a standard image size. The STD_WIDTH variable is one of the constants we defined in the initial setup section. The height of the image has not been standardized, since we want to preserve the image aspect ratio without cropping or distorting the image. We then implement the imresize function to create a new image of standard size, whether our input is smaller or bigger than the standard. The imresize function resamples the image for us automatically, using bicubic interpolation by default.

### Morphological Stave Processing
#### Source Code
```matlab
% create line structuring element to find staves
stave_SE = strel('line',MIN_STAVE_WIDTH,0);
 
% erode then dilate to isolate staves
I_stave = imopen(I_inv,stave_SE);
 
% % create line structuring element to fill stave pixel gaps
stave_gap_SE = strel('line',PIXEL_SKIPS,0);
 
% dilate then erode to fill pixel gaps
I_stave = imclose(I_stave,stave_gap_SE);
```
#### Explanation
Morphological processing is a subcategory of image processing which involves the processing of an image based on pixel-neighbor comparisons, as defined by what is known as a “structuring element”. In our case, we are attempting to isolate the staves from the rest of our data. Fortunately, the staves are unique in that they contain very wide lines. To match the lines in the stave, we chose a structuring element that is itself a horizontal line. Practically what this means, is that morphological operations with this structuring element must contain horizontal lines of length MIN_STAVE_WIDTH (as defined in initial setup) to evaluate as true.

The first morphological function we implement is imopen, which actually performs two morphologic operations back-to-back: erosion and dilation. Without getting into the details of how these two processes work, suffice it to say that performing an opening removes logical ones in places where there are not enough other logical one “neighbors”, (with neighbors being defined by the structing element). After performing an opening, we are left with an image that essentially only contains the staves. Following this operation, we also perform a closing – which is the exact opposite of an opening – first executing a dilation, followed by an erosion. We perform this closing using a similar structuring element, in an attempt to heal any pixels gaps in the stave.
#### Result - Stave Image
![](Readme%20Images/4_stave.png)

### Finding Stave Coordinates
#### Source Code
```matlab
% find the vertical coordinates of each stave line
stave = 1;
line = 1;
dif_line = true;
for i = 1:M
    % record coordinate if new stave line is detected
    if I_stave(i,round(N/2)) && dif_line
        stave_coords(stave,line) = i;
        dif_line = false;
        if line >= 5
            line = 1;
            stave = stave + 1;
        else
            line = line + 1;
        end
    % reset dif_line flag after each stave line detection
    elseif ~I_stave(i,round(N/2))
        dif_line = true;
    end
end
```
#### Explanation
Now that we have isolated the stave, we proceed to parameterizing the vertical coordinates of each of five lines in each stave. Despite marginally longer code for the section, the process is very easy. We simply start in the middle of image and increment down the centre. When we identify a logical true pixel, we record its position, set a flag, and carry on. We then wait for a false pixel, which tells us we have passed that line, reset the flag, and start the process over again.
#### Result - Stave Coordinates
![](Readme%20Images/5_stave_coordinates.png)
#### Result - Line Distance
![](Readme%20Images/6_line_distance.png)

### Solving for Note Thresholds
#### Source Code
```matlab
% calculate average distance between stave lines
line_dist = 0;
[num_staves,x] = size(stave_coords);
for i = 1:num_staves
    for j = 1:4
        line_dist = line_dist + stave_coords(i,j+1) - stave_coords(i,j);
    end
end
line_dist = line_dist / (4*num_staves);

% deterine note value thresholds
thresh_dist = line_dist/2;
for i = 1:num_staves
    thresh_top = stave_coords(i,1) - (thresh_dist/2 + thresh_dist*NOTES_ABOVE);
    thresh_bot = stave_coords(i,5) + (thresh_dist*3/4 + thresh_dist*NOTES_BELOW);
    note_threshs(i,:) = [thresh_top:thresh_dist:thresh_bot];
end
```
#### Explanation
With the coordinates of each of the stave lines recorded, we can now use the stave to calculate thresholds for the vertical coordinates of each note value. First, we need to get the distance in pixel distance between each of the stave lines by taking an average. With this information and a bit of musical theory, we can compute the note thresholds. Knowing that possible note locations are centered on the stave lines, centered between the stave lines, and on or between lines – above or below the staves, we can simply create threshold points halfway between each possible note location.
#### Result - Note Value Thresholds
![](Readme%20Images/7_note_value_thresholds.png)

### Point Processing
#### Source Code
```matlab

```
#### Explanation
#### Result
