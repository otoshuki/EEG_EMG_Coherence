%% Preliminary
clc;
clear;
load("data/s05.mat");

%% Frequency ranges

Fs = 512;
eeg_channels = [13, 48, 50]; %C3 - Cz - C4
emg_ch = 67; %Right hand FDP
%Theta-Mu-LowBeta-Beta-HighBeta-Gamma freqnecy ranges
theta_band = [4, 8];
mu_band = [8, 12];
spc_right_theta_store = [];
spc_right_mu_store    = [];
spc_left_theta_store  = [];
spc_left_mu_store     = [];

%% SPC for each frequency range

for trial = 1:100
    spc_right_theta_sample = [];
    spc_right_mu_sample    = [];
    spc_left_theta_sample  = [];
    spc_left_mu_sample     = [];
    emg_right = eeg.imagery_right(emg_ch, 3584*(trial-1)+1: 3584*trial);
    emg_left  = eeg.imagery_left(emg_ch, 3584*(trial-1)+1: 3584*trial);
    %SPC for each channel
    for eeg_ch = eeg_channels
        eeg_right = eeg.imagery_right(eeg_ch, 3584*(trial-1)+1: 3584*trial);
        eeg_left  = eeg.imagery_left(eeg_ch, 3584*(trial-1)+1: 3584*trial);
        spc_right_theta = spc(eeg_right, emg_right, theta_band, Fs);
        spc_right_mu    = spc(eeg_right, emg_right, mu_band, Fs);
        spc_left_theta  = spc(eeg_left, emg_left, theta_band, Fs);
        spc_left_mu     = spc(eeg_left, emg_left, mu_band, Fs);
        spc_right_theta_sample = [spc_right_theta_sample, spc_right_theta];
        spc_right_mu_sample    = [spc_right_mu_sample, spc_right_mu];
        spc_left_theta_sample  = [spc_left_theta_sample, spc_left_theta];
        spc_left_mu_sample     = [spc_left_mu_sample, spc_left_mu];
    end   
    spc_right_theta_store = [spc_right_theta_store; spc_right_theta_sample];
    spc_right_mu_store    = [spc_right_mu_store; spc_right_mu_sample];
    spc_left_theta_store  = [spc_left_theta_store; spc_left_theta_sample];
    spc_left_mu_store     = [spc_left_mu_store; spc_left_mu_sample];
end

%% Training Data

data_theta = [spc_right_theta_store(1:80,:); spc_left_theta_store(1:80,:)];
data_mu    = [spc_right_mu_store(1:80,:); spc_left_mu_store(1:80,:)];
labels     = [ones(80,1); zeros(80,1)];

training_theta = [data_theta, labels];
training_mu = [data_mu, labels];

%% Training model

% model_rch = fitcsvm(data_rch, labels, 'Verbose', 1, 'ScoreTransform', 'logit');
% model_lch = fitcsvm(data_lch, labels, 'Verbose', 1, 'ScoreTransform', 'logit');

%% Test data

% data_rch = [corr_right_rch_store(81:100,:); corr_left_rch_store(81:100,:)];
% data_lch = [corr_left_lch_store(81:100,:); corr_right_lch_store(81:100,:)];
% labels = [ones(20,1); zeros(20,1)];

%% Prediction

% [pred_labels_rch, pred_score_rch] = predict(model_rch, data_rch);
% [pred_labels_lch, pred_score_lch] = predict(model_lch, data_lch);
% 
% pred = find(pred_score_rch > pred_score_lch);