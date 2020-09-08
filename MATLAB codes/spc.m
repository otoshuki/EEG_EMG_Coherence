function corr = spc(eeg, emg, freq_range, Fs)
%% Butterworth filters

% [eeg_filt1, eeg_filt2] = butter(2,freq_range/(Fs/2), 'bandpass');
% [emg_filt1, emg_filt2] = butter(2,[30, 50]/(Fs/2), 'bandpass');
% b_eeg = filtfilt(eeg_filt1, eeg_filt2, double(eeg));
% b_emg = filtfilt(emg_filt1, emg_filt2, double(emg));

%% Squaring
p_eeg = b_eeg.^2;
p_emg = b_emg.^2;

%% Moving window average

sm_eeg = movmean(p_eeg, Fs);
sm_emg = movmean(p_emg, Fs/2);

%% Correlation coefficient

corr = corrcoef(sm_eeg, sm_emg);
corr = abs(corr(2));
%corr = corr(2);