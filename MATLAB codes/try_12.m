%% TRY 9 - 03/07/19

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

[filt_1, filt_2] = butter(2,[10, 50]/(Fs/2), 'bandpass');  %Mu range

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
    C3_right  = filter(f1, f2, eeg.imagery_right(C3, trial - 255: trial + 256));
    Cz_right  = filter(f1, f2, eeg.imagery_right(Cz, trial - 255: trial + 256));
    C4_right  = filter(f1, f2, eeg.imagery_right(C4, trial - 255: trial + 256));
    FDP_right = filter(f1, f2, eeg.imagery_right(FDP, trial - 255: trial + 256));
    %Bandpass filter
    C3_right = filter(filt_1, filt_2, C3_right);
    Cz_right = filter(filt_1, filt_2, Cz_right);
    C4_right = filter(filt_1, filt_2, C4_right);
    FDP_right = filter(filt_1, filt_2, FDP_right);
    
    %Negative Class
    %Notch filter
    C3_left   = filter(f1, f2, eeg.imagery_left(C3, trial - 255: trial + 256));
    Cz_left   = filter(f1, f2, eeg.imagery_left(Cz, trial - 255: trial + 256));
    C4_left   = filter(f1, f2, eeg.imagery_left(C4, trial - 255: trial + 256));
    FDP_left  = filter(f1, f2, eeg.imagery_left(FDP, trial - 255: trial + 256));
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

data = [[C3_FDP_right_store(1:70,:), Cz_FDP_right_store(1:70,:), C4_FDP_right_store(1:70,:)]; [C3_FDP_left_store(1:70,:), Cz_FDP_left_store(1:70,:), C4_FDP_left_store(1:70,:)]];
labels = [zeros(70, 1); ones(70, 1)];
out = [data, labels];

% [C3_opt, ~] = kpls_mrmr([C3_FDP_right_store(1:70,:); C3_FDP_left_store(1:70,:)], labels, 12, 1);
% [Cz_opt, ~] = kpls_mrmr([Cz_FDP_right_store(1:70,:); Cz_FDP_left_store(1:70,:)], labels, 12, 1);
% [C4_opt, ~] = kpls_mrmr([C4_FDP_right_store(1:70,:); C4_FDP_left_store(1:70,:)], labels, 12, 1);
% data = [C3_opt(:,1:12), Cz_opt(:,1:12), C4_opt(:,1:12)];
% out  = [data, labels];
% [data_opt, ~] = kpls_mrmr(data, labels, 12, 1);