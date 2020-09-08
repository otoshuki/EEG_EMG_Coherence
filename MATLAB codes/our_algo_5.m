function [pcorr] = our_algo_5(r_eeg, r_emg, Fs)
%% CWT

[cwt_eeg, f] = cwt(double(r_eeg), Fs);
[cwt_emg, f] = cwt(double(r_emg), Fs);

%% Rel-Score for label correlation

freq = find(f > 10 & f < 50)';
pcorr = [];

for f_corr = freq
    corr = corrcoef(abs(cwt_eeg(f_corr,:)'), abs(cwt_emg(f_corr, :)'));
    corr = corr(2);
    pcorr = [pcorr, corr];
end
