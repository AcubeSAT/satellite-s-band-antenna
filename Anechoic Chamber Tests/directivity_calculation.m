% -------------------------------------
% Using 3D plot values from both slices
% -------------------------------------
% Clalculate step for the angles
elevation_step = abs(elevation(1) - elevation(2));
azimuth_step = abs(azimuth(1) - azimuth(2));

% Interpolate the elevation pattern, since the measurements where taken
% with a 2 degree step instead of 1 like in azimuth
elev_pattern_interp_dB = interp1(-90:2:90, elev_pattern_dB, elevation);

% Simulate a pattern at the back
back_level_dB = 20;
el_back = elev_pattern_interp_dB - back_level_dB;
az_back = az_pattern_dB - back_level_dB;

% Calculate the pattern for the back-side
pat3D_back = patternFromSlices(el_back, 90 - elevation, az_back, ...
    azimuth, 'Method', 'CrossWeighted');
pat3D_back_lin = 10.^(pat3D_back/10);

% Calculate the 3D pattern
[pat3D, theta, phi] = patternFromSlices(elev_pattern_interp_dB, ...
    90 - elevation, az_pattern_dB, azimuth, 'Method', 'CrossWeighted');
pat3D_lin = 10.^(pat3D/10);
pat3D_lin_normalized = pat3D_lin/max(max(pat3D_lin));


% Create grid points and convert the pattern to cartesian coordinates
[phi_grid, theta_grid] = meshgrid(deg2rad(phi), deg2rad(theta));
[X, Y, Z] = sph2cart(theta_grid, phi_grid, pat3D_lin_normalized);

X = X(:);
Y = Y(:);
Z = Z(:);

pat3D_cartesian = [X Y Z];
pat3D_cartesian = unique(pat3D_cartesian, 'rows');

pat3D_shape = alphaShape(pat3D_cartesian); % Create an alpha shape of the pattern

% Plot the 3D reconstruction
figure;
plot(pat3D_shape)

% Calculate the integral
I_front = sum(pat3D_lin.*sind(theta), 'all')*deg2rad(elevation_step)...
    *deg2rad(azimuth_step);
I_back = sum(pat3D_back_lin.*sind(theta), 'all')*deg2rad(elevation_step)...
    *deg2rad(azimuth_step);

% Calculate directivity
D = 4*pi*pat3D_lin/(I_front + I_back);
D_3D_max = max(max(10*log10(D)));

% Print the results
fprintf('Directivity = %.2f dB\n', round(D_3D_max, 2));

% Clear the variables
clear I_front I_back;
clear phi theta azimuth_step elevation_step back_level_dB;
clear pat3D pat3D_surfaceArea pat3D_lin pat3D_lin_normalized pat3D_cartesian pat3D_back pat3D_back_lin;
clear xc yc X Y Z theta_grid phi_grid r_normalized elev_pattern_interp arc_length elev_pattern_lin D D_3D_max D_2D_max;
