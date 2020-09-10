clear;
clc;

channel_eeg = 48;
channel_emg = 68;

%Storing data
cmc_rest_store = [];
indices_rest_store = [];
sorted_rest_store = [];
cmc_move_store = [];
indices_move_store = [];
sorted_move_store = [];
counter_our = 0;

for j = 5:5
    % Load data
    load("s0" + j + ".mat");
    motion_index = find(eeg.imagery_event == 1);
    %Find the CMC of rest and motion
    for i = motion_index
        counter_our = counter_our + 1;
        %Find CMC of rest of both channels and store
        rest_cz = eeg.imagery_right(channel_eeg, i-1023:i-1);
        rest_fdp = eeg.imagery_right(channel_emg, i-1023:i-1);
        [cmc_rest, w_rest] = mscohere(rest_cz, rest_fdp, 384, 256);
        %Skip first 3 readings
        cmc_rest = cmc_rest(3:length(cmc_rest));
        w_rest = w_rest(3:length(w_rest));
        %Store data
        cmc_rest_store = [cmc_rest, cmc_rest_store];
        %Sort and store top 50 frequencies
%         [~, indices_rest] = sort(cmc_rest, 'descend');
%         indices_rest_store = [w_rest(indices_rest(1:50)), indices_rest_store];
        
        %Find CMC of motion of both channels and store
        move_cz = eeg.imagery_right(channel_eeg, i:i+1022);
        move_fdp = eeg.imagery_right(channel_emg, i:i+1022);
        [cmc_move, w_move] = mscohere(move_cz, move_fdp, 384, 256);
        %Skip first 3 readings
        cmc_move = cmc_move(3:length(cmc_move));
        w_move = w_move(3:length(w_move));
        %Store data
        cmc_move_store = [cmc_move, cmc_move_store];
        %Sort and select top 50 frequencies
%         [~, indices_move] = sort(cmc_move, 'descend');
%         indices_move_store = [w_move(indices_move(1:50)), indices_move_store];
    end
    eeg.subject
end

%Plot graph
% figure(1);
% hold on;
% plot(w_rest, movmean(cmc_rest_store(:,12), 5), 'red');
% title('Coherenece estimate for rest and motion(10th sample)');
% xlabel('Normalized frequency (x pi rad/sample)')
% ylabel('MS Coehrence');
% plot(w_move, movmean(cmc_move_store(:,12), 5), 'blue');
% hold off;

%KPLS
data = [cmc_rest_store, cmc_move_store]';
labels = [zeros(counter_our,1); ones(counter_our,1)];
% [kpls_R] = kpls(labels, data);
% 
% %Rel_Score
X = normalizemeanstd(data);
normalized_X = X - ones(size(X,1),1)*mean(X);
w = pinv(normalized_X)*kpls_R;
rel_scores = calVIP(labels', kpls_R', w);

[mR, I] = max(rel_scores);
F = kpls(data[:, I], data);
F = pinv(normalized_X)*kpls_R
% S = kpls_R - F;

Rf = sum(calVIP(F', S', w))/(254);
gamma = 1
R = max(mR - gamma*Rf);


MR = min(rel_scores)


out = [data, labels];
% %