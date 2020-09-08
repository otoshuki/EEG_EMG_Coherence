%% Method -
% 1. Mu range for EEG, [30-50] range for EMG
% 2. 


%%

clc;
clear;
load("data/s05.mat");

%% Preliminary

Fs = eeg.srate;
eeg_channels = [13, 48, 50];    %C3 - Cz - C4
emg_channels = [67, 68];        %Right hand FDP - ED

%% Filters

[eegF1, eegF2]   = butter(2, [8, 12]/(Fs/2), 'bandpass');
[emgF1, emgF2] = butter(2, [30, 50]/(Fs/2), 'bandpass');

%% Filtered data

indices = find(eeg.movement_event == 1);

for trial = indices
    %Get raw EEG and EMG data
    eeg_r_raw = eeg.movement_right(eeg_channels, trial - 256:trial + 768);
    eeg_l_raw = eeg.movement_left(eeg_channels, trial - 256:trial + 768);
    emg_r_raw = eeg.movement_right(emg_channels, trial - 256:trial + 768);
    emg_l_raw = eeg.movement_left(emg_channels, trial - 256:trial + 768);
    
%     %Get filtered EEG and EMG data
%     eeg_r_filt = filtfilt(eegF1, eegF2, double(eeg_r_raw'))';
%     eeg_l_filt = filtfilt(eegF1, eegF2, double(eeg_l_raw'))';
%     emg_r_filt = filtfilt(emgF1, emgF2, double(emg_r_raw'))';
%     emg_l_filt = filtfilt(emgF1, emgF2, double(emg_l_raw'))';
   
end

%% SPC on movement data

