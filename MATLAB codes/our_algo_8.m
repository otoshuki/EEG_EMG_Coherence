function [pcorr] = our_algo_7(r_eeg, r_emg, Fs)
%% CWT

[cwt_eeg, f] = cwt(double(r_eeg), Fs);
[cwt_emg, f] = cwt(double(r_emg), Fs);

%% KPLS_mrmr to select best freq according to time labelling

labels = [ones(length(r_emg)/2,1)*(-1); ones(length(r_emg)/2,1)];
freq = find(f > 10 & f < 50)';

[~, opt_eeg] = kpls_mrmr(abs(cwt_eeg(freq,:))', labels, 3, 1);
[~, opt_emg] = kpls_mrmr(abs(cwt_emg(freq,:))', labels, 1, 1);

pcorr = [];

for freq = opt_eeg
    corr = corrcoef(abs(cwt_eeg(freq,:)'), abs(cwt_emg(opt_emg, :)'));
    pcorr = [pcorr, corr(2)];
end
