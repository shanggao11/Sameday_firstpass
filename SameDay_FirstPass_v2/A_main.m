
% Define parameters.
% you can define all this parameters, like the baseline response, the
% Record_start_time...
% If you do not want to define it, just make variable
% "Self_enter_bin"='No' (Anything but not 'Yes' or 'yes' will be ok). And
% this program will use the default parameters in the same-day first-pass
% instruction. 
Self_enter_bin='No';
 bin_baseline=[-150,50];bin_response=[50,350];Record_start_time=-150;
targetinterval=[150,350]; rsp_strength_interval=[50,650];%TODO

imageonset=15; 
% note, the "imageonset" is based on 10 ms a bin, and start from 0 on the plots. 
% in same-day first-pass case, this should be set to 15. Since our
% record_start_time is -150 ms, and the stimulus onset will be 0ms(if we use 10ms bin and 0 start, the imageonset will be 15). 

A_main_compute
A_required_barplot
group_PSTH
% ————Maddie's data—————
% datapath='C:\Users\J\Desktop\carl_olson_project\SameDay_FirstPass_v2\'
% dataname='3D_data_matrix.mat'
%cond numbers in each group
%HV = high value
%LV = low value
%disk = image without ring (annulus)
%ann = image with ring (annulus)
%annulus = ring alone
% HVdisk = [11 12 21 22 31 32 41 42 51 52 61 62 71 72 81 82]
% LVdisk = [9 10 19 20 29 30 39 40 49 50 59 60 69 70 79 80]
% annulus = [7 8 17 18 27 28 37 38 47 48 57 58 67 68 77 78]
% HVann = [43 44 45 46 53 54 55 56 63 64 65 66 73 74 75 76]
% % LVann = [3]
% LVann = [3 4 5 6 13 14 15 16 23 24 25 26 33 34 35 36]
% target=[1,2,3,4,5]
% constellation1=[1,2]
% constellation3=[2,4,5]
% constellation2=[4,5]
% constellation4=[3,5]
% comparison1=[1,2]
% % comparison2=[3,4]

% _______If you want to have 80 groups, you can use the following code to generate 80 groups variable.
% for i=1:80
%     eval(['G',num2str(i),'=i'])
% condNum_in_groups{i}=eval(['G',num2str(i)]);
% end
