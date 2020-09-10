%% EEG-EMG Correlation using SPC
%KPLS - mRMR for feature selection

clear;
clc;

%% Select channels

channel_eeg = 48;
channel_emg = 68;

%% Butterworth filter

[filtb, filta] = butter(2,[8, 12]/512, 'bandpass');
%% Storing data

Fs = 512;
f = 1:100;
cmc_right_store = [];
cmc_left_store = [];
counter_our = 0;

data = ["s05.mat", "s08.mat", "s46.mat", "s44.mat", "s28.mat"];

for j = 6:6
    % Load data
    load("s08.mat");
    j = 0;
    trial = 3584;
    
    %Find the CMC of left and right movement
    for i = 1:20
        k = i*trial;
        counter_our = counter_our + 1;
        %Find CMC of rest of both channels and store
        eeg_right = filtfilt(filtb, filta, double(eeg.movement_right(channel_eeg, j+1:k-1024)));
        emg_right = filtfilt(filtb, filta, double(eeg.movement_right(channel_emg, j+1:k-1024)));
        [cmc_right, f] = mscohere(eeg_right, emg_right, 512, 384, f, Fs);
        %Store data
        cmc_right_store = [cmc_right; cmc_right_store];
        
        %Find CMC of motion of both channels and store
        eeg_left = filtfilt(filtb, filta, double(eeg.movement_left(channel_eeg, j+1:k-1024)));
        emg_left = filtfilt(filtb, filta, double(eeg.movement_left(channel_emg, j+1:k-1024)));
        [cmc_left, f] = mscohere(eeg_left, emg_left, 512, 384, f, Fs);
        %Store data
        cmc_left_store = [cmc_left; cmc_left_store];
        j = k;
    end
    eeg.subject
end

%% Plot graph

figure(1);
plot(f(1:50), cmc_right_store(12,1:50), 'red');
title('Coherenece estimate for rest and motion(12th sample)');
xlabel('Frequency(Hz)')
ylabel('MS Coehrence');
hold on;
plot(f(1:50), cmc_right_store(12,1:50), 'r*');
plot(f(1:50), cmc_left_store(12,1:50), 'blue');
plot(f(1:50), cmc_left_store(12,1:50), 'b*');
hold off;

%% Data

data = [cmc_right_store; cmc_left_store];
labels = [zeros(counter_our,1); ones(counter_our,1)];
out_cmc = [data, labels];

mu_data = [cmc_right_store(:,8:12); cmc_left_store(:,8:12)];
beta_data = [cmc_right_store(:,16:24); cmc_left_store(:,16:24)];
mu_beta_data = [mu_data, beta_data];

out_mu = [mu_data, labels];
out_beta = [beta_data, labels];
out_mu_beta = [mu_beta_data, labels];

%% KPLS - mRMR

%out_kpls = kpls_mrmr(data, labels, 20, 1);
