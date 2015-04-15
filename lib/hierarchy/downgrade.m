function data_downgraded = downgrade(data,subscripts)
%%
data_sizes = size(data);
downgraded_sizes = data_sizes;
downgraded_sizes(subscripts) = 1;
nCells = prod(downgraded_sizes);
if nCells>1
    % This is needed e.g. in joint time-frequency analysis of videos
    error('multi-cell downgrade not ready yet');
end
if iscell(data{1})
    % This is needed e.g. in 3rd-order 1D scattering with two spirals
    error('upper-level downgrade not ready yet');
end
%%
tensor_sizes = size(data{1});
if length(tensor_sizes)==2 && tensor_sizes(2)==1
    tensor_sizes = tensor_sizes(1);
end
padded_sizes = 2^nextpow2(data_sizes(subscripts));
target_sizes = [tensor_sizes,padded_sizes];
target = zeros(target_sizes);
subsref_structure.type = '()';
tensor_subs = replicate_colon(length(tensor_sizes));
data_subs = ...
    arrayfun(@(x) 1:x,data_sizes(subscripts),'UniformOutput',false);
subsref_structure.subs = cat(1,tensor_subs,data_subs);
target = subsasgn(target,subsref_structure,[data{:}]);
data_downgraded = {target};
end
