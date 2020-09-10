%% 20-06-19
%SPC and KPLS-mRMR to determine most important channels
%CMC/SPC on the channel combinations for prediction

clc;
clear;

%% Select channels

channels_eeg_right = [14, 13, 12, 48];
channels_eeg_left  = [51, 50, 49, 48];
emg_ch = 67;
acc_spc_cmc = [];
Fs = 512;
f = 1:50;
%SPC on several channels to select most important ones
for sub = 46:46
    %% Storing data

    corr_right_store1 = [];
    corr_left_store1 = [];
    corr_right_store2 = [];
    corr_left_store2 = [];
    counter_our = 0;
    %Load data
    if sub < 10
        load("data/s0" + sub + ".mat");
    else
        load("data/s" + sub + ".mat");
    end  
    j = 0;
    trial = 3584;
    %Select first 80 trials for training
    for i = 1:80
        k = i*trial;
        counter_our = counter_our + 1;
        %SPC for right hand
        corr_right_sample = [];
        corr_left_sample = [];
        for eeg_ch = channels_eeg_right
            %SPC for right side eeg channels
            eeg_right = eeg.imagery_right(eeg_ch, j+1:k-1024);
            emg_right = eeg.imagery_right(emg_ch, j+1:k-1024);
            corr_right = spc(eeg_right, emg_right, Fs);
            corr_right_sample = [corr_right_sample, corr_right];
            
            eeg_left = eeg.imagery_left(eeg_ch, j+1:k-1024);
            emg_left = eeg.imagery_left(emg_ch, j+1:k-1024);
            corr_left = spc(eeg_left, emg_left, Fs);
            corr_left_sample = [corr_left_sample, corr_left]; 
        end
        corr_right_store1 = [corr_right_store1; corr_right_sample];
        corr_left_store1  = [corr_left_store1; corr_left_sample]; 
        
        %SPC for left hand
        corr_right_sample = [];
        corr_left_sample = [];
        for eeg_ch = channels_eeg_left
            eeg_left = eeg.imagery_left(eeg_ch, j+1:k-1024);
            emg_left = eeg.imagery_left(emg_ch, j+1:k-1024);
            corr_left = spc(eeg_left, emg_left, Fs);
            corr_left_sample = [corr_left_sample, corr_left];
            
            %SPC for right side eeg channels
            eeg_right = eeg.imagery_right(eeg_ch, j+1:k-1024);
            emg_right = eeg.imagery_right(emg_ch, j+1:k-1024);
            corr_right = spc(eeg_right, emg_right, Fs);
            corr_right_sample = [corr_right_sample, corr_right];
        end  
        corr_right_store2 = [corr_right_store2; corr_right_sample];
        corr_left_store2  = [corr_left_store2; corr_left_sample]; 
        
        j = k;
    end
    eeg.subject

    %% Data for channel detection

    data_right_eeg = [corr_right_store1; corr_left_store1];
    labels = [zeros(counter_our,1); ones(counter_our,1)];
    out_spc_right_eeg = [data_right_eeg, labels];

    data_left_eeg = [corr_left_store2; corr_right_store2];
    out_spc_left_eeg = [data_left_eeg, labels];

    %% KPLS-mR to select important channel combination

    [~, right_eeg] = kpls_mrmr(data_right_eeg, labels, 1, 1);
    [~, left_eeg] = kpls_mrmr(data_left_eeg, labels, 1, 1);

    %% CMC training data for SVM and KPLS-mRMR for best features
    %Uses most important EEG channel

    j = 0;
    counter_our = 0;
    f = 1:50;
    cmc_right_store = [];
    cmc_left_store = [];
    right_ch = channels_eeg_right(right_eeg);
    left_ch = channels_eeg_left(left_eeg);
    %Find the CMC of left and right movement
    for i = 1:80
        k = i*trial;
        counter_our = counter_our + 1;
        %Class 1 - Right imagery
        eeg_right = eeg.imagery_right(right_ch, j+1:k);
        emg_right = eeg.imagery_right(emg_ch, j+1:k);
        [cmc_right, f] = mscohere(eeg_right, emg_right, 512, 384, f, Fs);
        %Store data
        cmc_right_store = [cmc_right; cmc_right_store];

        %Class 2 - Left imagery
        eeg_left = eeg.imagery_left(left_ch, j+1:k);
        emg_left = eeg.imagery_left(emg_ch, j+1:k);
        [cmc_left, f] = mscohere(eeg_left, emg_left, 512, 384, f, Fs);
        %Store data
        cmc_left_store = [cmc_left; cmc_left_store];

        j = k;
    end

    data = [cmc_right_store; cmc_left_store];

    %KPLS-mRMR to select top 10 features
    [~, F_prime] = kpls_mrmr(data, labels, 10, 1);

    %% Train SVM Model

    model = fitcsvm(data(:,F_prime), labels,  'Verbose', 1, 'ScoreTransform', 'logit');

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
        eeg_right = eeg.imagery_right(right_ch, j+1:k);
        emg_right = eeg.imagery_right(emg_ch, j+1:k);
        [cmc_right, f] = mscohere(eeg_right, emg_right, 512, 384, f, Fs);
        %Store data
        cmc_right_store = [cmc_right; cmc_right_store];

        %Wrong class
        eeg_wrong = eeg.imagery_left(left_ch, j+1:k);
        emg_wrong = eeg.imagery_left(emg_ch, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        %Store data
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        %Wrong class
        eeg_wrong = eeg.imagery_left(right_ch, j+1:k);
        emg_wrong = eeg.imagery_left(emg_ch, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        %Store data
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];
        %Wrong class
        eeg_wrong = eeg.imagery_right(left_ch, j+1:k);
        emg_wrong = eeg.imagery_right(emg_ch, j+1:k);
        [cmc_wrong, f] = mscohere(eeg_wrong, emg_wrong, 512, 384, f, Fs);
        %Store data
        cmc_wrong_store = [cmc_wrong; cmc_wrong_store];

        j = k;
    end

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
    acc_spc_cmc = [acc_spc_cmc; accuracy];
end