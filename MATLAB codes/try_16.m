%% TRY 16 - 07/08/19

% clc;
% clear;
load("data/s08.mat");

%% Preliminary

Fs = eeg.srate;
C3 = 13;    %EEG Left PMC
FDP = 67;   %EMG FDP Muscle

%% 50Hz Notch filter

w = 50/(Fs/2);
[f1, f2] = iirnotch(w, w/100);

%% Coherence-time graph for single trial

%Considering Left PMC and Right FDP Channel
eeg_right = eeg.imagery_right(C3, :);
emg_right = eeg.imagery_right(FDP, :);
r_corr_store = [];

eeg_left = eeg.imagery_left(C3, :);
emg_left = eeg.imagery_left(FDP, :);
l_corr_store = [];

%For nth trial
for n = 1:20
    eeg_r_trial = filter(f1, f2, eeg_right(Fs*7*(n-1)+Fs+1:Fs*7*n-Fs*4));
    emg_r_trial = filter(f1, f2, emg_right(Fs*7*(n-1)+Fs+1:Fs*7*n-Fs*4));
    [eeg_r_dwt, ~] = dwt(eeg_r_trial, 'db1');
    [emg_r_dwt, ~] = dwt(emg_r_trial, 'db1');
    r_corr = corrcoef(eeg_r_dwt, emg_r_dwt);
    r_corr_store = [r_corr_store; r_corr(2)];
    
    eeg_l_trial = filter(f1, f2, eeg_left(Fs*7*(n-1)+Fs+1:Fs*7*n-Fs*4));
    emg_l_trial = filter(f1, f2, emg_left(Fs*7*(n-1)+Fs+1:Fs*7*n-Fs*4));
    [eeg_l_dwt, ~] = dwt(eeg_l_trial, 'db1');
    [emg_l_dwt, ~] = dwt(emg_l_trial, 'db1');
    l_corr = corrcoef(eeg_l_dwt, emg_l_dwt);
    l_corr_store = [l_corr_store; l_corr(2)];
end

% randomize = randperm(samples);
% out = out(randomize,:);


