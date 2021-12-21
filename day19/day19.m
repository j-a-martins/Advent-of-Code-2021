% (): Run example puzzle, (<anything>): Run personal puzzle
function day19(~)

%% Read data from current folder
p = cd; p = p(end - 4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

f_id = fopen(file, 'r'); data = {}; sensor = {};
while true
    l = fgetl(f_id); if l == -1, break, end
    d = sscanf(l, "--- scanner %d ---") + 1;
    i = 1;
    while true
        l = fgetl(f_id); if isempty(l) || l(1) == -1, break, end
        data{d}(i, :) = sscanf(l, "%d,%d,%d").';
        i = i + 1;
    end
    sensor{d}(1, :) = [0, 0, 0]; % Add sensor position
end
fclose(f_id);

%% Process candidates
n = 2; %numel(data)-1; % Number of neighbours points to fingerprint
labels_prev = [];
while true
    % Break at less than 2 points
    if n < 2, break, end
    % Calculate distances between points
    distances = calculate_distances(data, 'sqe');
    % Get point fingerprints for n neighbours
    labels = fingerprint_points(distances, n);
    % Skip if no matches are found or matches are similar to the previous
    % iteration with the same n neighbours
    if sum(labels(:, :, 2), 'all') == 0 || ~isempty(labels_prev) && sum(labels_prev, 'all') == sum(labels, 'all')
        n = n - 1; labels_prev = []; continue
    else
        labels_prev = labels;
    end
    % Process beacon matches
    [data, sensor] = process_matches(data, sensor, distances, labels, n);
    % Display found matches
    matches = labels(:, :, 2);
    disp(n + ": " + strjoin(string(matches(matches ~= 0))))
end

%% Part 1
disp("Part 1: There are " + height(data{1}) + " beacons")

%% Part 2
distances = calculate_distances(sensor(1), 'manh');
disp("Part 2: The largest Manhattan distance was " + max(distances{1}, [], 'all'))

end

% Auxiliary functions

%% Calculate distances between 3D points
function dist = calculate_distances(data, type)
switch type
    case 'sqe'
        %dist_func = @(a, b) sqrt(sum((a-b).^2)); % Euclidean
        dist_func = @(a, b) sum((a - b).^2); % Squared Euclidean
    case 'manh'
        dist_func = @(a, b) sum(abs(a - b)); % Manhattan
end
dist = {};
for d = 1:numel(data)
    h_data = height(data{d});
    for i = 1:h_data
        for j = i:h_data
            dist{d}(i, j) = dist_func(data{d}(i, :), data{d}(j, :));
            dist{d}(j, i) = dist{d}(i, j);
        end
    end
end
end

%% Process beacon and sensor matches from fingerprints
function [data, sensor] = process_matches(data, sensor, distances, labels, n)
% Get all unique rotation quaternions
q = get_quaternions();
% Get matches from labels matrix
matches = labels(:, :, 2); 
labels = labels(:, :, 1);
% Find points with matches
l = labels(matches ~= 0); m = matches(matches ~= 0);
% Sort downwards from the most matches
[~, i] = sort(m, 'descend'); l = l(i);
% Get the unique labels
l = unique(l, 'stable');
% Process the labels, starting at the ones with most matches
for i = 1:numel(l)
    [point_row, dims] = find(labels == l(i));
    for d1 = 1:numel(dims)
        for d2 = d1 + 1:numel(dims)
            dd1 = dims(d1); dd2 = dims(d2);
            % Skip beacons that were already converted to other axis
            if isempty(data{dd1}) || isempty(data{dd2})
                continue
            end
            % Get the indices for the closest points
            [~, id1] = sort(distances{dd1}(point_row(d1), :));
            [~, id2] = sort(distances{dd2}(point_row(d2), :));
            % Restrict to point + n neighbours
            id1 = id1(1:1+n); id2 = id2(1:1+n);
            % Get the fingerprint points
            p1 = data{dd1}(id1, :);
            p2 = data{dd2}(id2, :);
            % Process the point rotations
            [data, sensor] = find_rotation_and_bias(q, data, sensor, p1, p2, dd1, dd2);
        end
    end
end
end

%% Fingerprint points from nearest neighbours
function [labels] = fingerprint_points(dist, n)
fingerprints = [];
matches = [];
n = n + 1;
% Columns in labels are different beacon groups
labels = zeros(max(cellfun(@(x) height(x), dist)), numel(dist), 2);
for d = 1:numel(dist)
    for i = 1:height(dist{d})
        l = dist{d}(i, :);
        l = sort(l);
        l = sum(l(2:n)); % Sum n neighbours
        % Search if fingerprint label already exists
        for f = 1:numel(fingerprints)
            if l == fingerprints(f)
                labels(i, d, 1) = f;
                matches(f) = matches(f) + 1;
                break
            end
        end
        % Create a new label
        if ~labels(i, d, 1)
            fingerprints(end + 1) = l;
            matches(end + 1) = 0;
            labels(i, d, 1) = numel(fingerprints);
        end
    end
end
% Count the number of label matches across beacon groups
if sum(matches) ~= 0
    sz_labels = size(labels);
    for i = 1:sz_labels(1)
        for j = 1:sz_labels(2)
            l = labels(i, j, 1);
            if l, labels(i, j, 2) = matches(l); end
        end
    end
end
end

%% Get all unique rotation quaternions
function q = get_quaternions()
q = quaternion.empty;
for x = [0 90 180 270]
    for y = [0 90 180 270]
        q(end + 1, :) = quaternion([x y 0], 'eulerd', 'XYZ', 'frame');
    end
end
for x = [0 90 180 270]
    for z = [90 -90]
        q(end + 1, :) = quaternion([x 0 z], 'eulerd', 'XYZ', 'frame');
    end
end
% i_del = [];
% for i = 1:numel(q), for j = i + 1:numel(q), if dist(q(i), q(j)) == 0, i_del(end + 1) = j; end, end, end
% q(i_del) = [];
end

%% Find rotations
function [data, sensor] = find_rotation_and_bias(quat, data, sensor, p1, p2, d1, d2)
% Convert to relative coords
p1_rel = p1 - p1(1, :);
p2_rel = p2 - p2(1, :);
% Try rotations until points match
for i = 1:numel(quat)
    % Rotate the points
    p2_rel_rot = round(rotateframe(quat(i), p2_rel));
    % Check if all points match
    if all(p1_rel == p2_rel_rot, 'all')
        data1 = data{d1}(:, :);
        % Rotate data2 beacons
        data2 = data{d2}(:, :);
        data2_rel = data2 - p2(1, :);
        data2_rel_rot = round(rotateframe(quat(i), data2_rel));
        data2 = p1(1, :) + data2_rel_rot;
        % Rotate the sensor
        s1 = sensor{d1}(:, :);
        s2 = sensor{d2}(:, :);
        s2_rel = s2 - p2(1, :);
        s2_rel_rot = round(rotateframe(quat(i), s2_rel));
        s2 = p1(1, :) + s2_rel_rot;
        % Save the point and sensor rotations
        data{d1} = unique([data1; data2], 'rows', 'stable');
        data{d2} = [];
        sensor{d1} = unique([s1; s2], 'rows', 'stable');
        sensor{d2} = [];
        % Terminate loop
        break
    end
end
end