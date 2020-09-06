function [features_store] = our_algo_4(r_eeg, r_emg, Fs)
%% Squaring
% p_eeg = r_eeg.^2;
% p_emg = r_emg.^2;

%% Moving window average

% sm_eeg = movmean(p_eeg, Fs);
% sm_emg = movmean(p_emg, Fs/2);

%% CWT

[cwt_eeg, f_eeg] = cwt(r_eeg, Fs);
[cwt_emg, f_emg] = cwt(r_emg, Fs);

X = normalizemeanstd(cwt_emg);
cwt_emg = X - ones(size(X,1),1) * mean(X);

X = normalizemeanstd(cwt_eeg);
cwt_eeg = X - ones(size(X,1),1) * mean(X);

%% Rel-Score for label correlation

freq_eeg = find(f_eeg > 8 & f_eeg < 12)';
freq_emg = find(f_emg > 30 & f_emg < 50)';

% labels = [ones(length(r_emg)/2,1)*(-1); ones(length(r_emg)/2,1)];
features_store = [];

for freq = freq_eeg
    %Rel_Score
    kpls_R = kpls(cwt_eeg(freq,:)', cwt_emg(freq_emg,:)');
    rel_score_emg = rel_score(cwt_emg(freq_emg,:)', kpls_R); 
    features_store = [features_store, rel_score_emg'];
end
