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
[f1, f2] = iirnotch(w, w);

%% Data

indices = find(eeg.imagery_event == 1);
C3_FDP_left_store = [];
C3_FDP_right_store = [];
C4_FDP_left_store = [];
C4_FDP_right_store = [];

for trial = indices
    %Get raw EEG and EMG data
    C3_left   = filter(f1, f2, eeg.imagery_left(C3, trial - 127:trial + 896));
    C4_left   = filter(f1, f2, eeg.imagery_left(C4, trial - 127:trial + 896));
    FDP_left  = filter(f1, f2, eeg.imagery_left(FDP, trial - 127:trial + 896));
    C3_right  = filter(f1, f2, eeg.imagery_right(C3, trial - 127:trial + 896));
    C4_right  = filter(f1, f2, eeg.imagery_right(C4, trial - 127:trial + 896));
    FDP_right = filter(f1, f2, eeg.imagery_right(FDP, trial - 127:trial + 896));
    
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