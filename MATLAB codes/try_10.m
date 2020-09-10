%% TRY 10 - 03/07/19

clc;
clear;
load("data/s05.mat");

%% Preliminary

Fs = eeg.srate;
C3 = 13;    %EEG Left PMC
Cz = 48;    %EEG PMC Center
C4 = 50;    %EEG Right PMC
FDP = 67;   %EMG FDP Muscle

%% 50Hz Notch filter

w = 50/(Fs/2);
[f1, f2] = iirnotch(w, w/100);

%% Bandpass filters

[filt_1, filt_2] = butter(2,[10, 50]/(Fs/2), 'bandpass'); 

%% Data

indices = find(eeg.imagery_event == 1);
C3_FDP_left_store = [];
C3_FDP_right_store = [];
Cz_FDP_left_store = [];
Cz_FDP_right_store = [];
C4_FDP_left_store = [];
C4_FDP_right_store = [];

for trial = indices
    %Positive Class
    %Notch filter
    C3_right  = filter(f1, f2, eeg.imagery_right(C3, trial - 511: trial + 512));
    Cz_right  = filter(f1, f2, eeg.imagery_right(Cz, trial - 511: trial + 512));
    C4_right  = filter(f1, f2, eeg.imagery_right(C4, trial - 511: trial + 512));
    FDP_right = filter(f1, f2, eeg.imagery_right(FDP, trial - 511: trial + 512));
    %Bandpass filter
    C3_right = filter(filt_1, filt_2, C3_right);
    Cz_right = filter(filt_1, filt_2, Cz_right);
    C4_right = filter(filt_1, filt_2, C4_right);
    FDP_right = filter(filt_1, filt_2, FDP_right);
    
    %Negative Class
    %Notch filter
    C3_left   = filter(f1, f2, eeg.imagery_left(C3, trial - 511: trial + 512));
    Cz_left   = filter(f1, f2, eeg.imagery_left(Cz, trial - 511: trial + 512));
    C4_left   = filter(f1, f2, eeg.imagery_left(C4, trial - 511: trial + 512));
    FDP_left  = filter(f1, f2, eeg.imagery_left(FDP, trial - 511: trial + 512));
    %Bandpass filter
    C3_left = filter(filt_1, filt_2, C3_left);
    Cz_left = filter(filt_1, filt_2, Cz_left);
    C4_left = filter(filt_1, filt_2, C4_left);
    FDP_left = filter(filt_1, filt_2, FDP_left);
    
    %Rel Scores
    C3_FDP_right = our_algo_7(C3_right, FDP_right, Fs);
    Cz_FDP_right = our_algo_7(Cz_right, FDP_right, Fs);
    C4_FDP_right = our_algo_7(C4_right, FDP_right, Fs);
    
    C3_FDP_left  = our_algo_7(C3_left, FDP_left, Fs);
    Cz_FDP_left  = our_algo_7(Cz_left, FDP_left, Fs);
    C4_FDP_left  = our_algo_7(C4_left, FDP_left, Fs);
    
    %Store rel_scores
    C3_FDP_right_store = [C3_FDP_right_store; C3_FDP_right];
    Cz_FDP_right_store = [Cz_FDP_right_store; Cz_FDP_right];
    C4_FDP_right_store = [C4_FDP_right_store; C4_FDP_right];
    
    C3_FDP_left_store  = [C3_FDP_left_store; C3_FDP_left];
    Cz_FDP_left_store  = [Cz_FDP_left_store; Cz_FDP_left];
    C4_FDP_left_store  = [C4_FDP_left_store; C4_FDP_left];
    
    trial
end

% a = 1;
% b = 0.5;
% data_left  = a*C3_FDP_left_store - b*C4_FDP_left_store;
% data_right = a*C3_FDP_right_store - b*C4_FDP_right_store;
data = [[C3_FDP_right_store, Cz_FDP_right_store, C4_FDP_right_store]; [C3_FDP_left_store, Cz_FDP_left_store, C4_FDP_left_store]];
labels = [zeros(length(indices), 1); ones(length(indices), 1)];
out = [data, labels];