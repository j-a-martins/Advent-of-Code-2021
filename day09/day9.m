%% Read data
file = 'day9_example.txt';
%file = 'day9_data.txt';

data = readmatrix(file, VariableWidth=ones(100,1));

%% Part 1
% Pad data with Infs
data_padded = padarray(data, [1 1], Inf);
% Define a logical mask
mask = @(i,j,data) ...
    data(i,j)<data(i-1,j-1) & data(i,j)<data(i-1,j) & data(i,j)<data(i-1,j+1) & ...
    data(i,j)<data(i,j-1) & data(i,j)<data(i,j+1) & ...
    data(i,j)<data(i+1,j-1) & data(i,j)<data(i+1,j) & data(i,j)<data(i+1,j+1);
% Run the mask through the data
low_points = mask(2:height(data)+1, 2:width(data)+1, data_padded);
% Determine risk
risk = (data+1).*low_points;
% Display result
disp("Part 1: The sum of the risk levels of all low points is " + sum(risk(:)))

%% Part 2
% Binarize data
data(data<9) = true;
data(data==9) = false;
% Label data
L = bwlabel(data,4);
% Count region elements
for i = max(L(:)):-1:1
    s(i) = sum(L(:) == i);
end
% Sort count by inverse order
s = sort(s,'descend');
% Display result
disp ("Part 2: The product of the sizes of the three largest basins is " + prod(s(1:3)))
