close all;

% Plot S21 of up and down directions
figure;
plot(Frequency,S21_down);
hold on;
plot(Frequency,S21_up);

% Plot S21 of left and right directions
figure;
plot(Frequency,S21_left);
hold on;
plot(Frequency,S21_right);

% Consider mean value of results for the two polarizations and calculate
% total S21 of circular polarization
S21_1=(S21_down+S21_up)/2;
S21_2=(S21_left+S21_right)/2;
S21_1=10.^(S21_1/20);
S21_2=10.^(S21_2/20);
S21_total=sqrt(S21_1.^2+S21_2.^2);

% Calculate the difference in path loss due to patch and horn difference in
% setup
c=3*10^8;
FSPL1=20*log10(1.4)+20*log10(Frequency*10^9)+20*log10(4*pi/c);
FSPL2=20*log10(1.69)+20*log10(Frequency*10^9)+20*log10(4*pi/c);
FSPLdif=FSPL2-FSPL1;

% Calculate patch antenna gain (considering extra path loss and 11 gain 
% for the horn antenna)
S21_test=20*log10(S21_total)-S21_horn+11+FSPLdif;

% Plot patch antenna gain
figure;
plot(Frequency,S21_test)
title('Final Gain')
xlabel('Frequency')
ylabel('dB')