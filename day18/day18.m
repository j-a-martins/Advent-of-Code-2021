% (): Run example puzzle, (<anything>): Run personal puzzle
function day18(~)

%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

f_id = fopen(file, 'r'); data = string.empty;
while true
    l = fgetl(f_id); if l == -1, break, end
    if isempty(data), data = string(l); else data(end+1, 1) = l; end
end
fclose(f_id);

%% Part 1
% Process all additions
timer = tic;
reduce = data{1};
for i_data = 2:numel(data)
    reduce = calculate_addition(reduce, data{i_data});
end
disp("Final string: "+reduce)

% Calculate magnitude
mag = calculate_magnitude(reduce);
disp("Part 1: The magnitude of the final sum is "+mag+" [Runtime "+toc(timer)+"s]")
if ~nargin, assert(strcmp(reduce, '[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]'), "Part 1 is incorrect."), end % Validate example puzzle
if ~nargin, assert(mag == 4140, "Part 1 is incorrect."), end % Validate example puzzle
if nargin, assert(strcmp(reduce, '[[[[6,6],[6,7]],[[9,5],[8,0]]],[[[7,8],[7,8]],[9,2]]]'), "Part 1 is incorrect."), end % Validate personal puzzle
if nargin, assert(mag == 3574, "Part 1 is incorrect."), end % Validate personal puzzle

%% Part 2
timer = tic;
large_mag = -Inf;
for i = 1:numel(data)
    for j = i + 1:numel(data) % Triangular search (top)
        mag = calculate_magnitude(calculate_addition(data{i}, data{j}));
        if mag > large_mag, large_mag = mag; end
    end
end
for i = numel(data):-1:1
    for j = i - 1:-1:1 % Triangular search (bottom)
        mag = calculate_magnitude(calculate_addition(data{i}, data{j}));
        if mag > large_mag, large_mag = mag; end
    end
end
disp("Part 2: The largest magnitude of the final sum is "+large_mag+" [Runtime "+toc(timer)+"s]")
if ~nargin, assert(large_mag == 3993, "Part 2 is incorrect."), end % Validate example puzzle
if nargin, assert(large_mag == 4763, "Part 2 is incorrect."), end % Validate personal puzzle

end

%% Auxiliary functions
function reduce = calculate_addition(str1, str2)
% Concatenate two lines for each iteration
reduce = ['[' str1 ',' str2 ']'];
% Assemble the binary tree
P = assemple_binary_tree(reduce);

while true
    while true
        % Explode pairs while possible
        %[val, pos] = max(arrayfun(@(i) P(i).n, numel(P):-1:1));
        %[val, pos] = max(cell2mat({P(end:-1:1).n}));
        [val, pos] = max([P(end:-1:1).n]);
        pos = numel(P) - pos + 1;
        if val < 4, break, end
        P = explode_pair(P, pos);
        %disp("Exploded:"+unpack_string(P))
    end
    while true
        % Reduce only one pair each iteration
        % Find the leftmost possible pair
        [~, visited] = find_left_val(P, numel(P), 0);
        % Break if there is none
        if visited(end) == Inf, break, end
        % Split the leftmost pair, if possible
        [P, c] = split_pair(P, abs(visited(end)));
        %if c ~= 0, disp("Reduced:"+assemble_string(P)), break, end
        % Break if the split was successful
        if c ~= 0, break, end
        while true
            % Keep trying to find a viable pair to the right of the leftmost pair
            [~, visited] = find_right_val(P, abs(visited(end)), 0);
            % Break if there is none
            if visited(end) == Inf, break, end
            % Split the next leftmost pair, if possible
            [P, c] = split_pair(P, abs(visited(end)));
            % Break if the split was successful
            if c ~= 0, break, end
        end
        % Keep the break if there was no innermost pair
        if visited(end) == Inf, break, end
        %if c ~= 0, disp("Reduced:"+assemble_string(P)), break, end
        % Keep the break if the inner split was successful
        if c ~= 0, break, end
    end
    % If we can't explode or split anymore, terminate
    if val < 4 && c == 0, break, end
end
% Unpack the final reduced string
reduce = unpack_string(P);
end

