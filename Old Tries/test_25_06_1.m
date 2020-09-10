clc;
clear;
load("data/s05.mat");

%% Preliminary

Fs = eeg.srate;
eeg_channels = [13, 48, 50];    %C3 - Cz - C4
emg_channels = [67, 68];              %Right hand FDP - ED
theta_band = [4, 8];            %Theta band - 4Hz to 8Hz
mu_band = [8, 12];              %Mu band - 8Hz to 12Hz
beta_band = [12, 30];           %Beta band - 12Hz to 30Hz

%% Filters

[muF1, muF2]        = butter(2, [4, 8]/(Fs/2), 'bandpass');
[thetaF1, thetaF2]  = butter(2, [8, 12]/(Fs/2), 'bandpass');
[betaF1, betaF2]    = butter(2, [12, 30]/(Fs/2), 'bandpass');
[emgF1, emgF2]      = butter(2, [30, 50]/(Fs/2), 'bandpass');

%% Filtered data

theta_r_data = [];
mu_r_data    = [];
beta_r_data  = [];
theta_l_data = [];
mu_l_data    = [];
beta_l_data  = [];
emg_r_data   = [];
emg_l_data   = [];


for trial = 1:100
    for eeg_ch = eeg_channels
        eeg_r = eeg.imagery_right(eeg_ch, 3584*(trial-1)+1:3584*trial);
        eeg_l = eeg.imagery_left(eeg_ch, 3584*(trial-1)+1:3584*trial);
        theta_r = filtfilt(thetaF1, thethaF2, eeg_r);
        theta_l = filtfilt(thetaF1, thethaF2, eeg_l);
    end
    for emg_ch = emg_channels
        emg_r = eeg.imagery_right(emg_ch, 3584*(trial-1)+1:3584*trial);
        emg_l = eeg.imagery_left(emg_ch, 3584*(trial-1)+1:3584*trial);
        emg_r_sample = filtfilt(emgF1, emgF2, emg_r);
        emg_l_sample = filtfilt(emgF1, emgF2, emg_l);
    end
    theta_r_data = [theta_r_data; theta_r_sample];
end

%% 

