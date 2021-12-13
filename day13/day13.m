%% Read data
%file = 'day13_example.txt';
file = 'day13_data.txt';

data = readmatrix(file, Delimiter = ',', OutputType = 'string');

coords = single(str2double(data)); % Get coordinates
filt = isnan(coords(:, 1));
instruct = data(filt ,1); % Get instructions (where coords == NaN)
coords(filt, :) = []; % Clear NaNs from coords

%% Part 1
mirror = @(x, fold) 2 * fold - x; % Define a mirror function
for i = 1:numel(instruct) % Process all instructions
    op = sscanf(instruct(i), 'fold along %c=%d'); % Get current instruction
    switch char(op(1))
        case 'x'
            filt = coords(:, 1) > op(2);
            coords(filt, 1) = mirror(coords(filt, 1), op(2));
        case 'y'
            filt = coords(:, 2) > op(2);
            coords(filt, 2) = mirror(coords(filt, 2), op(2));
    end
    coords = unique(coords, 'rows'); % Clear repeated rows
    if i == 1, disp("Part 1: There are " + height(coords) + " visible dots after the first fold"), end
end

%% Part 2
f = figure; f.Position = [500 700 300 50];
scatter(coords(:, 1), -coords(:, 2), 'filled'); axis off;
disp("Part 2: The activation code is " + ocr(getframe(gcf).cdata).Words{1})
