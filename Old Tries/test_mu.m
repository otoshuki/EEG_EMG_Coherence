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

for trial = 1:100
    %Get raw EEG and EMG data
    eeg_r_raw = eeg.imagery_right(eeg_channels, 3584*(trial-1)+1:3584*trial);
    eeg_l_raw = eeg.imagery_left(eeg_channels, 3584*(trial-1)+1:3584*trial);
    emg_r_raw = eeg.imagery_right(emg_channels, 3584*(trial-1)+1:3584*trial);
    emg_l_raw = eeg.imagery_left(emg_channels, 3584*(trial-1)+1:3584*trial);
    
    %Get filtered EEG and EMG data
    eeg_r_filt = filtfilt(eegF1, eegF2, double(eeg_r_raw'))';
    eeg_l_filt = filtfilt(eegF1, eegF2, double(eeg_l_raw'))';
    emg_r_filt = filtfilt(emgF1, emgF2, double(emg_r_raw'))';
    emg_l_filt = filtfilt(emgF1, emgF2, double(emg_l_raw'))';
   
end

%% CSP on the data

