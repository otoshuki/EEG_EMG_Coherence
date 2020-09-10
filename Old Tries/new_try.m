%% EEG-EMG Correlation using CMC
clc;
clear;
Fs = 512;
f = 1:50;
acc_cmc = [];
for sub = 1:52
    %% Storing data

    cmc_right_store = [];
    cmc_left_store = [];
    counter_our = 0;
    cmc_wrong_store = [];
    % 5 - 100
    % 8 - 85
    % Load data
    if sub < 10
        load("data/s0" + sub + ".mat");
    else
        load("data/s" + sub + ".mat");
    end    
    j = 0;
    trial = 3584;
    
    %Find the CMC of left and right movement
    for i = 1:80
        k = i*trial;
        counter_our = counter_our + 1;
        %Class 1 - Right imagery
        eeg_right = eeg.imagery_right(13, j+1:k);
        emg_right = eeg.imagery_right(67, j+1:k);
        [cmc_right, f] = mscohere(eeg_right, emg_right, 512, 384, f, Fs);
        %Store data
        cmc_right_store = [cmc_right; cmc_right_store];
        
%         %Class 2 - Left imagery
%         eeg_left = eeg.imagery_left(50, j+1:k);
%         emg_left = eeg.imagery_left(67, j+1:k);
%         [cmc_left, f] = mscohere(eeg_left, emg_left, 512, 384, f, Fs);
%         %Store data
%         cmc_left_store = [cmc_left; cmc_left_store];

        %Wrong class
        eeg_wrong = eeg.imagery_left(50, j+1:k);
        emg_wrong = eeg.imagery_left(67, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        %Wrong class
        eeg_wrong = eeg.imagery_left(13, j+1:k);
        emg_wrong = eeg.imagery_left(67, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        %Wrong class
        eeg_wrong = eeg.imagery_right(50, j+1:k);
        emg_wrong = eeg.imagery_right(67, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        j = k;
    end
    eeg.subject
    %% Plot graph
    % 
    % figure(1);
    % plot(f, cmc_right_store(12,:), 'red');
    % title('Coherenece estimate for rest and motion(10th sample)');
    % xlabel('Frequency(Hz)')
    % ylabel('MS Coehrence');
    % hold on;
    % plot(f, cmc_right_store(12,:), 'r*');
    % plot(f, cmc_left_store(12,:), 'blue');
    % plot(f, cmc_left_store(12,:), 'b*');
    % hold off;

    %% Data

    data = [cmc_right_store(1:80,:); cmc_wrong_store(1:80,:)];
    labels = [zeros(80,1); ones(80,1)];
    out_cmc = [data, labels];

    % mu_data = [cmc_right_store(:,8:12); cmc_left_store(:,8:12)];
    % beta_data = [cmc_right_store(:,16:24); cmc_left_store(:,16:24)];
    % mu_beta_data = [mu_data, beta_data];
    % 
    % out_mu = [mu_data, labels];
    % out_beta = [beta_data, labels];
    % out_mu_beta = [mu_beta_data, labels];

    %% KPLS - mRMR

    [out_kpls, F_prime] = kpls_mrmr(data, labels, 10, 1);

    %% SVM Model

    %model = fitcsvm(out_kpls(:,1:10), labels, 'KernelFunction', 'linear', 'Verbose', 1, 'ScoreTransform', 'logit');
    model = fitcsvm(out_kpls(:,1:10), labels, 'ScoreTransform', 'logit');

    %% Predict

    cmc_right_store = [];
    cmc_wrong_store = [];
    counter_our = 0;
    j = 80*trial;
    %Find the CMC of left and right movement
    for i = 81:100
        k = i*trial;
        counter_our = counter_our + 1;
        %Right hand imagery - correct class
        eeg_right = eeg.imagery_right(13, j+1:k);
        emg_right = eeg.imagery_right(67, j+1:k);
        [cmc_right, f] = mscohere(eeg_right, emg_right, 512, 384, f, Fs);
        %Store data
        cmc_right_store = [cmc_right; cmc_right_store];

        %Wrong class
        eeg_wrong = eeg.imagery_left(50, j+1:k);
        emg_wrong = eeg.imagery_left(67, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        %Store data
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        %Wrong class
        eeg_wrong = eeg.imagery_left(13, j+1:k);
        emg_wrong = eeg.imagery_left(67, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        %Store data
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        %Wrong class
        eeg_wrong = eeg.imagery_right(50, j+1:k);
        emg_wrong = eeg.imagery_right(67, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        %Store data
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];

        j = k;
    end

    %% Prediction

    new_data = [cmc_right_store; cmc_wrong_store];
    new_data = new_data(:,F_prime);
    [predicted_labels, predicted_score] = predict(model, new_data);

    positive_indexes = find(predicted_score(:,1)>0.75);
    out_labels = ones(80,1);
    out_labels(positive_indexes) = 0;

    actual_labels = [zeros(20,1); ones(60,1)];
    loss = sum(abs(out_labels-actual_labels));
    accuracy = (60-loss)*100/60;
    disp("Accuracy = " + accuracy + " %");
    acc_cmc = [acc_cmc; accuracy];
end

