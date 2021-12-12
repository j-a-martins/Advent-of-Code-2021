%% Read data
%file = 'day1_example.txt';
file = 'day1_data.txt';

data = uint16(readmatrix(file));

%% Part 1 (vectorial)
pos = data(2:end) - data(1:end-1);
pos = sum(pos > 0);

disp("Part 1 (vectorial): There are " + pos + " measurements larger than the previous")

%% Part 2 (vectorial)
slide3 = arrayfun(@(i) sum(data(i:i+2)), 1:numel(data)-2);

pos = slide3(2:end) - slide3(1:end-1);
pos = sum(pos > 0);

disp("Part 2 (vectorial): There are " + pos + " sums larger than the previous")

%% Part 1 (iterative)
pos = uint16(0);
for i = 1:numel(data) - 1
    if data(i+1) > data(i)
        pos = pos + 1;
    end
end

disp("Part 1 (iterative): There are " + pos + " measurements larger than the previous")

%% Part 2 (iterative 3-pt sliding window sum)
slide3 = uint16(0);
for i = 1:numel(data) - 3
    if sum(data(i+1:i+3)) > sum(data(i:i+2))
        slide3 = slide3 + 1;
    end
end

disp("Part 2 (iterative): There are " + slide3 + " sums larger than the previous")

%% Cleanup temp vars
clear i file