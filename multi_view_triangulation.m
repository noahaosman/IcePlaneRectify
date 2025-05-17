function output = multi_view_triangulation(params, plotQ)

    %Calculate 3D position of marked features across 2+ frames where camera
    %undergoes a known spatial translation.
    %Standard pinhole model solved iteratively via Newton-Gauss.

    if nargin <2
        plotQ = false;
    end

    % rotation of camera coordinates
    alpha = deg2rad(params.camera_rotation(1)); % roll
    beta   = deg2rad(params.camera_rotation(2)); % yaw
    gamma   = deg2rad(params.camera_rotation(3)); % pitch
    % Rotation matrices
    Rz = [cos(alpha), -sin(alpha), 0;
          sin(alpha),  cos(alpha), 0;
               0    ,      0     , 1];
    Ry = [ cos(beta), 0, sin(beta);
                0 , 1,     0   ;
          -sin(beta), 0, cos(beta)];
    Rx = [1,     0     ,      0     ;
          0, cos(gamma), -sin(gamma);
          0, sin(gamma),  cos(gamma)];
    % Combined rotation matrix
    R = Rx * Ry * Rz;

    norm_vector = R' * [0; 0; 1];
    norm_vector = norm_vector / norm(norm_vector);
    
    s.Dx = params.tau.* norm_vector(1);
    s.Dy = params.tau.* norm_vector(2);
    s.Dz = params.tau.* norm_vector(3);
    
    
    s.N = length(params.tau);
    % Residuals:
    s.ru = @(n,x,y,z,u) params.fx* (x - s.Dx(n)) / (z - s.Dz(n)) - u(n);
    s.rv = @(n,x,y,z,v) params.fy * (y - s.Dy(n)) / (z - s.Dz(n)) - v(n);
    function R = res(s, X, u, v)
        x = X(1);
        y = X(2);
        z = X(3);
        R = [];
        for n = 1:s.N
            R = [R; s.ru(n,x,y,z,u); s.rv(n,x,y,z,v)];
        end
    end
    
    % Jacobian
    s.dru_x = @(n,x,y,z) params.fx/ (z - s.Dz(n));
    s.dru_y = @(n,x,y,z) 0;
    s.dru_z = @(n,x,y,z) -params.fx* (x - s.Dx(n)) / (z - s.Dz(n))^2;
    s.drv_x = @(n,x,y,z) 0;
    s.drv_y = @(n,x,y,z) params.fy / (z - s.Dz(n));
    s.drv_z = @(n,x,y,z) -params.fy * (y - s.Dy(n)) / (z - s.Dz(n))^2;
    function J = jacob(s, X)
        x = X(1);
        y = X(2);
        z = X(3);
        J = [];
        for n = 1:s.N
            J = [ J; 
                s.dru_x(n,x,y,z)   s.dru_y(n,x,y,z)   s.dru_z(n,x,y,z);
                s.drv_x(n,x,y,z)   s.drv_y(n,x,y,z)   s.drv_z(n,x,y,z);
                ];
        end
    end
    
    
    points = {};
    for j = 1:length(params.tau)
        points{j} = readlines(['field_data/frame_',num2str((params.tau(j))*1000,'%03.f'),'_rect.csv']);
    end
    output.points = points;
    num_features = length(points{1})-1;
    matched_features = repmat(linspace(1,num_features,num_features)',1,length(params.tau));
    
    % output.Position = zeros(size(matched_features,1),3);
    % output.point_no =  string(-1.*ones(size(matched_features,1),1));
    output.Position = [];
    output.point_no =  string([]);
    
    for i = 1:size(matched_features,1)
        % read line matched point 1 = (x1,y1) and matched point 2 = (x2,y2)
        p = zeros(2, length(params.tau));
        for j = 1:length(params.tau)
            p(:,j) = str2num(points{j}(matched_features(i,j)));
        end
        p = p';
        
        % Convert image plane coordinates to be geometrically similar to camera coordinates
        s.u = -(p(:,1)'-params.cx); 
        s.v = -(p(:,2)'-params.cy);
        
        X1 = [10; 10; 10]; % big number
        X0 = params.X0_init;
        disp(['--------',num2str(i),'--------']);
        err = norm(X1 - X0);
        it = 0;
        while err > 0.0001 && norm(X1)<10^6
        
            J = jacob(s, X0);
            r = res(s, X0, s.u, s.v);
        
            X1 = X0 - (transpose(J)*J)\transpose(J)*r;
        
            err = norm(X1 - X0);
            X0 = X1;
       
            it = it+1;
    
        end
        disp(['Position of feature ',num2str(matched_features(i,2)),':']);
        disp(1000.*X1')
    
    
        if norm(X1)<0.5
            output.Position(end+1,1:3) = 1000.*X1';
            output.point_no(end+1) = string(matched_features(i,2));
        end
    end



    if plotQ

        figure()
        hold on
        scatter3(output.Position(:,1),output.Position(:,2),output.Position(:,3))
        textscatter3(output.Position(:,1),output.Position(:,2),output.Position(:,3), output.point_no)
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        view([-2.7, 13.8]);
        
        xlim([-70,90])
        ylim([-80,80])
        zlim([100,260])
        pbaspect([1,1,1]);
        
        % view([-90,18]) % side view
        view([-180,-90]) % front view
        % view([180,0]) % top view
    end



end

