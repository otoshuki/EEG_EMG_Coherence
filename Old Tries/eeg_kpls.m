clear;
clc;
% Load data
load('s01.mat');
% Preliminary data
Fs = eeg.srate;
L = 1023; % Length selected for each trial
channel1 = 68;
channel2 = 48;
% Get indexes where movement starts
motion_index = find(eeg.movement_event == 1);
% Get training samples for Cz and EM channels
rest_c1 = [];
motion_c1 = [];
rest_c2 = [];
motion_c2 = [];
f = Fs*(0:L/2)/L;
% Take the fft of signal as feature vector(removing one side)
for i = motion_index
    fft_rest_c1 = single_side(fft(eeg.imagery_left(channel1, i-1023:i-1)));
    rest_c1 = [fft_rest_c1(6:100); rest_c1];
    fft_motion_c1 = single_side(fft(eeg.imagery_left(channel1, i:i+1022)));
    motion_c1 = [fft_motion_c1(6:100); motion_c1];
    fft_rest_c2 = single_side(fft(eeg.imagery_left(channel2, i-1023:i-1)));
    rest_c2 = [fft_rest_c2(6:100); rest_c2];
    fft_motion_c2 = single_side(fft(eeg.imagery_left(channel2, i:i+1022)));
    motion_c2 = [fft_motion_c2(6:100); motion_c2];
end
figure(1);
subplot(1,2,1);
plot(f(6:100), fft_motion_c1(6:100));
title('Single-sided EEG signal');
xlabel('f (Hz)')
ylabel('|P(f)|');
subplot(1,2,2);
plot(f(6:100), fft_rest_c1(6:100));
% Training data and labels
data_c1 = [rest_c1; motion_c1];
data_c2 = [rest_c2; motion_c2];
labels = [zeros(20,1); ones(20,1)];
% EM = [rest_EM; motion_EM];
B = kpls(labels, data_c1, 0);