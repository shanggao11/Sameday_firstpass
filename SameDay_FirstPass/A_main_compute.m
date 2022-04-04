

if ~exist('datapath','var') || isempty(datapath);datapath=input('Enter datapath:');end
if ~exist('dataname','var') || isempty(dataname);dataname=input('Enter datafile name:');end
if ~exist('num_Of_Groups','var') || isempty(num_Of_Groups);num_Of_Groups=input('Enter the number of Groups: ');end
if ~exist('Num_of_constellations','var') || isempty(Num_of_constellations);Num_of_constellations=input('Enter the number of Constellations: ');end
if ~exist('target','var') || isempty(target);target=input('Enter target for each group:');end
if length(target)~=num_Of_Groups; error('Enter the correct target for each group');end
if ~exist('numComparisons','var') || isempty(numComparisons);numComparisons=input('Enter the number of Comparison: ');end

% ————————————————————————
fprintf('%d Groups in total\n',num_Of_Groups)
if ~exist('condNum_in_groups','var') || isempty(condNum_in_groups)
condNum_in_groups=cell(num_Of_Groups,1);
end
for i = 1:num_Of_Groups
    if ~exist(['G',num2str(i)],'var') || isempty(eval(['G',num2str(i)]))
        g=input(['G',num2str(i),':']);
   namestr = ['G' num2str(i) '=g'];
    eval(namestr);
    condNum_in_groups{i}=eval(['G',num2str(i)]);
    end
    
end

fprintf('%d Constellations in total\n',Num_of_constellations)
if ~exist('GroupnuminCons','var') || isempty(GroupnuminCons)
GroupnuminCons=cell(Num_of_constellations,1);
end
for i = 1:Num_of_constellations
    if ~exist(['Const',num2str(i)],'var') || isempty(eval(['Const',num2str(i)]))
        k=input(['Const',num2str(i),':']);
     namestr = ['Const' num2str(i) '=k'];
    eval(namestr);
    GroupnuminCons{i}=eval(['Const',num2str(i)]);
    end
   
end

fprintf('%d Comparisons in total\n',numComparisons)
if ~exist('const_in_comp','var') || isempty(const_in_comp)
const_in_comp=cell(numComparisons,1);
end
for i = 1:numComparisons
    if ~exist(['Comp',num2str(i)],'var') || isempty(eval(['Comp',num2str(i)]))
        k=input(['Comp',num2str(i),':']);
     namestr = ['Comp' num2str(i) '=k'];
    eval(namestr);
    const_in_comp{i}=eval(['Comp',num2str(i)]);
    end
   
end

% ————————————————————————
Input_information=A_Enterdata(datapath,dataname,num_Of_Groups,condNum_in_groups,...
    target,Num_of_constellations,GroupnuminCons,numComparisons,const_in_comp);

obj=A_winnowing(Input_information);
Input_information.Electrode_keep=obj.Electrode_keep;
Input_information.Electrode_Throwaway=obj.Electrode_throwaway;
% ————————————————————————
save([obj.pathname,'Output_data\','Input_information.mat'],'Input_information');
save([obj.pathname,'Output_data\','Data_during_computation.mat'],'obj')
save([obj.pathname,'Output_data\','All_variable.mat'])
% ————————————————————————
% A_required_barplot


% ————————————————————————
% datapath='C:\Users\J\Desktop\carl_olson_project\gs_carlproject\'
% dataname='3D_data_matrix.mat'
% HVdisk = [11 12 21 22 31 32 41 42 51 52 61 62 71 72 81 82]
% LVdisk = [9 10 19 20 29 30 39 40 49 50 59 60 69 70 79 80]
% annulus = [7 8 17 18 27 28 37 38 47 48 57 58 67 68 77 78]
% HVann = [43 44 45 46 53 54 55 56 63 64 65 66 73 74 75 76]
% % LVann = [3]
% LVann = [3 4 5 6 13 14 15 16 23 24 25 26 33 34 35 36]
% target=[1,2,3,4,5]
% constellation1=[1,2]
% constellation2=[4,5]

% constellation3=[2,4,5];
% constellation4=[3,5];

% comparison1=[1,2]
% % comparison2=[3,4]

