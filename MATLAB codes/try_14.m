%% TRY 14 - 23/07/19

% clc;
% clear;
load("data/s08.mat");

%% Preliminary

Fs = eeg.srate;
C3 = 13;    %EEG Left PMC
Cz = 48;    %EEG PMC Center
C4 = 50;    %EEG Right PMC
FDP = 67;   %EMG FDP Muscle

%% 50Hz Notch filter

w = 50/(Fs/2);
[f1, f2] = iirnotch(w, w/100);

%% Coherence-time graph for single trial

%Considering Left PMC and Right FDP Channel
eeg_right = eeg.movement_right(48, :);
emg_right = eeg.movement_right(FDP, :);

%For nth trial
n = 9;
eeg_r_trial = eeg_right(Fs*7*(n-1)+1:Fs*7*n);
emg_r_trial = emg_right(Fs*7*(n-1)+1:Fs*7*n);
% [cmc_right, f] = mscohere(eeg_r_trial, emg_r_trial, 512, 128, f, Fs);

%CMC for each window
window_size  = Fs/2; %0.5 sec window
steps = Fs/4;
f = 3:50;
cmc_right_store = [];
for i = 1:steps:(Fs*6)
    [cmc_right, f] = mscohere(eeg_r_trial(i:i+Fs), emg_r_trial(i:i+Fs), window_size, 128, f, Fs); 
    cmc_right_store = [cmc_right; cmc_right_store];
end
time_axis = (1:steps:(Fs*6))/Fs;
[a,b] = max(cmc_right_store,[],2);
plot(time_axis', a);
%hold on;