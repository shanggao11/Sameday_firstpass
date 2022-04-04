# Same-day-First-pass-v2

v2 version can self define some parameters at the start of A_main.m.  

Using steps:

1. open A_main.m, NOTICE1: you can see 2 commands:①A_main_compute ②A_required_barplot; the first is to compute all the data and save the data, the second is save all the required plots; if you already save some plots and just want to re-run, annotating the second command will be faster. 

2. Run it, and then you will see some hints in the command window, just input the required words. 

Step1, you may see <Enter datapath:>, this is just the path where you wish to put your 3D matrix data. E.g. 'C:\Users\J\Desktop\carl_olson_project\SameDay_FirstPass\'

Step2, <Enter datafile name:>, this is just the name of that 3D matrix, e.g. '3D_data_matrix.mat'

Step3, <Enter the number of Groups: >, just the number of Groups you have, e.g. 4 

Step4, <Enter the number of Constellations: >, just the number of Constellations you have, e.g. 2

Step5, <Enter target for each group:>, this is the target defined for each group, the dimension should be the same as the number of groups, otherwise, it will generate errors. e.g. 1:4, or [1 2 3 4]

Step6, <Enter the number of Comparison: >, number of comparison, e.g. 1

After the 6 steps above, you should see a hint, <4 Groups in total>, which tells you how many groups in total, and then you will need to input the condition number in each group. 

Step7, <G1:> condition numbers of Group 1, e.g. [11 12 21 22 31 32 41 42 51 52 61 62 71 72 81 82], G2, G3... all the same.

Step8, <2 Constellations in total
Const1:> just input the group number in constellations, e.g. [1,2]

Step9, <1 Comparisons in total
Comp1:> just input the constellation number in comparison, e.g. [1,2]




NOTICE2: this program will save all you input, rerun it (if you do not close MATLAB) will not ask you to re-input informations; 
However, if you do want to change some stuff, for example, the condition number in G1, you can just <clear G1>, or just delete the G1 variable in the variable workspace. One thing you need to be aware of is that if you want to add a group number, you can delete the num_Of_Groups, but also the target, since the target has the same dimension as the number of Groups, so just delete these two variables, and you will add more groups.

After all these steps, go back to the path where your 3D matrix is, you will find two folders:1. <Output_data> 2. <Output_plots>

<Output_data>: This contains 3 things: 
1. All_variable.mat: this is just all the variables in the workspace at the last time you run this program; What is this for?: for instance, if you close your matlab accidentally, and want to run the program last time you did, you can just open this file,  and you will be able to get all the variables at the last run, also, you still can modify the conditions number of groups or other variable just like  aforementioned NOTICE2.

2. Input_information.mat: This is just all the information you input (which is the input part in the same-day first-pass instruction), however, some of the variables may not be the same as things you input. For example, the condition number in groups  will be the variable <condNum_in_groups>, which is a cell, each row means the condition number in groups, e.g. the first row, is the condition number in group 1. 
	Another thing you need to be aware of is that it contains the electrode number after winnowing. Also it shows the electrode ID that was thrown away. 

3. Data_during_computation.mat: This is just the data doing the process of computing in the instruction.

<Output_plots>: This contains 3 things: 1. Comparison_traj_plots: this is just the cosine angle trajectory plots.
2. Inter-group distance plots: this is just the inter-group distance plots 3. Mean response strength: this is just the mean response strength both for groups and constellations. 
NOTICE3: all these plots will contain the data based on raw data and normalized data, which is the name of the image file, you can explore it. 





