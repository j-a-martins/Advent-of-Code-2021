%% Read data
%file = 'day10_example.txt';
file = 'day10_data.txt';

data = readmatrix(file, ...
    Delimiter='', ...
    OutputType = 'string', ...
    VariableWidth=ones(1000,1));

%% Part 1
for i = 1:numel(data)
    l = data{i};
    while true
        % Replace pairs until there is nothing to replace
        l_prev = l;
        l = strrep(l,'()',''); l = strrep(l,'[]',''); l = strrep(l,'{}',''); l = strrep(l,'<>','');
        if strcmp(l_prev, l)
            break
        end
    end
    data{i} = l;
end

% Calculare the score and clear corrupt lines for Part 2
score = 0;
for i = 1:numel(data)
    for c = data{i}
        switch c
            case ")"
                score = score + 3; data(i) = "";
                break
            case "]"
                score = score + 57; data(i) = "";
                break
            case "}"
                score = score + 1197; data(i) = "";
                break
            case ">"
                score = score + 25137; data(i) = "";
                break
        end
    end
end

disp("Part 1: The total syntax error score is " + score)

%% Part 2
% Discard corrupted lines
data(data=="") = [];

% Fill missing braces
line_score = zeros(numel(data),1);
for i = 1:numel(data)
    for c = numel(data{i}):-1:1
        switch data{i}(c)
            case "("
                data{i}(end+1) = ')';
                line_score(i) = line_score(i)*5 + 1;
            case "["
                data{i}(end+1) = ']';
                line_score(i) = line_score(i)*5 + 2;
            case "{"
                data{i}(end+1) = '}';
                line_score(i) = line_score(i)*5 + 3;
            case "<"
                data{i}(end+1) = '>';
                line_score(i) = line_score(i)*5 + 4;
        end
    end
end
disp("Part 2: The middle score is " + median(line_score))
