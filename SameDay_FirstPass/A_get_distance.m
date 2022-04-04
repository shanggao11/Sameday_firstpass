% this is just a test file. A_winnowing already contain this.
for i=1:3
        obj.const_raw_distance{i,1}=get_distance(obj,i);%function dd=get_distance(obj,which_const,GroupnuminCons,const_TV) %TODO
end

const_TV=obj.const_group_normalized_target_vector;
for i=1:3
        obj.const_normalized_distance{i,1}=get_distance(obj,i,GroupnuminCons,const_TV);%function dd=get_distance(obj,which_const,GroupnuminCons,const_TV) %TODO
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
    rawTV=const_TV{which_const,1}
    gg{i,1}=calculate_distance(rawTV(index));
    gg{i,2}=[num2str(g_id(1)),num2str(g_id(2))];
end
end
dd=gg;
end


function distance=calculate_distance(pair_vector,mode)
arguments
    pair_vector='Please enter a pair_vector'
    mode='euclidean'
end

if size(pair_vector,1)~=2, error('make the vector number correct');end
switch mode
    case 'euclidean'
        r1=pair_vector{1};r2=pair_vector{2};
        distance=sqrt(sum((r1-r2).^2));
    case 'consine'
end
end
