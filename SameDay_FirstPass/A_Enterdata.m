function input_table=A_Enterdata(pathname,dataname,numGroups,condNum_in_groups,target_each_group,Num_constellations,GroupnuminCons,numComparisons,const_in_comp)

arguments
    pathname
    dataname
    numGroups='input number of groups, G';
    condNum_in_groups='Input the conditions numbers for each groups,just make them a cell array'
    target_each_group='Input the target for each groups 1 to G'
    Num_constellations='Number of constellations'
    GroupnuminCons='Group numbers in each constellation 1 to C'
    numComparisons='Number of comparisons (K).'
    const_in_comp='Constellations in each comparison 1 to K ' 
end
input_table=struct;
input_table.pathname=pathname;
input_table.dataname=dataname;
a1=struct2cell(load([pathname,dataname]));
input_table.datamatrix=a1{1};
input_table.numGroups=numGroups;
input_table.condNum_in_groups=condNum_in_groups;
input_table.target_each_group=target_each_group;
input_table.Num_constellations=Num_constellations;
input_table.GroupnuminCons=GroupnuminCons;
input_table.numComparisons=numComparisons;
input_table.const_in_comp=const_in_comp;
input_table.ElectrodeID=(1:size(input_table.datamatrix,1))';

createfolders(pathname,'Output_data');
createfolders(pathname,'Output_plots');
end


function path=createfolders(mainpath,folders_names) 
cd(mainpath);mkdir(folders_names);
path=strcat(mainpath,folders_names);
end