%% TRY NEW - 03-11-19

clc;
clear;

%% Load data and channels

load("data/s05.mat");
Fs = eeg.srate;
%Channels
% C5 = 14;
C3 = 13;    
% C1 = 12;
Cz = 48;
% C2 = 49;
C4 = 50;
% C6 = 51;

FDP = 67;   %EMG FDP Muscle

%% Required data

%Positive class
% eegc5_right = eeg.movement_right(C5, :);
% eegc3_right = eeg.movement_right(C3, :);
% eegc1_right = eeg.movement_right(C1, :);
% eegcz_right = eeg.movement_right(Cz, :);
% eegc2_right = eeg.movement_right(C2, :);
% eegc4_right = eeg.movement_right(C4, :);
% eegc6_right = eeg.movement_right(C6, :);
% emgfdp_right = eeg.movement_right(FDP, :);
%Negative class
% eegc5_left  = eeg.movement_left(C5, :);
% eegc3_left  = eeg.movement_left(C3, :);
% eegc1_left  = eeg.movement_left(C1, :);
% eegcz_left  = eeg.movement_left(Cz, :);
% eegc2_left  = eeg.movement_left(C2, :);
% eegc4_left  = eeg.movement_left(C4, :);
% eegc6_left  = eeg.movement_left(C6, :);
% emgfdp_left  = eeg.movement_left(FDP, :);

%% Channel bands

eeg_band = [8 28];      %mu+beta band
emg_band = [30 50];

%% Notch filter

w = 50/(Fs/2);                  %50 Hz noise removal
[f1, f2] = iirnotch(w, w/100);  %Q = 100

%% Feature extraction

indices = find(eeg.movement_event == 1);

%Storage variables
C3_r_store = [];
C4_r_store = [];
C3_l_store = [];
C4_l_store = [];

tr = 1;
for trial = indices(1)
   tr
   %Positive class
   %Normalize and filter
%    C5_right  = norm_pass(eeg.movement_right(C5, :), trial, eeg_band, Fs, f1, f2);
   C3_right  = norm_pass(eeg.movement_right(C3, :), trial, eeg_band, Fs, f1, f2);
%    C1_right  = norm_pass(eeg.movement_right(C1, :), trial, eeg_band, Fs, f1, f2);
   Cz_right  = norm_pass(eeg.movement_right(Cz, :), trial, eeg_band, Fs, f1, f2);
%    C2_right  = norm_pass(eeg.movement_right(C2, :), trial, eeg_band, Fs, f1, f2);
   C4_right  = norm_pass(eeg.movement_right(C4, :), trial, eeg_band, Fs, f1, f2);
%    C6_right  = norm_pass(eeg.movement_right(C6, :), trial, eeg_band, Fs, f1, f2);
   FDP_right = norm_pass(eeg.movement_right(FDP, :), trial, emg_band, Fs, f1, f2);
   
   %S transform on signals
%    [C5_r_st, ~, ~]  = st(C5_right, 8, 28, 1/Fs, 1);
   C3_r_st  = stran(C3_right);
%    [C1_r_st, ~, ~]  = st(C1_right, 8, 28, 1/Fs, 1);
   Cz_r_st  = stran(Cz_right);
%    [C2_r_st, ~, ~]  = st(C2_right, 8, 28, 1/Fs, 1);
   C4_r_st  = stran(C4_right);
%    [C6_r_st, ~, ~]  = st(C6_right, 8, 28, 1/Fs, 1);
   FDP_r_st = stran(FDP_right);
   
   %Time series decomposition
%    C5_r_tfd  = ifft(C5_r_st, [], 1);
   C3_r_tfd  = ifft(abs(C3_r_st), [], 1);
%    C1_r_tfd  = ifft(C1_r_st, [], 1);
   Cz_r_tfd  = ifft(abs(Cz_r_st), [], 1);
%    C2_r_tfd  = ifft(C2_r_st, [], 1);
   C4_r_tfd  = ifft(abs(C4_r_st), [], 1);
%    C6_r_tfd  = ifft(C6_r_st, [], 1);
   FDP_r_tfd = ifft(abs(FDP_r_st), [], 1);
   
   
   %Negative class
   %Normalize and filter
%    C5_left  = norm_pass(eeg.movement_left(C5, :), trial, eeg_band, Fs, f1, f2);
   C3_left  = norm_pass(eeg.movement_left(C3, :), trial, eeg_band, Fs, f1, f2);
%    C1_left  = norm_pass(eeg.movement_left(C1, :), trial, eeg_band, Fs, f1, f2);
   Cz_left  = norm_pass(eeg.movement_left(Cz, :), trial, eeg_band, Fs, f1, f2);
%    C2_left  = norm_pass(eeg.movement_left(C2, :), trial, eeg_band, Fs, f1, f2);
   C4_left  = norm_pass(eeg.movement_left(C4, :), trial, eeg_band, Fs, f1, f2);