%% Process magnitude
function r = calculate_magnitude(str)
while true
    % Get the pairs in the string
    [s, e] = regexp(str, '[\[][P\d]+[,][P\d]+[\]]'); if isempty(s), break, end
    for i = numel(s):-1:1
        % Left element
        a = char(regexp(str(s(i)+1:e(i)), '[\d]+[,]', 'match'));
        % Right element
        b = char(regexp(str(s(i)+1:e(i)), '[,][\d]+[\]]', 'match'));
        % The magnitude = 3*a + 2*b
        p = str2double(a(1:end-1)) * 3 + str2double(b(2:end-1)) * 2;
        % Replace the pair by its magnitude
        str = replaceBetween(str, s(i), e(i), num2str(p));
    end
end
r = str2double(str); % Convert the final value to a number
end

%% Assemble string from binary tree
function str = unpack_string(P)
% Initialize the streing with the outermost pair, P(end)
str = ['[' P(end).l ',' P(end).r ']'];
while true
    % Find all elements Px
    [s, e] = regexp(str, '[P][\d]+'); if isempty(s), break, end
    for i = numel(s):-1:1
        % Get the pair
        p = P(str2double(str(s(i)+1:e(i))));
        % Get both elements of the pair
        new = ['[' num2str(p.l) ',' num2str(p.r) ']'];
        % Replace the pair by its elements
        str = replaceBetween(str, s(i), e(i), new);
    end
end
end

%% Assemble a binary tree from string data
function P = assemple_binary_tree(str)
p = 1; P = struct; % Store the binary tree in a struct
while true
    % Find the [x,x] pairs
    [s, e] = regexp(str, '[\[][P\d]+[,][P\d]+[\]]'); if isempty(s), break, end
    for i = numel(s):-1:1
        % Get both elements of a pair
        v = regexp(str(s(i)+1:e(i)), '[P\d]+', 'match');
        % Process the left element, Px or a number
        if v{1}(1) == 'P'
            idx = str2double(v{1}(2:end));
            P(p).l = v{1};
            P(idx).parent = p;
        else
            P(p).l = str2double(v{1});
        end
        % Process the right element, Px or number
        if v{2}(1) == 'P'
            idx = str2double(v{2}(2:end));
            P(p).r = v{2};
            P(idx).parent = p;
        else
            P(p).r = str2double(v{2});
        end
        % Initialize the nesting value at zero
        P(p).n = 0;
        % Update the representation of the assembled pair
        str = [str(1:max(1, s(i)-1)), 'P', num2str(p), str(min(end, e(i)+1):end)];
        % Increase the binary tree index
        p = p + 1;
    end
end
% Update all nests of the binary tree
P = update_nests(P);
end

%% Split pair
function [P, c_splits] = split_pair(P, pos)
c_splits = 0; % Count the number of splits done
p = P(pos);
for side = ['l' 'r']
    d = p.(side);
    if isnumeric(d) && d >= 10
        % Find an empty tree position
        %idx = find(arrayfun(@(i) P(i).n, 1:numel(P)) == -1, 1, 'first');
        %idx = find([P.n] == -1, 1, 'first');
        idx = -1;
        for i = 1:numel(P), if P(i).n < 0, idx = i; break, end; end
        if idx < 0, idx = numel(P) + 1; end
        % Update the value according to the formula
        v = d ./ 2;
        P(idx).l = floor(v);
        P(idx).r = ceil(v);
        % Increase the nesting value of the pair
        P(idx).n = p.n + 1;
        % Set the parent of the node, and the node as child
        P(idx).parent = pos;
        P(pos).(side) = ['P' num2str(idx)];
        % Increase the split counter
        c_splits = c_splits + 1;
        break
    end
end
end

%% Explode pair
function P = explode_pair(P, pos)
% Find the left and right values of a pair
% The left or right element of the neighbour pair is defined by sign
% The initial search direction is also encoded in the initial position sign
[l_nest, l_pos] = find_left_val(P, -pos, 0);
[r_nest, r_pos] = find_right_val(P, pos, 0);

% Leftmost pair
if l_pos(end) == Inf
    if r_pos > 0
        P(P(pos).parent).l = 0;
        P(r_pos).r = P(r_pos).r + P(pos).r;
    else
        P(-r_pos).l = P(-r_pos).l + P(pos).r;
        P(P(pos).parent).l = 0;
    end
    % Rightmost pair
elseif r_pos(end) == Inf
    if l_pos < 0
        P(-l_pos).l = P(-l_pos).l + P(pos).l;
        P(P(pos).parent).r = 0;
    else
        P(l_pos).r = P(l_pos).r + P(pos).l;
        P(P(pos).parent).r = 0;
    end
    % Middle pair
