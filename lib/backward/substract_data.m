function [difference_data,difference_ranges] = substract_data( ...
%% Initialization of ranges
top_minuend_ranges = minuend_ranges{end};
top_subtrahend_ranges = subtrahend_ranges{end};
top_difference_ranges = top_minuend_ranges;
nSubscripts = size(top_minuend_ranges,2);
if nargin<5
    min_size = zeros(1,nSubscripts);
end

%% Initialization of subsref/subsasgn structures
minuend_substruct = substruct('()',replicate_colon(nSubscripts));
subtrahend_substruct = minuend_substruct;
subsasgn_structure = minuend_substruct;

%% Iterated loop over zeroth-level subscripts
for subscript = 1:nSubscripts
    % Special case when ranges are the same
    minuend_range = top_minuend_ranges(:,subscript);
    subtrahend_range = top_subtrahend_ranges(:,subscript);
    if isequal(minuend_range,subtrahend_range)
        continue
    end
    
    % Definition of step
    if minuend_range(2)~=subtrahend_range(2)
        error('minuend and subtrahend have different samplings');
    end
    step = minuend_range(2);
    
    % Definition of starting indices
    if minuend_range(1)<=subtrahend_range(1)
        top_difference_ranges(1,subscript) = subtrahend_range(1);
        minuend_start = 1 + (subtrahend_range(1)-minuend_range(1)) / step;
        subtrahend_start = 1;
    else
        top_difference_ranges(1,subscript) = minuend_range(1);
        minuend_start = 1;
        subtrahend_start = 1 + (minuend_range(1)-subtrahend_range(1)) / step;
    end
    
    % Definition of stopping indices
    if minuend_range(3)<=subtrahend_range(3)
        top_difference_ranges(1,subscript) = minuend_range(3);
        minuend_stop = (minuend_range(3)-minuend_range(1)+1) / step;
        subtrahend_stop = (minuend_range(3)-subtrahend_range(1)+1) / step;
    else
        top_difference_ranges(1,subscript) = subtrahend_ranges(3);
        minuend_stop = (subtrahend_range(3)-minuend_range(1)+1) / step;
        subtrahend_stop = (subtrahend_range(3)-subtrahend_range(1)+1) / step;
    end
    
    % Lower bound for nCoefficients (useful when padding over gamma or j)
    nCoefficients = minuend_stop - minuend_start + 1;
    if (length(minuend_ranges)==1) && (nCoefficients<min_size(subscript))
        nCoefficients = min_size(subscript);
        minuend_stop = minuend_start + nCoefficients - 1;
        subtrahend_stop = subtrahend_start + nCoefficients - 1;
    end
    
    % Definition of substructs
    minuend_substruct.subs{subscript} = minuend_start:minuend_stop;
    subtrahend_substruct.subs{subscript} = subtrahend_start:subtrahend_stop;
    subsasgn_structure.subs{subscript} = 1:nCoefficients;
    
    % Definition of difference range
    top_difference_ranges(1,subscript) = ...
        max(minuend_range(1),subtrahend_range(1));
    top_difference_ranges(3,subscript) = ...
        min(minuend_range(3),subtrahend_range(3));
end

%%
difference_ranges = cell(minuend_ranges);
difference_ranges{end} = top_difference_ranges;

%%
if length(minuend_ranges)>1
    minuend_data = subsref(minuend_data,minuend_substruct);
    subtrahend_data = subsref(subtrahend_data,subtrahend_substruct);
    difference_data = cell(size(minuend_data));
    for node = 1:numel(minuend_data)
        minuend_ranges_node = get_ranges_node(minuend_ranges,node);
        subtrahend_ranges_node = get_ranges_node(subtrahend_ranges,node);
        [difference_data{node},difference_ranges_node] = substract_data( ...
            minuend_data{node},minuend_ranges_node, ...
            subtrahend_data{node},subtrahend_ranges_node);
        difference_ranges = ...
            set_ranges_node(difference_ranges,difference_ranges_node,node);
    end
else
    %% Subscripted reference and pointwise substraction
    difference_data = ...
        subsref(minuend_data,minuend_substruct) - ...
        subsref(subtrahend_data,minuend_substruct);
end
end