%    C6_left  = norm_pass(eeg.movement_left(C6, :), trial, eeg_band, Fs, f1, f2);
   FDP_left = norm_pass(eeg.movement_left(FDP, :), trial, emg_band, Fs, f1, f2);
   
   %S transform on signals
%    [C5_l_st, ~, ~]  = st(C5_left, 8, 28, 1/Fs, 1);
   C3_l_st  = stran(C3_left);
%    [C1_l_st, ~, ~]  = st(C1_left, 8, 28, 1/Fs, 1);
   Cz_l_st  = stran(Cz_left);
%    [C2_l_st, ~, ~]  = st(C2_left, 8, 28, 1/Fs, 1);
   C4_l_st  = stran(C4_left);
%    [C6_l_st, ~, ~]  = st(C6_left, 8, 28, 1/Fs, 1);
   FDP_l_st = stran(FDP_left);
   
   %Time series decomposition
%    C5_l_tfd  = ifft(C5_l_st, [], 1);
   C3_l_tfd  = ifft(abs(C3_l_st), [], 1);
%    C1_l_tfd  = ifft(C1_l_st, [], 1);
   Cz_l_tfd  = ifft(abs(Cz_l_st), [], 1);
%    C2_l_tfd  = ifft(C2_l_st, [], 1);
   C4_l_tfd  = ifft(abs(C4_l_st), [], 1);
%    C6_l_tfd  = ifft(C6_l_st, [], 1);
   FDP_l_tfd = ifft(abs(FDP_l_st), [], 1);
   
   %TF correlation
%    C3_r_corr = mscohere(C3_r_tfd, FDP_r_tfd);
%    C3_r_store = [C3_r_store, sig_coh(C3_r_corr)];
% %    C4_r_corr = mscohere(C4_r_tfd, FDP_r_tfd);
% %    C4_r_store = [C4_r_store, sig_coh(C4_r_corr)];
%    C3_l_corr = mscohere(C3_l_tfd, FDP_l_tfd);
%    C3_l_store = [C3_l_store, sig_coh(C3_l_corr)];
% %    C4_l_corr = mscohere(C4_l_tfd, FDP_l_tfd);
% %    C4_l_store = [C4_l_store, sig_coh(C4_l_corr)];
   
   tr = tr + 1;
end

%% Finale

p_eeg1_r = abs(C3_r_tfd).^2;
p_eeg1_l = abs(C3_l_tfd).^2;
p_eeg2_r = abs(Cz_r_tfd).^2;
p_eeg2_l = abs(Cz_l_tfd).^2;
p_eeg3_r = abs(C4_r_tfd).^2;
p_eeg3_l = abs(C4_l_tfd).^2;
p_emg_r = abs(FDP_r_tfd).^2;
p_emg_l = abs(FDP_l_tfd).^2;

corr1_r = [];
corr1_l = [];
corr2_r = [];
corr2_l = [];
corr3_r = [];
corr3_l = [];
for i = 1:3071
    corr1 = corrcoef(p_eeg1_r(:,i),p_emg_r(:,i));
    corr1_r = [corr1_r,abs(corr1(2))];
    corr1 = corrcoef(p_eeg1_l(:,i),p_emg_l(:,i));
    corr1_l = [corr1_l,abs(corr1(2))];
    corr2 = corrcoef(p_eeg2_r(:,i),p_emg_r(:,i));
    corr2_r = [corr2_r,abs(corr2(2))];
    corr2 = corrcoef(p_eeg2_l(:,i),p_emg_l(:,i));
    corr2_l = [corr2_l,abs(corr2(2))];
    corr3 = corrcoef(p_eeg3_r(:,i),p_emg_r(:,i));
    corr3_r = [corr3_r,abs(corr3(2))];
    corr3 = corrcoef(p_eeg3_l(:,i),p_emg_l(:,i));
    corr3_l = [corr3_l,abs(corr3(2))];
end
% plot(1:3071, corr_r);
% hold on;
% plot(1:3071, corr_l);
% data = [C3_r_store';C3_l_store']; 
% labels = [ones(50,1);zeros(50,1)];
% out = [data, labels];

%Using the maximum and minimum values and frequencies as features
% [max_r, fx_r] = max(C3_r_store',[],2);
% [min_r, fn_r] = min(C3_r_store',[],2);
% [max_l, fx_l] = max(C3_l_store',[],2);
% [min_l, fn_l] = min(C3_l_store',[],2);
% 
% row_r = [max_r, min_r, fx_r, fn_r];
% row_l = [max_l, min_l, fx_l, fn_l];
% 
% data = [row_r;row_l];
% out = [data,labels];
%% Feature selection

%% Correlation pattern

%% Classification