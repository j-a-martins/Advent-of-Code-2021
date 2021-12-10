%% Read data
file = 'day5_example.txt';
%file = 'day5_data.txt';

fileID = fopen(file, 'r');
data = fscanf(fileID, '%d,%d -> %d,%d', [4 Inf])';
fclose(fileID);
% For Matlab notation, translate points to [1, Inf) instead of [0, Inf)
% This makes matrix notation easier to work with
data = data + 1; 

%% Part 1
% Get all segment coordinates from data points
points = segments_all_coords(data,'hv');
% Add all segment coordinates to a zero-init matrix
m = zeros(max(points));
for p = points' % Run through all pairs p = [x y];
    m(p(1),p(2)) = m(p(1),p(2)) + 1;
end
disp("Part 1: Number of hv-segment points with >1 overlap is " + sum(m(:)>1));

%% Part 2
points = segments_all_coords(data,'');
m = zeros(max(points));
for p = points'
    m(p(1),p(2)) = m(p(1),p(2)) + 1;
end
disp("Part 2: Number of segment points with >1 overlap is " + sum(m(:)>1));

%% Determine all integer coordinates of a line segment
function P = segments_all_coords(points, type)
    P = []; % Store points
    for i = 1:height(points)
        [x1, y1, x2, y2] = deal(points(i,1),points(i,2),points(i,3),points(i,4));
        % Calculate slope
        m = (y2 - y1)./(x2 - x1);
        % Ignore non-horizontal or non-vertical lines
        if type == "hv" && ~(abs(x1-x2)==0 || abs(y1-y2)==0)
            continue
        end
        % Line equation as anonymous function
        F = @(x) m.*(x - x1) + y1;
        % Run through x-axis
        for x = min(x1,x2):max(x1,x2)
            y = F(x);
            % For integer points, check if division remainder is zero
            if rem(y,1) == 0
                P(end+1,:) = [x y];
            end
            % For vertical slopes, y is NaN as m is infinite
            if isnan(y)
                % Run through y-axis
                for y = min(y1,y2):max(y1,y2)
                    P(end+1,:) = [x y];
                end
            end
        end
    end
end