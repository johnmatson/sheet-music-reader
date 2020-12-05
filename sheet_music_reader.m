clear

% image constants
IMAGE_WIDTH = 1700;
MIN_STAVE_WIDTH = 400;
MIN_NOTE_RADIUS = 6;
CLEF_WIDTH = 100;
END_WIDTH = 10;
BOUND_HEIGHT = 40;
PIXEL_SKIPS = 3;

% music constants
FS = 4e3;
BPM = 100;
NOTE_LENGTH = BPM/60/4;
NOTES_BELOW = 4;
NOTES_ABOVE = 4;
NOTE_FREQS = [220.00 246.94 261.63 293.66 329.63 349.23 392.00 440.00 493.88 523.25 587.33 659.25 698.46 783.99 880.00 987.77 1046.50];


I = imread("Test Images/music2.jpg");

I_gray = rgb2gray(I); % convert to greyscale
I_bin = imbinarize(I_gray); % threshold convert to binary image
I_inv = imcomplement(I_bin); % invert image so background is false & print is true

% resample image to standard resolution
[M,N] = size(I_inv);
M = round(IMAGE_WIDTH*M/N);
N = IMAGE_WIDTH;
I_inv = imresize(I_inv,[M,N]);

stave_SE = strel('line',MIN_STAVE_WIDTH,0); % create line structuring element to find staves
I_stave = imopen(I_inv,stave_SE); % erode then dilate to isolate staves

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
thresh_top = stave_coords(i,1) - (thresh_dist/2 + thresh_dist*(NOTES_ABOVE));
thresh_bot = stave_coords(i,5) + (thresh_dist/2 + thresh_dist*(NOTES_BELOW));
for i = 1:num_staves
    note_threshs(i,:) = [thresh_top:thresh_dist:thresh_bot];
end

% compute stave bounds
stave_bounds = zeros(num_staves,4);
for i = 1:num_staves
    stave_bounds(i,1) = stave_coords(i,1);
    stave_bounds(i,2) = stave_coords(i,5);
    end_line = PIXEL_SKIPS;
    for j = round(N/2):-1:1
        if (~I_stave(stave_coords(i,1),j)) && (end_line <= 1)
            stave_bounds(i,3) = j;
            break
        elseif ~I_stave(stave_coords(i,1),j)
            end_line = end_line - 1;
        end
    end
    end_line = PIXEL_SKIPS;
    for j = round(N/2):N
        if (~I_stave(stave_coords(i,1),j)) && (end_line <= 1)
            stave_bounds(i,4) = j;
            break
        elseif ~I_stave(stave_coords(i,1),j)
            end_line = end_line - 1;
        end
    end
end

% compute possible note bounds
note_bounds = stave_bounds;
for i = 1:num_staves
    note_bounds(i,1) = note_bounds(i,1) - BOUND_HEIGHT;
    note_bounds(i,2) = note_bounds(i,2) + BOUND_HEIGHT;
    note_bounds(i,3) = note_bounds(i,3) + CLEF_WIDTH;
    note_bounds(i,4) = note_bounds(i,4) - END_WIDTH;
end

note_SE = strel('disk',MIN_NOTE_RADIUS); % create disk structuring element to find notes
note_coords = [];
notes = [];
for i = 1:num_staves
    % remove all data outside possible note areas for note detection
    mask_notes_pre = zeros(M,N,'logical');
    mask_notes_pre(note_bounds(i,1):note_bounds(i,2),note_bounds(i,3):note_bounds(i,4)) = true;
    I_notes_pre = I_inv & mask_notes_pre;
    
    % erode then dilate to isolate notes
    I_notes = imopen(I_notes_pre,note_SE);
    
    % find note coordinates
    note_stats = regionprops('table',I_notes,'Centroid');
    note_coords = note_stats.Centroid;
    
    % determine note values
    for j = 1:length(note_coords)
        for k = 1:(length(note_threshs(i,:))-1)
            if ((note_coords(j,2)>note_threshs(i,k)) && (note_coords(j,2)<note_threshs(i,k+1)))
                notes = [notes;k];
                break
            end
        end
    end
end
% invert so notes increase by pitch value rather than pixel value
notes = length(note_threshs(1,:)) - notes;

% generate full notes-only image for viewing
mask_notes_pre = zeros(M,N,'logical');
for i = 1:num_staves
    mask_notes_pre(note_bounds(i,1):note_bounds(i,2),note_bounds(i,3):note_bounds(i,4)) = true;
end
I_notes_pre = I_inv & mask_notes_pre;
I_notes = imopen(I_notes_pre,note_SE);

% compile notes into song
song = [];
t = 0:(1/FS):NOTE_LENGTH;
for i = 1:length(notes)
    song = [song 0.1*sin(2*pi*NOTE_FREQS(notes(i))*t)];
end

% play song
sound(song,FS);

figure
subplot(1,2,1), imshow(I_stave)
subplot(1,2,2), imshow(I_notes)
