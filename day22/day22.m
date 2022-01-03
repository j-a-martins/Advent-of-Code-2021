% (): Run example puzzle, (<anything>): Run personal puzzle
function day22(~)

%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

f_id = fopen(file, 'r'); i = 1; data = string.empty;
while true
    l = fgetl(f_id); if l == -1, break, end
    data(i, :) = string(regexp(l, '[onf-\d]+', 'match'));
    i = i + 1;
end
fclose(f_id);
% Get "on" string positions
filt = data(:, 1) == "on";
% Set "on" to 1 and the rest to -1
data = double(data); data(filt) = 1; data(~filt) = -1;

%% Part 1
reactor = struct.empty;
for i = 1:height(data)
    % Skip cubes outside [-50,50]
    if data(i, 2) <= -50 || data(i, 3) >= 50 || ...
       data(i, 4) <= -50 || data(i, 5) >= 50 || ...
       data(i, 6) <= -50 || data(i, 7) >= 50
        continue
    end
    reactor = add_cube(reactor, data(i, 1:7));
end
r = count_cubes(reactor);
disp("Part 1: There are "+r+" ON cubes, in the region x=-50..50, y=-50..50, z=-50..50")
if ~nargin, assert(r == 474140, "The Part 1 example puzzle is incorrect."), end % Validate example puzzle
if nargin, assert(r == 591365, "The Part 1 personal puzzle is incorrect."), end % Validate personal puzzle

%% Part 2
reactor = struct.empty;
% Add a waitbar for progress visualization
f = waitbar(0, '0%', Name = 'Processing Part 2...'); incr = 1 ./ height(data);
for i = 1:height(data)
    reactor = add_cube(reactor, data(i, 1:7));
    waitbar(incr.*i, f, sprintf('%.0f %%', 100.*incr.*i))
end
close(f)
r = count_cubes(reactor);
disp("Part 2: There are "+r+" ON cubes, in total")
if ~nargin, assert(r == 2758514936282235, "The Part 2 example puzzle is incorrect."), end % Validate example puzzle
if nargin, assert(r == 1211172281877240, "The Part 2 personal puzzle is incorrect."), end % Validate personal puzzle
end

%% Auxiliary Functions

%% Add cubes to the reactor list
function r = add_cube(r, c)
% Create the initial cube
cube.sign = c(1);
cube.xmin = c(2); cube.xmax = c(3);
cube.ymin = c(4); cube.ymax = c(5);
cube.zmin = c(6); cube.zmax = c(7);
% Return if results list is empty (i.e., first cube)
if isempty(r), r = cube; return, end
% Add the cube to a temporary list if sign is positive
if cube.sign > 0, rr = cube; else, rr = cube([]); end
% Set cube sign to -1 for intersections
cube.sign = -1;
% Get intersections with all previous volumes
for i = 1:numel(r)
    int_vol = get_signed_volume_intersection(cube, r(i));
    if ~isempty(int_vol)
        rr(end+1) = int_vol;
    end
end
% Add the volumes to the reactor list
r = [r rr];
end

%% Get volume intersections
function vol3 = get_signed_volume_intersection(vol1, vol2)
% Calculate min and max, with early return
xmin = max(vol1.xmin, vol2.xmin); xmax = min(vol1.xmax, vol2.xmax); if xmin > xmax, vol3 = struct.empty; return, end
ymin = max(vol1.ymin, vol2.ymin); ymax = min(vol1.ymax, vol2.ymax); if ymin > ymax, vol3 = struct.empty; return, end
zmin = max(vol1.zmin, vol2.zmin); zmax = min(vol1.zmax, vol2.zmax); if zmin > zmax, vol3 = struct.empty; return, end
% Less overhead in struct lookups this way
vol3.xmin = xmin; vol3.xmax = xmax; vol3.ymin = ymin; vol3.ymax = ymax; vol3.zmin = zmin; vol3.zmax = zmax;
vol3.sign = vol1.sign .* vol2.sign;
end

%% Count all areas, using cube signs
function area = count_cubes(r)
area = 0;
for i = 1:numel(r)
    area = area + get_signed_area(r(i));
end
end

function area = get_signed_area(vol)
area = vol.sign .* (vol.xmax - vol.xmin + 1) .* (vol.ymax - vol.ymin + 1) .* (vol.zmax - vol.zmin + 1);
end