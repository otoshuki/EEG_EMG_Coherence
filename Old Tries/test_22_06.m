%% Preliminary

% clc;
% clear;
% load('data/s05.mat');

%% Test - EEG and EMG data plotting
% 
% eeg_right = eeg.imagery_right(13, 1:3584);
% emg_right = eeg.imagery_left(67, 1:3584);
% 
% scatter(eeg_right, emg_right);
% %Ddin't really work out well

%% Motor imagery and real movement correlation

%Butterworth filter
[f1, f2] = butter(2, [8, 12]/256, 'bandpass');
[f3, f4] = butter(2, [30, 50]/256, 'bandpass');

corr_coeff_store = [];

for i = 1:20
    
    eeg_mi = eeg.imagery_right(68, 3584*(i-1)+1:3584*i);
    eeg_rm = eeg.movement_right(68, 3584*(i-1)+1:3584*i);

    eeg_mi = filtfilt(f1, f2, double(eeg_mi));
    eeg_rm = filtfilt(f1, f2, double(eeg_rm));

    corr_coeff = corrcoef(eeg_mi, eeg_rm);
    corr_coeff = abs(corr_coeff(2));
    corr_coeff_store = [corr_coeff_store; corr_coeff];
end

%The values don't make sense
plot(1:3584, eeg.imagery_right(68, 1:3584));
hold on;
plot(1:3584, eeg.movement_right(68, 1:3584));
