
% 0 - 80 bins, 10ms 1 bin;
Groupname=cell(num_Of_Groups,1);
for i=1:num_Of_Groups
    Groupname{i}=['G',num2str(i)];
end

% % % % RAW
[raw_mat,normalized_mat]=plot_G_PSTH(obj);
plot(raw_mat')
xline(15,'r')
legend(Groupname)
xlabel('Bins (10ms a bin)');ylabel('Response(Firing rate, sp/s)')
title('Group PSTH, raw data')

saveas(gcf,[obj.pathname,'Output_plots/','Group_PSTH_raw.png'])

% % % % NORMALIZED
figure
plot(normalized_mat')
xline(15,'r')
legend(Groupname)
xlabel('Bins (10ms a bin)');ylabel('Response(Firing rate, sp/s)')
title('Group PSTH, Normalized data')
saveas(gcf,[obj.pathname,'Output_plots/','Group_PSTH_Normalized.png'])

function [raw_mat,normalized_mat]=plot_G_PSTH(obj)
G_raw_PSTH=obj.group_raw_PSTH(:,1);
G_normalized_PSTH=obj.group_normalized_PSTH(:,1);

new_raw=cellfun(@(x) mean(cell2mat(x),1),G_raw_PSTH,'UniformOutput',false);
new_normalized=cellfun(@(x) mean(cell2mat(x),1),G_normalized_PSTH,'UniformOutput',false);

raw_mat=cell2mat(new_raw);
normalized_mat=cell2mat(new_normalized);
end

