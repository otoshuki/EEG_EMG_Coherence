clc;
clear;

load('data/s18.mat');
%Create a 4th order butterworth filter @ 4-12 Hz
[f1, f2] = butter(2, [4, 12]/256, 'bandpass');


%%channel selection
eegR1=eeg.imagery_right(13:17,:);
eegR2=eeg.imagery_right(45:49,:);
eegR3=eeg.imagery_right(50:54,:);
eeg_R=[eegR1;eegR2;eegR3];

eegL1=eeg.imagery_left(13:17,:);
eegL2=eeg.imagery_left(45:49,:);
eegL3=eeg.imagery_left(50:54,:);
eeg_L=[eegL1;eegL2;eegL3];

%%meanshift calculation
% R_sum=0;
% L_sum=0;
% for a=1:15
%     for b=1:3584
%         R_sum=eeg_R(a,b)+R_sum;
%         L_sum=eeg_L(a,b)+L_sum;
%       
% 
%     end
% end
% eeg_Ravg=R_sum/(3584*15);
% eeg_Lavg=L_sum/(3584*15);
% for i=1:15
%     for j=1:3584
%         if (eeg_Lavg>eeg_L(i,j))
%             new_eegL(i,j)= eeg_L(i,j) + eeg_Lavg;
%         elseif (eeg_Lavg<eeg_L(i,j))
%                 new_eegL(i,j)= eeg_L(i,j) - eeg_Lavg;
%             else
%                 new_eegL(i,j)= eeg_Lavg; 
%         end
%         if (eeg_Ravg>eeg_R(i,j))
%              new_eegR(i,j)= eeg_R(i,j) + eeg_Ravg;
%         elseif (eeg_Ravg<eeg_R(i,j))
%                 new_eegR(i,j)= eeg_R(i,j) - eeg_Ravg;
%             else
%                 new_eegR(i,j)= eeg_Ravg;
%         end
%     end
% end
%% Trials
data_L_store = [];
data_R_store = [];

for k=1:10
    eeg_right = filtfilt(f1, f2, double(eeg_R(1:15,3584*(k-1)+1:3584*k)));
    eeg_left = filtfilt(f1, f2, double(eeg_L(1:15,3584*(k-1)+1:3584*k)));
    projection = CSP(eeg_left, eeg_right);
    out = spatFilt([eeg_left,eeg_right], projection, 10);
    data_L = mean(real(out(:,1:3584)),2);
    data_R = mean(real(out(:,3585:7168)),2);
    data_L_store = [data_L_store; data_L'];
    data_R_store = [data_R_store; data_R'];
end

training_data = [data_L_store; data_R_store];
labels = [zeros(10,1); ones(10,1)];
classifier_data = [training_data, labels];
[optimal, F_prime] = kpls_mrmr(training_data, labels, 5, 1);

