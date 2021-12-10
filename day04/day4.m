%% Read data
%file = 'day4_example.txt';
file = 'day4_data.txt';

data = readtable(file, Delimiter = {'comma'});

bingo_rolls = [str2double(data.Var1{1}) table2array(data(1,2:end))];


%% Read bingo cards
data = readtable(file, ...
    Delimiter = {'space'}, ...
    LeadingDelimitersRule = 'ignore', ...
    ConsecutiveDelimitersRule = 'join');

% Use decreasing indexes so that bingo_cards is created at max size
for i = (height(data)-4):-5:1
    bingo_cards((i+4)/5) = {table2array(data(i:i+4,:))};
end

%% Draw!
mark = -1;  %Choose a constant to mark rolls on cards
mark_ignore = -2;  %Choose a constant to mark completed cards (after bingo)

first_score = -1;
for roll = bingo_rolls
    for card = 1:numel(bingo_cards)
        % Ignore cards marked as complete in pos (1,1)
        if bingo_cards{card}(1,1) == mark_ignore, continue, end
        % Mark current roll into card
        bingo_cards{card}(roll == bingo_cards{card}) = mark;
        % Check if card is complete for Bingo (either a full row or column)
        % Meaning either the sum of a row or a column is 5*mark
        if any(sum(bingo_cards{card},1) == 5*mark) || any(sum(bingo_cards{card},2) == 5*mark)
            score = roll*sum(bingo_cards{card}(bingo_cards{card}(:) ~= mark));
            disp("Bingo! Winner card: " + card + ", Score: " + score)
            % Mark a card as complete in pos (1,1)
            bingo_cards{card}(1,1) = mark_ignore;
            %return
            if first_score == -1
                first_score = score;
            end
        end
    end
end
disp(" ")
disp("Part 1: The score of the first card to win is " + first_score)
disp("Part 2: The score of the last card to win is " + score)