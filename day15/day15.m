% (): Run example puzzle, (<anything>): Run personal puzzle
function day15(~)
%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

% Read data as string array -> char matrix -> single precision matrix
data = single(char(readmatrix(file, Delimiter = "", OutputType = 'string', NumHeaderLines = 0))) - 48;

%% Part 1
[P, d] = shortest_path_tl_br(data);
disp("Part 1: The lowest total risk is " + d + " on path (" + strjoin(P,')->(') + ")")
if ~nargin, assert(d == 40, "Part 1 is incorrect."), end

%% Part 2
[P, d] = shortest_path_tl_br(expand_cave(data, 5));
disp("Part 2: The lowest total risk is " + d + " on path (" + strjoin(P,')->(') + ")")
if ~nargin, assert(d == 315, "Part 2 is incorrect."), end

end

%% Auxiliar functions
function [P, d] = shortest_path_tl_br(data)
% Get source and target nodes, with edge weights
[s, t, wt] = get_nodes(data);
% Create graph
G = digraph(s, t, wt);
% Get the shortest path from (1,1) to (h,w) and its cost
[P, d] = shortestpath(G, "1,1", height(data) + "," + width(data));
%p = plot(G,'EdgeLabel',G.Edges.Weight);
%highlight(p, P, EdgeColor='r', LineWidth=2)
end

function [s, t, wt] = get_nodes(data)
w = width(data); h = height(data);
s = string.empty; t = string.empty; wt = single.empty;
for i = 1:h
    for j = 1:w
        if i > 1 % Up
            s(end+1) = i + "," + j;
            t(end+1) = (i-1) + "," + j;
            wt(end+1) = data(i-1, j);
        end
        if j < w % Right
            s(end+1) = i + "," + j;
            t(end+1) = i + "," + (j+1);
            wt(end+1) = data(i, j+1);
        end
        if i < h % Down
            s(end+1) = i + "," + j;
            t(end+1) = (i+1) + "," + j;
            wt(end+1) = data(i+1, j);
        end
        if j > 1 % Left
            s(end+1) = i + "," + j;
            t(end+1) = i + "," + (j-1);
            wt(end+1) = data(i, j-1);
        end
    end
end
end

function data = expand_cave(data, exp_factor)
w = width(data); h = height(data);
% Replicate data exp_factor by exp_factor
data = repmat(data, exp_factor);
% Add 1 by Manhattan distance across replicates
for i = 1:(exp_factor * h)
    for j = 1:(exp_factor * w)
        data(i,j) = data(i,j) + floor((i-1)/h) + floor((j-1)/w);
        % Reduce by 9 when overflown (futureproofing: using div remainder)
        if data(i,j) > 9
            data(i,j) = max(1, rem(data(i,j), 9)); % 0->1
        end
    end
end
end