function [features_store] = our_algo_2(r_eeg, r_emg, Fs)
%% Butterworth filters

% [eeg_filt1, eeg_filt2] = butter(2,[8, 30]/(Fs/2), 'bandpass');  %Mu range
% [emg_filt1, emg_filt2] = butter(2,[30, 50]/(Fs/2), 'bandpass');
% b_eeg = filtfilt(eeg_filt1, eeg_filt2, double(r_eeg));
% b_emg = filtfilt(emg_filt1, emg_filt2, double(r_emg));

%% Squaring
% p_eeg = r_eeg.^2;
% p_emg = r_emg.^2;

%% Moving window average

% sm_eeg = movmean(p_eeg, Fs);
% sm_emg = movmean(p_emg, Fs/2);

%% CWT

% cwt_eeg = cwt(sm_eeg);
% cwt_emg = cwt(sm_emg);

%% FFT along time scale

fft_eeg_store = [];
fft_emg_store = [];

for ini = 1:128:(length(r_eeg)-128)
    fft_eeg = single_side(fft(r_eeg(ini:ini+255)));
    fft_emg = single_side(fft(r_eeg(ini:ini+255)));
    fft_eeg_store = [fft_eeg_store; fft_eeg(8:12)];
    fft_emg_store = [fft_emg_store; fft_emg(30:50)];
end
    
%% Rel-Score for correlation

features_store = [];

for freq = 1:5
    %Rel_Score
    kpls_R = kpls(fft_eeg_store(:,freq), fft_emg_store);
    rel_score_eeg_emg = rel_score(fft_emg_store, kpls_R); 
    [~, freq_index] = max(rel_score_eeg_emg);
    features_store = [features_store, freq_index + 29];
end
