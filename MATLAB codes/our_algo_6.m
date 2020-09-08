function [pcorr] = our_algo_6(r_eeg, r_emg, Fs)
%% CWT

[cwt_eeg, f] = cwt(double(r_eeg), Fs);
[cwt_emg, f] = cwt(double(r_emg), Fs);

%% Rel-Score for label correlation

freq = find(f > 10 & f < 50)';
pcorr = [];

corr = corrcoef(abs(cwt_eeg(freq,:)'), abs(cwt_emg(freq, :)'));
pcorr = corr(2);
