function [rel_score_eeg_emg] = our_algo_4(r_eeg, r_emg, Fs)
%% Squaring
% p_eeg = r_eeg.^2;
% p_emg = r_emg.^2;

%% Moving window average

% sm_eeg = movmean(p_eeg, Fs);
% sm_emg = movmean(p_emg, Fs/2);

%% Wavelet Coherence

[wcoh,~,f] = wcoherence(r_eeg,r_emg,Fs);

%% Rel-Score for label correlation

freqs = find(f > 8 & f < 30)';

labels = [ones(length(r_emg)/2,1)*(-1); ones(length(r_emg)/2,1)];

%Rel_Score
kpls_R = kpls(labels, wcoh');
rel_score_eeg_emg = rel_score(wcoh', kpls_R); 
