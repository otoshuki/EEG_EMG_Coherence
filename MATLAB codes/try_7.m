%% TRY 7 - 02/07/19

clc;
clear;
load("data/s05.mat");

%% Preliminary

Fs = eeg.srate;
eeg_channels = [14, 13, 12, 48, 49, 50, 51];
emg_ch  = 67;

%% 50Hz Notch filter

w = 50/(Fs/2)
[f1, f2] = iirnotch(w, w/100);

%% Data

indices = find(eeg.imagery_event == 1);
spc_right_store = [];
spc_left_store  = [];

for trial = indices
    spc_right_ch = [];
    spc_left_ch  = [];
    emg_right = filter(f1, f2, eeg.imagery_right(emg_ch, trial - 511: trial + 512));
    emg_left  = filter(f1, f2, eeg.imagery_left(emg_ch, trial - 511: trial + 512));
    for eeg_ch = eeg_channels
        eeg_right = filter(f1, f2, eeg.imagery_right(eeg_ch, trial - 511: trial + 512));
        eeg_left  = filter(f1, f2, eeg.imagery_left(eeg_ch, trial - 511: trial + 512));
        spc_right = spc(eeg_right, emg_right, [8, 30], Fs);
        spc_left  = spc(eeg_left, emg_left, [8, 30], Fs);
        spc_right_ch = [spc_right_ch, spc_right];
        spc_left_ch  = [spc_left_ch, spc_left];
    end
    spc_right_store = [spc_right_store; spc_right_ch];
    spc_left_store  = [spc_left_store; spc_left_ch];
    
    trial
end

data = [spc_right_store; spc_left_store];
labels = [zeros(length(indices), 1); ones(length(indices), 1)];
out = [data, labels];

[opt, feat] = kpls_mrmr(data, labels, 5, 1);