function [rel] = our_algo(r_eeg, r_emg, Fs)
%% Butterworth filters

[eeg_filt1, eeg_filt2] = butter(2,[8, 30]/(Fs/2), 'bandpass');  %Mu range
[emg_filt1, emg_filt2] = butter(2,[30, 50]/(Fs/2), 'bandpass');
b_eeg = filtfilt(eeg_filt1, eeg_filt2, double(r_eeg));
b_emg = filtfilt(emg_filt1, emg_filt2, double(r_emg));

%% Squaring
p_eeg = b_eeg.^2;
p_emg = b_emg.^2;

%% Moving window average

sm_eeg = movmean(p_eeg, Fs);
sm_emg = movmean(p_emg, Fs/2);

%% CWT

% cwt_eeg = cwt(sm_eeg);
% cwt_emg = cwt(sm_emg);

%% FFT along time scale

features_eeg = [];
features_emg = [];


for ini = 1:128:(length(r_eeg)-128)
    fft_eeg = single_side(fft(sm_eeg(ini:ini+255)));
    fft_emg = single_side(fft(sm_eeg(ini:ini+255)));
    [~, feat_eeg] = max(fft_eeg(8:30));
    [~, feat_emg] = max(fft_emg(30:50));
    features_eeg = [features_eeg; feat_eeg + 7];
    features_emg = [features_emg; feat_emg + 29];  
end
    
%% Rel-Score for correlation

%Rel_Score F-C
kpls_R = kpls(features_emg, features_eeg);
rel = rel_score(features_eeg, kpls_R); 
