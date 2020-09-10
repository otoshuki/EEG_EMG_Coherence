%% EEG-EMG Correlation using CMC
%KPLS - mRMR for feature selection

clear;
clc;

%% Select channels

channel_eeg = 48;
channel_emg = 68;

%% Storing data

cmc_rest_store = [];
indices_rest_store = [];
sorted_rest_store = [];
cmc_move_store = [];
indices_move_store = [];
sorted_move_store = [];
counter_our = 0;

for j = 6:6
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
        
        %Find CMC of motion of both channels and store
        move_cz = eeg.imagery_right(channel_eeg, i:i+1022);
        move_fdp = eeg.imagery_right(channel_emg, i:i+1022);
        [cmc_move, w_move] = mscohere(move_cz, move_fdp, 384, 256);
        %Skip first 3 readings
        cmc_move = cmc_move(3:length(cmc_move));
        w_move = w_move(3:length(w_move));
        %Store data
        cmc_move_store = [cmc_move, cmc_move_store];
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

%% Data

data = [cmc_rest_store, cmc_move_store]';
labels = [zeros(counter_our,1); ones(counter_our,1)];
out_cmc = [data, labels];

%% KPLS - mRMR

out_kpls = kpls_mrmr(data, labels, 20, 1);
