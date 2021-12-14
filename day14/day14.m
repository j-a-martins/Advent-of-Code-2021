function day14(steps)
%% Read data
file = 'day14_example.txt';
%file = 'day14_data.txt';

data = readmatrix(file,Delimiter = '->', OutputType = 'string', NumHeaderLines = 0);

for i = height(data):-1:2
    % Get all matching pairs
    pairs(i-1,:) = [data(i,1) data{i,1}(1)+data(i,2) data(i,2)+data{i,1}(2)];
    % Fill rules with matching pairs
    rules.(pairs(i-1,1)) = pairs(i-1,2:3);
end

% Calculate unique pair combinations
pairs = char(unique(pairs));

% Initialize a counting struct with all possible pairs
for i = 1:height(pairs), c_empty.(pairs(i,:)) = 0; end

% Get the starting pairs from the initial polymer template
for i = 1:numel(data{1})-1, c_curr.(data{1}(i:i+1)) = 1; end

%% Part 1 and 2
for step = 1:steps
    c_new = c_empty;
    % Run through all pairs
    for pair = string(fieldnames(c_curr)).'
        % Skip if pair is unused
        if c_curr.(pair) == 0, continue, end
        % Get the substitution rules for this pair
        r = rules.(pair);
        % Increase both new pair counters by the ammount of the current pair
        c_new.(r(1)) = c_new.(r(1)) + c_curr.(pair);
        c_new.(r(2)) = c_new.(r(2)) + c_curr.(pair);
        % Zero the current pair count (as it was replaced by the new pairs)
        c_curr.(pair) = 0;
    end
    % Replace the current count with the new count
    c_curr = c_new;
end

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