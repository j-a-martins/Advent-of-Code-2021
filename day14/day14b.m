function day14b(steps)
%% Read data
file = 'day14_example.txt';
%file = 'day14_data.txt';

data = readmatrix(file, Delimiter = '->', OutputType = 'char', NumHeaderLines = 0);

for i = 2:height(data)
    rules.(data{i,1}) = data{i,2};
end
%rules = orderfields(rules);  % For debugging

% Get the starting pairs from the initial polymer template
for i = 1:numel(data{1})-1
    c_curr.(data{1}(i:i+1)) = 1;
end

%% Part 1 and 2
for step = 1:steps
    c_new = struct;
    % Run through all pairs
    for pair = char(fieldnames(c_curr)).'
        % Skip if pair is unused
        if c_curr.(pair) == 0, continue, end
        % Get the substitution rules for this pair
        r = get_field(rules, pair);
        if r
            % Increase both new pair counters by the ammount of the current pair
            c_new.([pair(1) r]) = get_field(c_new, [pair(1) r]) + c_curr.(pair);
            c_new.([r pair(2)]) = get_field(c_new, [r pair(2)]) + c_curr.(pair);
        else
            % No rule was found for this pair
            c_new.(pair) = c_curr.(pair);
        end
    end
    % Replace the current count with the new count
    c_curr = c_new;
end

% Calculate unique pair combinations
pairs = char(fieldnames(c_curr));

% Get all unique single elements from the pairs
elements = unique(pairs);

% For every element, count the number of occurrences in pairs
for i = numel(elements):-1:1
    counts(i) = 0;
    % Only when the current element is the first letter of a pair
    for pair = pairs(pairs(:,1) == elements(i),:).'
        counts(i) = counts(i) + c_curr.(pair);
    end
end
% Add the last element of the polymer to the count
filt = elements == data{1}(end);
counts(filt) = counts(filt) + 1;

% Get the max and min values, with respective indexes
[max_count, max_pos] = max(counts);
[min_count, min_pos] = min(counts);

disp("Part 1/2: " + elements(max_pos) + "(" + max_count + ") - " + ...
    elements(min_pos) + "(" + min_count + ") = " + (max_count-min_count))
end

%% Helper: Returns a field value, or 0 if if does not exist
% Similar functionality to a defaultdict in Python
function v = get_field(S, k)
if isfield(S, k)
    v = S.(k);
else
    v = 0;
end
end