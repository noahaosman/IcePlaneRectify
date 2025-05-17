function scale_mm_per_pixel = calculate_scale(triang,filepath, rectifiedImage, tform, plotQ)

    if nargin < 3
        plotQ=false;
    end

    image = imread(filepath);
    num_points = length(triang.points{1})-1;
    img_size = size(image);  % original image size
    test_img = zeros(img_size);
    
    % Convert all points and plot them on the image
    for i = 1:num_points
        pt = flipud(str2num(triang.points{1}(i))');  % [row; col]
        test_img(pt(1), pt(2)) = 255;  % mark white pixel
    end
    
    % Rectify
    test_img_rect = imwarp(test_img, tform);
    
    % Label blobs
    labeled = bwlabel(test_img_rect);
    props = regionprops(labeled, 'Centroid');
    
    % Extract all centroids
    centroids = cat(1, props.Centroid);
    num_points = size(triang.Position, 1);
    scales = [];
    
    for i = 1:num_points
        for j = i+1:num_points
            % Real-world 3D distance (mm)
            P1 = triang.Position(i, :);
            P2 = triang.Position(j, :);
            real_dist = norm(P1 - P2);
    
            % Rectified 2D pixel distance
            c1 = centroids(i, :);
            c2 = centroids(j, :);
            pixel_dist = norm(c1 - c2);
    
            % Skip degenerate cases
            if pixel_dist > 0
                scale = real_dist / pixel_dist;  % mm per pixel
                scales(end+1) = scale;
            end
        end
    end
    
    % Average scale
    scale_mm_per_pixel = mean(scales);

    % plot scale reference points (sanity check)
    if plotQ
        hFig2 = figure();
        figure(hFig2);
        imshow(rectifiedImage);
        hold on;
        
        for i = 1:size(centroids, 1)
            x = centroids(i, 1);
            y = centroids(i, 2);
            plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        end
        
        hold off;
    end

end



