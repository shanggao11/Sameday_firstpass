%% parameters

days = [2,4];
noiseLevels = [0,20,40,60];
standardize_firing_rate_mode = 'na'; %na,zscore,maxnorm
step = 0.01;

t = 0:step:1.3;
subtract_baseline = false;

h = 0.01;

%% initialize


legend_subset = [];

scores = {};

scores{1} =  zeros(22,40,131); %predefine scores
scores{2} =  zeros(22,40,131); %predefine scores



%%
tic

for l = 1:2
    d = days(l);
    cdt = cdts(d);
    img_labels = 1:cdt.numImage;
    
    
    % for each image select index of noise pattern. i.e. if idx_each_image = 1, 10 trials.
    % if more indexes are given than there are trials, they are ignored and
    % all trials will be used. 1:10 is all trials.
    
    idx_each_image = 1:10;
    
    
    maxCondition = cdt.maxCondition;
    
    
    cond = 0; % initialize condition
    for i = 1:length(noiseLevels)
        for j = 1:length(img_labels)
            
            cdt = cdts(d);
            img_label = img_labels(j);
            noiseLevel = noiseLevels(i);
            img_set = img_label:cdt.numImage:maxCondition;
            [combined] = cdt.combine_spikes(img_set,noiseLevel,idx_each_image);

            fiRate = cdt.estimate_firing_rate(combined,subtract_baseline,t,h);
            
            
            switch standardize_firing_rate_mode
                case 'na'
                case 'zscore'
                    tuning_center = params_constant_neurons(:,1,d);
                    tuning_std = params_constant_neurons(:,2,d);
                    fiRate = (fiRate - tuning_center)./tuning_std;
                case 'maxnorm'
                    fiRate = fiRate./maxfiRate(:,d);
                    
                    
                    
            end
            
            cond = cond+1;
            scores{l}(:,cond,:) = fiRate;
            
            
            
            
        end
    end
end