%% TRY NEW - 23-10-19

clc;
clear;

%% Load data and channels

load("data/s05.mat");
Fs = eeg.srate;
C3 = 13;    %EEG Left PMC
C4 = 50;    %EEG Right PMC
FDP = 67;   %EMG FDP Muscle

%% Required data

%Positive class
eegc3_right = eeg.movement_right(C3, :);
eegc4_right = eeg.movement_right(C4, :);
emgfdp_right = eeg.movement_right(FDP, :);
%Negative class
eegc3_left  = eeg.movement_left(C3, :);
eegc4_left  = eeg.movement_left(C4, :);
emgfdp_left  = eeg.movement_left(FDP, :);

%% Channel bands

eeg_band = [8 30];      %mu+beta band
emg_band = [30 50];

%% Notch filter

w = 50/(Fs/2);                  %50 Hz noise removal
[f1, f2] = iirnotch(w, w/100);  %Q = 100

%% Feature extraction

indices = find(eeg.movement_event == 1);

for trial = indices(1)
   %Positive class
   %Normalize and filter
   C3_right  = norm_pass(eegc3_right, trial, eeg_band, Fs, f1, f2);
   C4_right  = norm_pass(eegc4_right, trial, eeg_band, Fs, f1, f2);
   FDP_right = norm_pass(emgfdp_right, trial, emg_band, Fs, f1, f2);
   
   %Negative class
   %Normalize and filter
   C3_left  = norm_pass(eegc3_left, trial, eeg_band, Fs, f1, f2);
   C4_left  = norm_pass(eegc4_left, trial, eeg_band, Fs, f1, f2);
   FDP_left = norm_pass(emgfdp_left, trial, emg_band, Fs, f1, f2);
   
end

%% Feature selection

%% Correlation pattern

%% Classification