paren = @(x, varargin) x(varargin{:});

%% Read data
%file = 'day8_example.txt';
file = 'day8_data.txt';

data = readmatrix(file, ...
    Delimiter = {' ','|'}, ...
    OutputType = 'string', ...
    ConsecutiveDelimitersRule = 'join');

%% Part 1
d1 = sum(strlength(data(:,11:14))==2,"all");  % 1
d7 = sum(strlength(data(:,11:14))==3,"all");  % 7
d4 = sum(strlength(data(:,11:14))==4,"all");  % 4
d8 = sum(strlength(data(:,11:14))==7,"all");  % 8

disp("Part 1: The sum of unique digits is " + (d1+d7+d4+d8))
clear d1 d7 d4 d8

%% Part 2
% 1 -> cf(2)
% 7 -> acf(3)
% 4 -> bcdf(4)d(10)
% 2 -> acdeg(5) | 3 -> acdfg(5) | 5 -> abdfg(5)
% 0 -> abcefg(6) | 6 -> abdefg(6) | 9 -> abcdfg(6)
% 8 -> abcdefg(7)

for l = 1:height(data)
    line = sort_strs(data(l,:));
    % Extract 1
    one = paren(line(strlength(line)==2),1);
    c = one; %f = one;
    % Extract segment a from 7
    seven = paren(line(strlength(line)==3),1);
    a = rem_el(seven, one);
    % Extract 4
    four = paren(line(strlength(line)==4),1);
    b = rem_el(four, one); %d = b;
    % Extract 3 (two segments common with 1)
    three = line(strlength(line)==5); three = paren(three(contains(three, one{1}(1)) & contains(three, one{1}(2))),1);
    g = rem_el(three, four + a);
    d = rem_el(three, seven + g);
    % At this point, a, d and g are solved
    b = rem_el(b, d); % Get b from 4
    % With b we can solve 5 and thus get f
    five = line(strlength(line)==5); five = paren(five(contains(five, b)),1);
    f = rem_el(five, a+b+d+g);
    c = rem_el(c,f); % Get c from one
    % Only e remains
    eight = "abcdefg";
    e = rem_el(eight, a+b+c+d+f+g);
    % Fill missing numbers
    zero = sort_strs(a+b+c+e+f+g);
    two = sort_strs(a+c+d+e+g);
    six = sort_strs(a+b+d+e+f+g);
    nine = sort_strs(a+b+c+d+f+g);

    digit = [zero one two three four five six seven eight nine];
    for i = 0:9
        line(line == digit(i+1)) = i;
    end
    data(l,:) = line;
end

outputs = str2double(data(:,11) + data(:,12) + data(:,13) + data(:,14));

disp("Part 2: The sum of outputs is " + sum(outputs))

% Remove elements from a string
function str_out = rem_el(str_out, str_in)
    for i = 1:numel(str_in{1})
        str_out = strrep(str_out, str_in{1}(i), '');
    end
end

% Sort inner string characters
function str = sort_strs(str)
    for i = 1:numel(str)
        str(i) = sort(str{i});
    end
end