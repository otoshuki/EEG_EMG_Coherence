%% Preliminary
clc;
clear;
load("data/s05.mat");

%% Frequency ranges

Fs = 512;
eeg_rch = 13; %Left motor cortex
eeg_lch = 50; %Right motor cortex
emg_ch = 67; %Right hand FDP
%Theta-Mu-Lower Beta-Beta-Higher Beta-Gamma
freq_ranges = [[4,8], [8,12], [12,16], [16,20], [20,25], [25,40]];
corr_right_rch_store = [];
corr_right_lch_store = [];
corr_left_rch_store = [];
corr_left_lch_store = [];
counter_our = 0;

%% SPC for each frequency range

for trial = 1:100
    corr_right_rch_sample = [];
    corr_right_lch_sample = [];
    corr_left_rch_sample  = [];
    corr_left_lch_sample  = [];
    eeg_right_rch  = eeg.imagery_right(eeg_rch, 3584*(trial-1)+1: 3584*trial);
    eeg_right_lch  = eeg.imagery_right(eeg_lch, 3584*(trial-1)+1: 3584*trial);
    emg_right      = eeg.imagery_right(emg_ch, 3584*(trial-1)+1: 3584*trial);
    eeg_left_rch   = eeg.imagery_left(eeg_rch, 3584*(trial-1)+1: 3584*trial);
    eeg_left_lch   = eeg.imagery_left(eeg_lch, 3584*(trial-1)+1: 3584*trial);
    emg_left       = eeg.imagery_left(emg_ch, 3584*(trial-1)+1: 3584*trial);
    %SPC for each freq range
    for freq = 1:2:12
        corr_right_rch = spc(eeg_right_rch, emg_right, freq_ranges(freq:freq+1), Fs);
        corr_right_lch = spc(eeg_right_lch, emg_right, freq_ranges(freq:freq+1), Fs);
        corr_right_rch_sample = [corr_right_rch_sample, corr_right_rch];
        corr_right_lch_sample = [corr_right_lch_sample, corr_right_lch];
        corr_left_rch = spc(eeg_left_rch, emg_right, freq_ranges(freq:freq+1), Fs);
        corr_left_lch = spc(eeg_left_lch, emg_right, freq_ranges(freq:freq+1), Fs);
        corr_left_rch_sample = [corr_left_rch_sample, corr_left_rch];
        corr_left_lch_sample = [corr_left_lch_sample, corr_left_lch];
    end   
    corr_right_rch_store = [corr_right_rch_store; corr_right_rch_sample];
    corr_right_lch_store = [corr_right_lch_store; corr_right_lch_sample];
    corr_left_rch_store = [corr_left_rch_store; corr_left_rch_sample];
    corr_left_lch_store = [corr_left_lch_store; corr_left_lch_sample];
end

%% Training Data

data_rch = [corr_right_rch_store(1:80,:); corr_left_rch_store(1:80,:)];
data_lch = [corr_left_lch_store(1:80,:); corr_right_lch_store(1:80,:)];
labels = [ones(80,1); zeros(80,1)];

%% Training model

model_rch = fitcsvm(data_rch, labels, 'Verbose', 1, 'ScoreTransform', 'logit');
model_lch = fitcsvm(data_lch, labels, 'Verbose', 1, 'ScoreTransform', 'logit');

%% Test data

data_rch = [corr_right_rch_store(81:100,:); corr_left_rch_store(81:100,:)];
data_lch = [corr_left_lch_store(81:100,:); corr_right_lch_store(81:100,:)];
labels = [ones(20,1); zeros(20,1)];

%% Prediction

[pred_labels_rch, pred_score_rch] = predict(model_rch, data_rch);
[pred_labels_lch, pred_score_lch] = predict(model_lch, data_lch);

pred = find(pred_score_rch > pred_score_lch);