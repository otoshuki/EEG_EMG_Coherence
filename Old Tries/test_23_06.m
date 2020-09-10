%% Preliminary
clc;
clear;
load("data/s05.mat");

%% SPC data colection

Fs = 512;
eeg_channels = [14,13,12,48,49,50,51];
emg_ch = 67;

corr_right_store = [];
corr_left_store = [];
counter_our = 0;

for trial = 1:100
    corr_right_sample = [];
    corr_left_sample  = [];
    for eeg_ch = eeg_channels
        eeg_right  = eeg.imagery_right(eeg_ch, 3584*(trial-1)+1: 3584*trial);
        emg_right  = eeg.imagery_right(emg_ch, 3584*(trial-1)+1: 3584*trial);
        corr_right = spc(eeg_right, emg_right, Fs);
        corr_right_sample = [corr_right_sample, corr_right];
        
        eeg_left   = eeg.imagery_left(eeg_ch, 3584*(trial-1)+1: 3584*trial);
        emg_left   = eeg.imagery_left(emg_ch, 3584*(trial-1)+1: 3584*trial);
        corr_left  = spc(eeg_left, emg_left, Fs);
        corr_left_sample = [corr_left_sample, corr_left];
    end   
    corr_right_store = [corr_right_store; corr_right_sample];
    corr_left_store  = [corr_left_store; corr_left_sample];
end

data   = [corr_right_store; corr_left_store];
labels = [ones(100, 1); zeros(100, 1)];

%% KPLS - mR to select most relevant feature to class

%Rel_Score F-C
kpls_R = kpls(labels, data);
rel_score_fc = rel_score(data, kpls_R); 

%Sort the set
[~, sorted_indices] = sort(rel_score_fc, 'descend');

%Select the most relevant feature for right motor cortex
right_sorted = max(sorted_indices(find(sorted_indices <= 4)));

%% KPLS - MR to select least relevant feature to right

%Rel_Score F-C
kpls_R = kpls(data(:, right_sorted), data(:, 5:7));
rel_score_fc = rel_score(data(:, 5:7), kpls_R); 

%Sort the set
[~, sorted_indices] = sort(rel_score_fc, 'ascend');

left_sorted = 4 + sorted_indices(1);

%% Linear combination of SPC of these channels for classification

alpha = 1;
beta  = -1;

out_data = alpha*data(:,right_sorted) + beta*data(:,left_sorted);

classifier_data = [out_data, labels];