else
    if l_pos < 0
        P(-l_pos).l = P(-l_pos).l + P(pos).l;
        if r_nest > l_nest, P(P(pos).parent).r = 0; end
    else
        P(l_pos).r = P(l_pos).r + P(pos).l;
        if r_nest > l_nest, P(P(pos).parent).l = 0; end
    end
    if r_pos > 0
        P(r_pos).r = P(r_pos).r + P(pos).r;
        if l_nest > r_nest, P(P(pos).parent).l = 0; end
    else
        P(-r_pos).l = P(-r_pos).l + P(pos).r;
        if l_nest > r_nest, P(P(pos).parent).l = 0; end
    end
end
% Signal that this pair is unused in the binary tree
P(pos).l = -1;
P(pos).r = -1;
P(pos).n = -1; % Only this one really needs to be set to -1
P(pos).parent = -1;
end

%% Search values to the right
function [nest, visited] = find_right_val(P, visited, nest)
p = P(abs(visited(end)));
d = p.r; parent = p.parent;

% Stop if numeric
if isnumeric(d) && numel(visited) > 1
    visited = visited(end);
    return
end
% Go to children
[nest, visited, stop] = search_children(d, visited, nest, @find_left_val, @find_right_val, P);
if stop, return, end
% Go to parents
[nest, visited] = search_parents(parent, d, visited, nest, @find_right_val, P);
if numel(visited) == 1, return, end
% Did not find any value
if visited(end) ~= Inf, visited(end+1) = Inf; end
end

%% Search values to the left
function [nest, visited] = find_left_val(P, visited, nest)
p = P(abs(visited(end)));
d = p.l; parent = p.parent;

% Stop if numeric
if isnumeric(d) && numel(visited) > 1
    visited = -visited(end);
    return
end
% Go to children
[nest, visited, stop] = search_children(d, visited, nest, @find_left_val, @find_right_val, P);
if stop, return, end
% Go to parents
[nest, visited, stop] = search_parents(parent, d, visited, nest, @find_left_val, P);
if stop, return, end
% Did not find any value
if visited(end) ~= Inf, visited(end+1) = Inf; end
end

%% Search child nodes
function [nest, visited, stop] = search_children(d, visited, nest, l_search_func, r_search_func, P)
stop = false;
if d(1) == 'P'
    % Do not revisit nodes
    %if ~any(abs(visited) == str2double(d(2:end)))
    node = str2double(d(2:end));
    if is_unchecked(visited, node)
        % Determine the next child to visit
        visited(end+1) = node;
        % Invert the search direction one time, as the sides change when looking at children
        if sign(visited(1)) == 1
            [nest, visited] = l_search_func(P, visited, nest);
        else
            [nest, visited] = r_search_func(P, visited, nest);
        end
        % If visited is a single value, a valid node was found
        if numel(visited) == 1, stop = true; end
    end
end
end

%% Optimization: Check if node is unvisited
% ~any(abs(visited) == str2double(d(2:end)))
function pass = is_unchecked(visited, node)
pass = true;
for i = 1:numel(visited)
    if abs(visited(i)) == node
        pass = false;
        return
    end
end
end

%% Search parent nodes
function [nest, visited, stop] = search_parents(parent, d, visited, nest, search_func, P)
stop = false;
if ~isempty(parent) && (d(1) == 'P' || numel(visited) == 1)
    % Do not revisit nodes
    %if ~any(abs(visited) == parent)
    if is_unchecked(visited, parent)
        % Increase the nesting value when crossig parenthesis
        nest = nest + 1;
        % Visit the node's parent
        visited(end+1) = parent;
        [nest, visited] = search_func(P, visited, nest);
        % If visited is a single value, a valid node was found
        if numel(visited) == 1, stop = true; end
    end
end
end

%% Calculate parenthesis depth for the initial pairs of the binary tree
function P = update_nests(P)
% Start at the outmost node, P(end)
for i = numel(P):-1:1
    if P(i).l(1) == 'P'
        % Get a child's node index
        idx = str2double(P(i).l(2:end));
        % Increase the nesting of a child node
        P(idx).n = P(i).n + 1;
    end
    if P(i).r(1) == 'P'
        % Get a child's node index
        idx = str2double(P(i).r(2:end));
        % Increase the nesting of a child node
        P(idx).n = P(i).n + 1;
    end
end
end

%% Convert a string to number with low overhead
function n = str2double(str)
n = double(string(str));
end

%% Convert a number to string with low overhead
% function str = num2str(n)
% str = int2str(n);
% end