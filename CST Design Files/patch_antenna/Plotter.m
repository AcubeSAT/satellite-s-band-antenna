close all;

figure;
patternCustom(gain, theta_cst, phi_cst);

figure;
patternCustom(gain, theta_cst, phi_cst,'CoordinateSystem','polar',...
    'Slice','phi','SliceValue',0);

% k = find(phi_cst == 0);
% gain0 = gain(k);
% theta0 = theta_cst(k);
% Gmax = max(gain0);
% Gmin = min(gain0); 
% m = find(abs(gain0-(Gmax-3)) < 0.3);

% theta0v1 = ones(1, 30)*theta0(m(1));
% theta0v2 = ones(1, 30)*theta0(m(2));
% gainv1 = linspace(0, Gmax+2, length(theta0v1));
% 
% figure;
% polarplot(theta0v2, gainv1) 

