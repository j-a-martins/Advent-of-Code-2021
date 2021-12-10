format rational

%% Read data
data = readmatrix('day3_data.txt');
% Specify that data is binary and store as uint16
code = arrayfun(@(x) uint16(str2num(sprintf("0b%d", x))), data);

%% Part 1
digits = 12;  % Significant digits<16

gamma = uint16(0);
%epsilon = uint16(0);
for i = 1:digits
    value = median(bitget(code, i));
    gamma = bitset(gamma, i, value);
    %epsilon = bitset(epsilon, i, ~value);
end
epsilon = bitand(bitcmp(gamma), 0b0000111111111111);  % Clear unused precision
disp("Part 1: The power consumption is " + single(gamma).*single(epsilon))

%% Part 2
oxygen = code;
co2_scrubber = code;

for i = digits:-1:1
    value = ceil(median(bitget(oxygen, i)));
    oxygen(bitget(oxygen, i) ~= value) = [];
    if numel(oxygen) == 1, break, end
end
for i = digits:-1:1
    value = ceil(median(bitget(co2_scrubber, i)));
    co2_scrubber(bitget(co2_scrubber, i) == value) = [];
    if numel(co2_scrubber) == 1, break, end
end

disp("Part 2: The life support rating is " + single(oxygen).*single(co2_scrubber))

%% Misc (unused)
%str_med = @(x) num2str(ceil(median(str2num(x))));
%str_inv = @(x) num2str(abs(1-str2num(x)));
%str_bin = @(x) str2num(sprintf("0b%s", x));