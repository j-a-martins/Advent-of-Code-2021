%% Read data
file = 'day12_example1.txt';
%file = 'day12_example2.txt';
%file = 'day12_example3.txt';
%file = 'day12_data.txt';

data = readmatrix(file, Delimiter = '-', OutputType = 'string');

% Convert data into graph format
G = graph(data(:, 1), data(:, 2));

%% Part 1
count_paths_part1 = 0;
disp("----- Part 1 -----")
count_paths_part1 = explore(G, string.empty, count_paths_part1, "start", 0);
disp(" ")

%% Part 2
count_paths_part2 = 0;
disp("----- Part 2 -----")
count_paths_part2 = explore(G, string.empty, count_paths_part2, "start", 1);
disp(" ")

%% Display final counts
disp("Part 1: There are " + count_paths_part1 + " paths");
disp("Part 2: There are " + count_paths_part2 + " paths");

%% Recursive exploration function
function c_paths = explore(G, visited, c_paths, curr_node, small_caves_explorable)
% Stop criteria: ignore start node (useful for Part 2)
if "start" == curr_node && numel(visited) > 1
    return
end
% Mark node as visited
visited(end+1) = curr_node;
% Stop criteria: reached end node
if "end" == curr_node
    c_paths = c_paths + 1;
    disp("Path " + c_paths + ": " + strjoin(visited, ','))
    return
end
% Get neighbor nodes
neigh = neighbors(G, curr_node);
for i = 1:numel(neigh)
    % Check if uppercase (node can be visited again)
    if neigh(i) == upper(neigh(i))
        c_paths = explore(G, visited, c_paths, neigh(i), small_caves_explorable);
    % Check if explored previously (visited is matching pattern)
    elseif ~contains(neigh(i), visited)
        c_paths = explore(G, visited, c_paths, neigh(i), small_caves_explorable);
    % Part 2 exception for small nodes: check if already explored (now neigh is matching pattern)
    elseif sum(count(visited, neigh(i))) <= small_caves_explorable
        c_paths = explore(G, visited, c_paths, neigh(i), 0);
    end
end
end