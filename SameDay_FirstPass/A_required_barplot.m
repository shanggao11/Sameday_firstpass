


tic
raw_savename='Groups_raw response strength bar plot';
raw_titlename='Raw Response strength for each Groups ';

normalized_savename='Groups_Normalized response strength bar plot';
normalized_titlename='Normalized Response strength for each Groups';
savefoldername='Mean response strength/';

xlabelname='Groups';
ylabelname='Firing rate (spikescount/s)';

Groupname=cell(num_Of_Groups,1);
for i=1:num_Of_Groups
    Groupname{i}=['G',num2str(i)];
end

constname=cell(Num_of_constellations,1);
for i=1:Num_of_constellations
    constname{i}=['const',num2str(i)];
end

% % ——↓ Run functions 
get_MRS_bar_group(obj,savefoldername,Groupname,obj.group_rsp_strength_raw,raw_savename,raw_titlename,xlabelname,ylabelname)
get_MRS_bar_group(obj,savefoldername,Groupname,obj.group_rsp_strength_normalized,normalized_savename,normalized_titlename,xlabelname,ylabelname)
get_MRS_bar_group(obj,savefoldername,constname,obj.const_rsp_strength_raw,'consts_raw rsp strength bar plot','raw rsp strength for each constellation'...
    ,'constellations');
get_MRS_bar_group(obj,savefoldername,constname,obj.const_rsp_strength_normalized,'consts_normalized rsp strength bar plot','normalized rsp strength for each constellation'...
    ,'constellations');

plot_inter_distance(obj,'Inter-group distance plots/')

get_all_avg_cosine_PSTH(obj,'Comparison_traj_plots/','raw')
get_all_avg_cosine_PSTH(obj,'Comparison_traj_plots/','normalized')
% % ——↑


% msgbox('Mission completed !')

toc
function get_all_avg_cosine_PSTH(obj,savefoldername,raw_or_normalized)
const_in_comp=obj.const_in_comp;
constindex=size(const_in_comp,1);
for i=1:constindex
get_avg_cosine_angle(obj,savefoldername,raw_or_normalized,i)
end
end

function get_avg_cosine_angle(obj,savefoldername,raw_or_normalized,which_comparison) 
pathname=[obj.pathname,'Output_plots/'];
const_in_comp=obj.const_in_comp;
switch raw_or_normalized
    case 'raw'
        data=obj.const_avg_cosine_PSTH_raw;
    case 'normalized'
        data=obj.const_avg_cosine_PSTH_normalized;
end
constnum=const_in_comp{which_comparison,:}; 
for i=constnum
plot(data{i,1})
hold on
end
xline(15,'r')
xlim auto
ylim auto
xlabel('Time bin (one bin=10ms)')
ylabel('Cosine angle between group bin vector and target vector')
title([raw_or_normalized,', average cosine PSTH for comparison:',num2str(which_comparison)])

savename=['avg_cosine_plots for comparison',num2str(which_comparison),'_',raw_or_normalized];
for i=1:length(constnum)
    lgd{i}=['constellation:',num2str(constnum(i))];
end
legend(lgd,'Location','best');

createfolders(pathname,savefoldername);
% exportgraphics(gcf,[pathname,savefoldername,savename,'.png'],'Resolution',700)
saveas(gcf,[pathname,savefoldername,savename,'.png'])
fprintf('img save done\n')
hold off
end
function plot_inter_distance(obj,savefoldername)
distances_raw=obj.const_raw_distance;
distances_norm=obj.const_normalized_distance;
for i=1:size(distances_raw,1)
gp_name=distances_raw{i}(:,2);
gp_dis_raw=cell2mat(distances_raw{i}(:,1));
gp_dis_norm=cell2mat(distances_norm{i}(:,1));
get_MRS_bar_group(obj,savefoldername,gp_name,gp_dis_raw,['consts_raw_inter-group distance bar plot',num2str(i)],['Raw inter-group distance for constellation:',num2str(i)]...
    ,'Groups in constellation','Group distance');
get_MRS_bar_group(obj,savefoldername,gp_name,gp_dis_norm,['consts_normalized_inter-group distance bar plot',num2str(i)],['Normalized inter-group distance for constellation:',num2str(i)]...
    ,'Groups in constellation','Group distance');
end

end


function get_MRS_bar_group(obj,savefoldername,group_names,MRS,savename,titlename,xlabelname,ylabelname) %MRS: mean response strength
arguments
    obj
    savefoldername
    group_names
    MRS
    savename
    titlename
    xlabelname
    ylabelname='Firing rate (spikescount/s)';
end
if isempty(group_names)
    group_names=(1:size(obj.GroupnuminCons));
end
% define var
pathname=[obj.pathname,'Output_plots/'];
% 

figure('Visible','off')
Rsp_strenght=MRS;
X=categorical(group_names');X = reordercats(X,group_names');
b=bar(X,Rsp_strenght,0.2);
title({[titlename];['        ']})
xlabel(xlabelname)
ylabel(ylabelname)
xtips1 = b.XEndPoints;
ytips1 = b.YEndPoints;
labels1 = string(b.YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom')
xlim('auto')
% ylim('tickaligned') %%%%%%%%%%%
axis auto
createfolders(pathname,savefoldername);
% exportgraphics(gcf,[pathname,savefoldername,savename,'.png'],'Resolution',700)
saveas(gcf,[pathname,savefoldername,savename,'.png'])
fprintf('img save done\n')
end


function path=createfolders(mainpath,folders_names)
cd(mainpath);mkdir(folders_names);
path=strcat(mainpath,folders_names);
end

