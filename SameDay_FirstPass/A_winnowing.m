classdef A_winnowing
    properties
        pathname
        dataname
        datamatrix
        numGroups
        condNum_in_groups
        target_each_group
        Num_constellations
        GroupnuminCons
        numComparisons
        const_in_comp
        conditions_avg
        ElectrodeID
        Electrode_keep
        Electrode_throwaway
        rawPSTH
        normalize_PSTH
        group_combined_rawSpikes
        group_combined_NormalizedSpikes
        group_raw_PSTH
        group_normalized_PSTH
        group_raw_target_vector
        group_normalized_target_vector
        group_rsp_strength_raw
        group_rsp_strength_normalized
        const_raw_PSTH
        const_normalized_PSTH
        const_group_raw_target_vector
        const_group_normalized_target_vector
        const_rsp_strength_raw
        const_rsp_strength_normalized
        const_raw_distance
        const_normalized_distance
        avg_target_vector_in_const_raw
        avg_target_vector_in_const_normalized
        after_subtract_avg_target_vector_raw
        after_subtract_avg_target_vector_normalized
        const_smoothed_PSTH_raw
        const_smoothed_PSTH_normalized
        const_smoothed_PSTH_sub_TV_raw
        const_smoothed_PSTH_sub_TV_normalized
        const_smoothed_PSTH_sub_TV_cosinecorr_raw
        const_smoothed_PSTH_sub_TV_cosinecorr_normalized
        const_avg_cosine_PSTH_raw
        const_avg_cosine_PSTH_normalized
    end
    methods
        % _________________
        function obj=A_winnowing(input)
            arguments
                input='input the x, when you let x=Enterdata(xx)'
            end
            
            fields = fieldnames(input);
            for i = 1:length(fields)
                obj.(fields{i}) = input.(fields{i});
            end
            
            %         here is you run the function, all you can run the function in
            %         main.m :
            % remember,the sequence is important, because you cannot run
            % function without generating the basis you need.
            obj=obj.data_prepare;
            %             obj=obj.get_electrode([-150,50],[50,350],-500); % ?????TODO
            obj=obj.get_electrode([-150,50],[50,350],-150); % ?????TODO
            obj=obj.compute_raw_PSTH;% 1 means save the matrix,0 means not
            obj=obj.compute_normalized_PSTH(obj.rawPSTH);
            obj=obj.group_combine_spikes;
            obj=obj.group_combined_PSTH;
            obj=obj.compute_target_vector;
            obj=obj.group_rsp_strength;
            obj=obj.get_const_spikes;
            obj=obj.get_const_target_vector;
            obj=obj.compute_all_distance;
            obj=obj.get_const_rsp_strength;
            obj=obj.avg_target_vector(obj.const_group_raw_target_vector,'raw');% keep the same (raw or normalized)
            obj=obj.avg_target_vector(obj.const_group_normalized_target_vector,'normalized');
            obj=obj.get_smoothed_PSTH;
            obj=obj.get_CSSTV('raw');
            obj=obj.get_CSSTV('normalized');
            obj=obj.get_cosine_corr('raw');
            obj=obj.get_cosine_corr('normalized');
            obj=obj.get_avg_cosinePSTH('raw');
            obj=obj.get_avg_cosinePSTH('normalized');
        end
        % _________________
        %         here it should be able to accept empty
        %           cellfun(@isempty,a) !!
        function obj=data_prepare(obj)
            %             obj.datamatrix(:,1:2)=[];
            %             obj.condNum_in_groups(:,1)=cellfun(@(x) x-2, obj.condNum_in_groups(:,1),'UniformOutput',false);
            %            here,useless
            
            %           here's operation make [] to NaN, which make it
            %           failed to calculate, so we need to change nan to []
            %           after this.
            for i=1:size(obj.datamatrix,1) % this is for combining the trials in the specific condition
                for j=1:size(obj.datamatrix,2)
                    if size(obj.datamatrix{i,j},1)~=1
                        obj.datamatrix{i,j}=mean(obj.datamatrix{i,j}./size(obj.datamatrix{i,j},1));
                    end
                end
            end
            
            obj.datamatrix(find(cellfun(@(x) any(isnan(x)),obj.datamatrix)))={[]};% Change NaN to []
            
            obj.datamatrix=cellfun(@(x) x.*100, obj.datamatrix, 'UniformOutput',false);
        end
        
        
        
        % _________________
        function obj=get_electrode(obj,bin_baseline,bin_response,Record_start_time) % i combined all the conditions(80), TODO
            arguments
                obj
                bin_baseline=[-150,30] % 50 or 30
                bin_response=[50,350]
                Record_start_time=-150 %unit: ms TODO
            end
            
            for i=1:size(obj.datamatrix,1)
                k=obj.datamatrix(i,:);
                g=cell2mat(k'); % row num: condition，coloumn  num : bins
                avg_of_conditions=sum(g)./(size(g,1));
                obj.conditions_avg{i,1}=avg_of_conditions;
            end
            
            [t_baseline,t_response,~]=obj.time_bin_calculate_method(bin_baseline,bin_response,Record_start_time);
            %
            % set the judegement interval
            % we need -150ms~30ms, and 50ms~350ms, it is equal to -15~3, 5~35
            % (with 10 ms a bin), and it is also equal to 1:18, 20:50; 1:80 in total
            %             filter_logic_results=cellfun(@(x) obj.filter_out(x,t_baseline,t_response), obj.datamatrix,'UniformOutput',false);
            %
            filter_logic_results=filter_out(obj,obj.datamatrix,t_baseline,t_response);
            obj.Electrode_keep=find((filter_logic_results)==1);% this is the winnowing
            obj.Electrode_throwaway=obj.ElectrodeID(find((filter_logic_results)==0));
            
        end
        
        % _________________
        function [t_baseline,t_response,test_result]=time_bin_calculate_method(obj,bin_baseline,bin_response,Record_start_time,testInterval) %         ____the interval problem
            arguments
                obj
                bin_baseline=[-150,30]; %%%????, -150 -> 30, or ->50 ?
                bin_response=[50,350];
                Record_start_time=-150; %unit: ms
                %                 Record_start_time=-500; %unit: ms TODO
                testInterval=[];
            end
            if ~(isempty(bin_baseline) || isempty(bin_response))
                t_baseline=bin_baseline(1)/10+(-Record_start_time/10+1):(bin_baseline(2)/10+(-Record_start_time/10+1))-1; % original: no -1
                t_response=bin_response(1)/10+(-Record_start_time/10+1):bin_response(2)/10+(-Record_start_time/10+1);
            else
                t_baseline='define the baseline interval';t_response='define the baseline interval';
            end
            if ~isempty(testInterval)
                test_result=testInterval(1)/10+(-Record_start_time/10+1):testInterval(2)/10+(-Record_start_time/10+1);
            else
                test_result=testInterval;
            end
        end
        % _________________
        function a=filter_out(obj,rsp_all_electrode,timebin_baseline,timebin_response) % here, all the winnowing is based on:
            %             calculating the mean(baseline bins' mean and firing bins' mean) in each condition, and baseline bins' mean form a vector and firing bins' mean
            %                 form a vector, then, do the ttest2 for these two vector
            arguments
                obj
                rsp_all_electrode
                timebin_baseline=(1:19);
                timebin_response=(21:51);
            end
            for i=1:size(rsp_all_electrode,1)
                gg=rsp_all_electrode(i,:);
                
                logicalind=cellfun(@isempty,gg);
                
                f_baseline0=cellfun(@(x) x(timebin_baseline),gg(~logicalind),'UniformOutput',false);
                f_baseline1=cell2mat(cellfun(@(x) mean(x),f_baseline0,'UniformOutput',false));
                f_firing0=cellfun(@(x) x(timebin_response),gg(~logicalind),'UniformOutput',false);
                f_firing1=cell2mat(cellfun(@(x) mean(x),f_firing0,'UniformOutput',false));
                [~,p,~]=ttest2(f_baseline1,f_firing1);
                if p<0.05 && (mean(f_firing1)-mean(f_baseline1))>0
                    a(i,1)=1;
                else
                    a(i,1)=0;
                end
            end
            
            %             a=mean(rsp_one_electrode(timebin_response)) > mean(rsp_one_electrode(timebin_baseline));%%  TODO, question: what's the process
        end
        
        % _________________
        function obj=compute_raw_PSTH(obj)
            obj.rawPSTH=obj.datamatrix(obj.Electrode_keep,:); % the trial problems
            raw_PSTH=obj.rawPSTH;
        end
        
        % _________________
        function obj=compute_normalized_PSTH(obj,raw_PSTH)
            
            for i=1:size(raw_PSTH,1)
                kk=raw_PSTH(i,:); gg=cell2mat(kk');sdf=sum(mean(gg))/size(gg,2);%here, mean gg take the average of all rows: combined all the conditions
                normPSTH=cellfun(@(x) x./sdf, kk,'UniformOutput',false);
                nnPSTH(i,:)=normPSTH;
            end
            obj.normalize_PSTH=nnPSTH;
        end
        
        
        % _________________
        %         function plot_all_PSTH(obj)
        %             %         plot_raw_PSTH, prototype
        %             electrodeName=1:size(obj.rawPSTH,1);
        %             conditionsNum=1:size(obj.rawPSTH,2);
        %             for i=electrodeName
        %                 for j=conditionsNum
        %                     set(0,'DefaultFigureVisible', 'off')
        %                     plot(obj.rawPSTH{i,j});
        %                     exportgraphics(gcf,[obj.pathname,'imgs/','rawPSTH_','conditions_',num2str(j)...
        %                         ,'_electrode_',num2str(i),'.png'],'Resolution',700)   %TODO
        %                     fprintf(['plot:','conditions_',num2str(j),'_electrode_',num2str(i),'\n'])
        %                 end
        %             end
        %         end
        %
        % _________________
        function obj=group_combine_spikes(obj) % get the combined_spikes, this is the combined-spikes after classified by the groups
            %             take the whole mean
            groups=obj.condNum_in_groups;
            if size(groups,2)==2
                groupname=groups(:,2);
                groupNum=groups(:,1);
                for i = 1:size(groupNum,1)
                    obj.group_combined_rawSpikes{i,1}=obj.rawPSTH(:,groupNum{i});% this is the corresponding groupnames
                    obj.group_combined_rawSpikes{i,2}=groupNum{i};
                    obj.group_combined_rawSpikes{i,3}=groupname{i}; % this is the index for different conditions in groups
                end
                for i = 1:size(groupNum,1)
                    obj.group_combined_NormalizedSpikes{i,1}=obj.normalize_PSTH(:,groupNum{i});% this is the corresponding groupnames
                    obj.group_combined_NormalizedSpikes{i,2}=groupNum{i};
                    obj.group_combined_NormalizedSpikes{i,3}=groupname{i}; % this is the index for different conditions in groups
                end
            else
                groupNum=groups(:,1);
                for i = 1:size(groupNum,1)
                    obj.group_combined_rawSpikes{i,1}=obj.rawPSTH(:,groupNum{i});% this is the corresponding groupnames
                    obj.group_combined_rawSpikes{i,2}=groupNum{i}; % this is the index for different conditions in groups
                end
                for i = 1:size(groupNum,1)
                    obj.group_combined_NormalizedSpikes{i,1}=obj.normalize_PSTH(:,groupNum{i});% this is the corresponding groupnames
                    obj.group_combined_NormalizedSpikes{i,2}=groupNum{i};
                end
            end
            
        end
        
        function obj=group_combined_PSTH(obj)
            obj.group_raw_PSTH=combined_PSTH(obj,obj.group_combined_rawSpikes,obj.group_combined_rawSpikes);
            obj.group_normalized_PSTH=combined_PSTH(obj,obj.group_combined_NormalizedSpikes,obj.group_combined_NormalizedSpikes);
        end
        % _________________
        function kk=combined_PSTH(obj,source_combinespikes,mat)
            for i=1:size(mat,1)
                ind(i)=size(mat{i,1},2)==1;
            end
            index=find(ind==1);
            mat(:,1)=cellfun(@(x) obj.cond_mean(x),mat(:,1),'UniformOutput',false);
            for i=1:length(index)
                mat{index(i),1}=source_combinespikes{index(i),1};
            end
            kk=mat;
        end
        
        % _________________
        function a4=cond_mean(obj,m)
            for i=1:size(m,1)
                a1=m(i,:);a2=cell2mat(a1'); a3=mean(a2);a4{i,1}=a3; % the format should be strict
            end
        end
        % _________________
        % compute target vector
        function obj=compute_target_vector(obj,target,testInterval)
            arguments
                obj
                target=obj.target_each_group;
                testInterval=[150,350];
            end
            %             [t_baseline,t_response,test_result]=time_bin_calculate_method(obj,bin_baseline,bin_response,Record_start_time,testInterval)
            [~,~,test_result]=time_bin_calculate_method(obj,[],[],-150,testInterval);
            raw=obj.group_raw_PSTH;normal=obj.group_normalized_PSTH;
            if length(target)~=obj.numGroups; fprintf('\n !!Please input the correct target \n');target=1:obj.numGroups;end
            %             else
            
            for i=target
                rr(find(target==i),1)={cell2mat(cellfun(@(x) mean(x(test_result)),raw{i,1},'UniformOutput',false))};
                nn(find(target==i),1)={cell2mat(cellfun(@(x) mean(x(test_result)),normal{i,1},'UniformOutput',false))};
            end
            obj.group_raw_target_vector=rr;
            obj.group_normalized_target_vector=nn;
            %             end
        end
        % _________________
        function obj=group_rsp_strength(obj,time_interval,group_raw_PSTH,group_normalized_PSTH)
            arguments
                obj
                time_interval=[50,650];
                group_raw_PSTH=obj.group_raw_PSTH;
                group_normalized_PSTH=obj.group_normalized_PSTH;
            end
            [~,~,test_result]=time_bin_calculate_method(obj,[],[],-150,time_interval);
            if test_result(end)>80
                test_result=test_result(1):(test_result(end)-(test_result(end)-80));
            end
            for i=1:obj.numGroups
                raw=cellfun(@(x) x(test_result),group_raw_PSTH{i,1},'UniformOutput',false);
                normal=cellfun(@(x) x(test_result),group_normalized_PSTH{i,1},'UniformOutput',false);
                group_rsp_strength_raw(i,1)=mean(mean(cell2mat(raw),1));
                group_rsp_strength_normalized(i,1)=mean(mean(cell2mat(normal),1));
            end
            obj.group_rsp_strength_raw=group_rsp_strength_raw;
            obj.group_rsp_strength_normalized=group_rsp_strength_normalized;
        end
        % _________________
        function obj=get_const_spikes(obj,GroupnuminCons,group_raw_PSTH,group_normalized_PSTH)
            arguments
                obj
                GroupnuminCons=obj.GroupnuminCons
                group_raw_PSTH=obj.group_raw_PSTH
                group_normalized_PSTH=obj.group_normalized_PSTH
            end
            for i=1:size(GroupnuminCons,1)
                const_raw{i,1}=group_raw_PSTH(GroupnuminCons{i},1);
                const_raw{i,2}=GroupnuminCons{i};
            end
            for i=1:size(GroupnuminCons,1)
                const_normalized{i,1}=group_normalized_PSTH(GroupnuminCons{i},1);
                const_normalized{i,2}=GroupnuminCons{i};
            end
            obj.const_raw_PSTH=const_raw;
            obj.const_normalized_PSTH=const_normalized;
        end
        % _________________
        function obj=get_const_rsp_strength(obj,const_raw_PSTH,const_normalized_PSTH,time_interval)
            arguments
                obj
                const_raw_PSTH=obj.const_raw_PSTH
                const_normalized_PSTH=obj.const_normalized_PSTH
                time_interval=[50,650]
            end
            obj.const_rsp_strength_raw=obj.compute_const_rsp_strength(const_raw_PSTH,time_interval);
            obj.const_rsp_strength_normalized=obj.compute_const_rsp_strength(const_normalized_PSTH,time_interval);
        end
        function g3=compute_const_rsp_strength(obj,constPSTH,time_interval)
            arguments
                obj
                constPSTH='please in input const_PSTH'
                time_interval=[50,650]
            end
            [~,~,test_result]=time_bin_calculate_method(obj,[],[],-150,time_interval);
            if test_result(end)>80
                test_result=test_result(1):(test_result(end)-(test_result(end)-80));
            end
            for i = 1: obj.Num_constellations
                a=constPSTH{i,1};
                for j=1:size(a,1)
                    k=a{j,1};
                    g1=cellfun(@(x) x(test_result),k,'UniformOutput',false);
                    g2(j,1)=mean(mean(cell2mat(g1),1));
                end
                g3(i,1)=mean(g2);
            end
        end
        % _________________
        function obj=get_const_target_vector(obj,GroupnuminCons,group_raw_target_vector,group_normalized_target_vector)
            arguments
                obj
                GroupnuminCons=obj.GroupnuminCons
                group_raw_target_vector=obj.group_raw_target_vector
                group_normalized_target_vector=obj.group_normalized_target_vector
            end
            for i=1:size(GroupnuminCons,1)
                const_raw_targetV{i,1}=group_raw_target_vector(GroupnuminCons{i},1);
                const_raw_targetV{i,2}=GroupnuminCons{i};
            end
            for i=1:size(GroupnuminCons,1)
                const_normalized_targetV{i,1}=group_normalized_target_vector(GroupnuminCons{i},1);
                const_normalized_targetV{i,2}=GroupnuminCons{i};
            end
            obj.const_group_raw_target_vector=const_raw_targetV;
            obj.const_group_normalized_target_vector=const_normalized_targetV;
        end
        % _________________↓,same as the A_get_distance in the A_main
        function obj=compute_all_distance(obj,GroupnuminCons)
            arguments
                obj
                GroupnuminCons=obj.GroupnuminCons
            end
            for i=1:obj.Num_constellations
                obj.const_raw_distance{i,1}=obj.get_distance(i);%function dd=get_distance(obj,which_const,GroupnuminCons,const_TV) %TODO
            end
            
            const_TV=obj.const_group_normalized_target_vector;
            for i=1:obj.Num_constellations
                obj.const_normalized_distance{i,1}=obj.get_distance(i,GroupnuminCons,const_TV);%function dd=get_distance(obj,which_const,GroupnuminCons,const_TV) %TODO
            end
            
        end
        
        function dd=get_distance(obj,which_const,GroupnuminCons,const_TV) %TODO
            arguments
                obj
                which_const=1
                GroupnuminCons=obj.GroupnuminCons
                const_TV=obj.const_group_raw_target_vector
            end
            
            group_num_in_const=GroupnuminCons{which_const,1};
            if length(group_num_in_const)==1;
                gg{1,1}=0;
                gg{1,2}=[num2str(group_num_in_const(:))];
            else
                rank=nchoosek(group_num_in_const,2);
                for i=1:size(rank,1)
                    g_id=rank(i,:);
                    index=find(ismember(group_num_in_const,g_id));
                    rawTV=const_TV{which_const,1};
                    gg{i,1}=obj.calculate_distance(rawTV(index));
                    gg{i,2}=[num2str(g_id(1)),num2str(g_id(2))];
                end
            end
            dd=gg;
        end
        
        
        function distance=calculate_distance(obj,pair_vector)
            arguments
                obj
                pair_vector='Please enter a pair_vector'
            end
            
            if size(pair_vector,1)~=2, error('make the vector number correct');end
            r1=pair_vector{1};r2=pair_vector{2};
            distance=sqrt(sum((r1-r2).^2));
        end
        % _____Traj analysis____________
        
        function obj=avg_target_vector(obj,const_group_target_vector,raw_or_normalized)
            arguments
                obj
                const_group_target_vector=obj.const_group_raw_target_vector
                raw_or_normalized='raw'
            end
            for i=1:size(const_group_target_vector,1)
                avgg=mean(cell2mat((const_group_target_vector{i})'),2);
                TV_after_subtract_avg{i,1}=cell2mat((const_group_target_vector{i})')-avgg;
                TV_after_subtract_avg{i,2}=const_group_target_vector{i,2};
                avg_TV{i,1}=avgg;
            end
            switch raw_or_normalized
                case 'raw'
                    obj.avg_target_vector_in_const_raw=avg_TV;
                    obj.after_subtract_avg_target_vector_raw=TV_after_subtract_avg;
                case 'normalized'
                    obj.avg_target_vector_in_const_normalized=avg_TV;
                    obj.after_subtract_avg_target_vector_normalized=TV_after_subtract_avg;
            end
        end
        %         ____
        function obj=get_smoothed_PSTH(obj,const_raw,const_normalized)
            arguments
                obj
                const_raw=obj.const_raw_PSTH
                const_normalized=obj.const_normalized_PSTH
            end
            
            obj.const_smoothed_PSTH_raw=obj.compute_smoothed_PSTH(const_raw);
            obj.const_smoothed_PSTH_normalized=obj.compute_smoothed_PSTH(const_normalized);
        end
        
        function g=compute_smoothed_PSTH(obj,PSTH)
            for i=1:size(PSTH,1)
                each_const=PSTH{i,1};
                for j=1:size(each_const,1)
                    smoothed_PSTH{i,1}{j,1}=cellfun(@(x) obj.smoothing(x),each_const{j},'UniformOutput',false);
                    smoothed_PSTH{i,2}=PSTH{i,2};
                end
            end
            g=smoothed_PSTH;
        end
        
        function r=smoothing(obj,PSTH)
            % N-4 to N
            r=movmean(PSTH,[4,0]);
            % it will discard the first 4 elements (discard 40ms, -150ms→-110ms),
        end
        
        % % ____        CSSTV: const
        
        function obj=get_CSSTV(obj,raw_or_normalized)
            arguments
                obj
                raw_or_normalized='raw'
            end
            switch raw_or_normalized
                case 'raw'
                    const_smoothed_PSTH=obj.const_smoothed_PSTH_raw;
                    TV=obj.avg_target_vector_in_const_raw;
                    obj.const_smoothed_PSTH_sub_TV_raw=obj.compute_CSSTV_2(const_smoothed_PSTH,TV);
                case 'normalized'
                    const_smoothed_PSTH=obj.const_smoothed_PSTH_normalized;
                    TV=obj.avg_target_vector_in_const_normalized;
                    obj.const_smoothed_PSTH_sub_TV_normalized=obj.compute_CSSTV_2(const_smoothed_PSTH,TV);
            end
        end
        
        function kkk=compute_CSSTV_2(obj,const_smoothed_PSTH,TV)
            arguments
                obj
                const_smoothed_PSTH=obj.const_smoothed_PSTH_raw
                TV=obj.avg_target_vector_in_const_raw
            end
            for i=1:size(const_smoothed_PSTH,1)
                for j=1:size(const_smoothed_PSTH{i,1},1)
                    kkk{i,1}{j,1}=obj.compute_CSSTV_1(const_smoothed_PSTH,TV,i,j);
                end
                kkk{i,2}=const_smoothed_PSTH{i,2};
            end
            
        end
        
        function a2=compute_CSSTV_1(obj,PSTH,TV,constnum,groupnum)
            targetvector=TV{constnum,1};
            psth=PSTH{constnum,1}{groupnum,1};
            aa=cell2mat(psth)-targetvector;
            for constnum=1:size(aa,1)
                a2{constnum,1}=aa(constnum,:);
            end
        end
        % _____compute the cosine corr by cosine angle
        
        function obj=get_cosine_corr(obj,raw_or_normalized)
            arguments
                obj
                raw_or_normalized='raw'
            end
            switch raw_or_normalized
                case 'raw'
                    psth=obj.const_smoothed_PSTH_sub_TV_raw;
                    tv=obj.after_subtract_avg_target_vector_raw;
                    obj.const_smoothed_PSTH_sub_TV_cosinecorr_raw=obj.compute_cosine_3(psth,tv);
                    
                    
                case 'normalized'
                    psth=obj.const_smoothed_PSTH_sub_TV_normalized;
                    tv=obj.after_subtract_avg_target_vector_normalized;
                    obj.const_smoothed_PSTH_sub_TV_cosinecorr_normalized=obj.compute_cosine_3(psth,tv);
            end
            
        end
        
        
        function re=compute_cosine_3(obj,PSTH,TV)
            for i=1:size(PSTH,1)
                re{i,1}=obj.compute_cosine_2(PSTH,TV,i);
                re{i,2}=PSTH{i,2};
            end
        end
        
        function kk=compute_cosine_2(obj,PSTH,TV,constnum)
            psth_const=PSTH{constnum,1};
            tv_const=TV{constnum,1};
            for groupnum=1:size(psth_const,1)
                kk{groupnum,1}=obj.compute_cosine_1(psth_const,tv_const,groupnum);
            end
        end
        
        function cosine_distance=compute_cosine_1(obj,psth_const,tv_const,groupnum)
            
            psth_group=psth_const{groupnum,1};
            pp=cell2mat(psth_group);
            tv_const_new=tv_const(:,groupnum);
            for i=1:size(pp,2) % size should be 76
                cosine_distance(1,i)=1-pdist2(pp(:,i)',tv_const_new','cosine'); % z
            end
            
        end
        % _____compute avg cosinePSTH of groups in const
        
        function obj=get_avg_cosinePSTH(obj,raw_or_normalized)
            arguments
                obj
                raw_or_normalized='raw'
            end
            switch raw_or_normalized
                case 'raw'
                    %
                    PSTH=obj.const_smoothed_PSTH_sub_TV_cosinecorr_raw;
                    obj.const_avg_cosine_PSTH_raw=obj.compute_avg_cosinePSTH_2(PSTH);
                case 'normalized'
                    PSTH=obj.const_smoothed_PSTH_sub_TV_cosinecorr_normalized;
                    obj.const_avg_cosine_PSTH_normalized=obj.compute_avg_cosinePSTH_2(PSTH);
            end
        end
        
        function r=compute_avg_cosinePSTH_2(obj,PSTH)
            arguments
                obj
                PSTH=obj.const_smoothed_PSTH_sub_TV_cosinecorr_raw;
            end
            r=cellfun(@(x) obj.compute_avg_cosinePSTH_1(x),PSTH(:,1),'UniformOutput',false);
        end
        
        function avg_psth=compute_avg_cosinePSTH_1(obj,psth_in_const)
            avg_psth=mean(cell2mat(psth_in_const),1);
        end
        
        
    end
end
