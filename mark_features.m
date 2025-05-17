% Clear environment
clear; clc; close all;

% --- Load the image ---
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif','Image Files (*.jpg, *.png, *.bmp, *.tif)'}, ...
    'Select an image');
if isequal(filename,0)
   disp('User canceled file selection.');
   return;
end

img = imread(fullfile(pathname, filename));
imshow(img); hold on;
title('Click on features. Press Enter when done.');

% --- Click features ---
[x, y] = ginput();  

% --- Annotate the image ---
numPoints = length(x);
coords = zeros(numPoints, 2); % [x, y]
for i = 1:numPoints
    coords(i,:) = [round(x(i)), round(y(i))];
    scatter(x(i),y(i),'r')
    % text(x(i), y(i), sprintf('%d (%d,%d)', i, round(x(i)), round(y(i))), ...
    %      'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
    text(x(i), y(i), sprintf('%d', i), 'Color', 'yellow', 'FontSize', 12, 'FontWeight', 'bold');
end

% --- Save the annotated image ---
annotatedImgFile = fullfile(pathname, [filename(1:end-4), '_annotated.png']);
frame = getframe(gca);  % Capture current axes
imwrite(frame.cdata, annotatedImgFile);  % Save to file

fprintf('Annotated image saved to %s\n', annotatedImgFile);

% --- Save coordinates to CSV ---
outputFile = fullfile(pathname, [filename(1:end-4),'.csv']);
writematrix(coords, outputFile);

fprintf('Saved %d points to %s\n', numPoints, outputFile);


