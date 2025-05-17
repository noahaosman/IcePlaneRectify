function [rectifiedImage, tform] = rectify_image(params, triang, filepath, plotQ)


    if nargin < 4
        plotQ = false;
    end


% Plane projection:

    % collect all converged features
    x = triang.Position(:,1);
    y = triang.Position(:,2);
    z = triang.Position(:,3);
    
    % create least-sum plane from those points
    A = [x, y, ones(size(x))]; 
    coeff = A \ z;
    a = coeff(1);
    b = coeff(2);
    c = coeff(3);
    z_fit = a*x + b*y + c;
    [xq, yq] = meshgrid(linspace(-80, 80), linspace(-80, 80));
    zq = a*xq + b*yq + c;

    % plot plane and features (sanity check)
    if plotQ
        hFig1 = figure();
        mesh(xq, yq, zq);
        hold on;
        scatter3(x,y,z,'or')        
        xlim([-70,90])
        ylim([-80,80])
        zlim([100,260])
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        pbaspect([1,1,1]);
        
        % view([-90,18]) % side view
        view([-180,-90]) % front view
        hold off;
    end

    % Normal vector to plane found above
    n = [a; b; -1];
    n = -n / norm(n);
    
    % Create orthonormal basis
    v0 = [0; 1; 0];
    if abs(dot(n, v0)) > 0.9
        v0 = [1; 0; 0]; % avoid being parallel
    end
    u = cross(v0, n); 
    u = u / norm(u);
    v = cross(n, u);
    
    R = [u, v, n];
    
    K = [params.fx, 0,     params.cx;
            0,     params.fy, params.cy;
            0,     0,     1];
    H = K * R * inv(K);
    
    image = imread(filepath);
    tform = projective2d(H');
    rectifiedImage = imwarp(image, tform);

end

