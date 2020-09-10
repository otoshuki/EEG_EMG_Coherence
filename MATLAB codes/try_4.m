%% TRY 2 - 01/07/19

clc;
clear;
load("data/s05.mat");

%% Preliminary

Fs = eeg.srate;
C3 = 13;    %EEG Left PMC
C4 = 50;    %EEG Right PMC
FDP = 67;   %EMG FDP Muscle

%% 50Hz Notch filter

w = 50/(Fs/2)
[f1, f2] = iirnotch(w, w/100);

%% Bandpass filters

[eeg_filt1, eeg_filt2] = butter(2,[8, 30]/(Fs/2), 'bandpass');  %Mu range
[emg_filt1, emg_filt2] = butter(2,[30, 50]/(Fs/2), 'bandpass'); %30-50 Hz

%% Data

indices = find(eeg.imagery_event == 1);
C3_FDP_left_store = [];
C3_FDP_right_store = [];
C4_FDP_left_store = [];
C4_FDP_right_store = [];

for trial = indices
    %Positive Class
    %Notch filter
    C3_right  = filter(f1, f2, eeg.imagery_right(C3, trial - 511:trial + 1536));
    C4_right  = filter(f1, f2, eeg.imagery_right(C4, trial - 511:trial + 1536));
    FDP_right = filter(f1, f2, eeg.imagery_right(FDP, trial - 511:trial + 1536));
    %Bandpass filter
    C3_right = filtfilt(eeg_filt1, eeg_filt2, double(C3_right));
    C4_right = filtfilt(eeg_filt1, eeg_filt2, double(C4_right));
    FDP_right = filtfilt(emg_filt1, emg_filt2, double(FDP_right));
    
    %Negative Class
    %Notch filter
    C3_left   = filter(f1, f2, eeg.imagery_left(C3, trial - 511:trial + 1536));
    C4_left   = filter(f1, f2, eeg.imagery_left(C4, trial - 511:trial + 1536));
    FDP_left  = filter(f1, f2, eeg.imagery_left(FDP, trial - 511:trial + 1536));
    %Bandpass filter
    C3_left = filtfilt(eeg_filt1, eeg_filt2, double(C3_left));
    C4_left = filtfilt(eeg_filt1, eeg_filt2, double(C4_left));
    FDP_left = filtfilt(emg_filt1, emg_filt2, double(FDP_left));
    
    %Rel Scores
    C3_FDP_left  = our_algo_2(C3_left, FDP_left, Fs);
    C4_FDP_left  = our_algo_2(C4_left, FDP_left, Fs);
    C3_FDP_right = our_algo_2(C3_right, FDP_right, Fs);
    C4_FDP_right = our_algo_2(C4_right, FDP_right, Fs);
    
    %Store rel_scores
    C3_FDP_left_store  = [C3_FDP_left_store; C3_FDP_left];
    C4_FDP_left_store  = [C4_FDP_left_store; C4_FDP_left];
    C3_FDP_right_store = [C3_FDP_right_store; C3_FDP_right];
    C4_FDP_right_store = [C4_FDP_right_store; C4_FDP_right];
    
end

a = 1;
b = 0.5;
data_left  = a*C3_FDP_left_store - b*C4_FDP_left_store;
data_right = a*C3_FDP_right_store - b*C4_FDP_right_store;
data = [data_left; data_right];
labels = [zeros(length(indices), 1); ones(length(indices), 1)];
out = [data, labels];