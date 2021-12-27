% (): Run example puzzle, (<anything>): Run personal puzzle
function day21(~)

%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

f_id = fopen(file, 'r');
data = fscanf(f_id, 'Player %d starting position: %d\n', [2 Inf]).';
fclose(f_id);

%% Part 1
scores = uint16([0; 0]); % Player scores (max 1000)
position = uint16([data(1, 2); data(2, 2)]); % Player positions (1-10)
die = uint16(0); % Die sequence (resets at 399)

player = uint8(1); % Starting player
c_triple_rolls = uint16(0); % Count triple die rolls
max_score = uint32(1000); % Score to end game

while all(scores < max_score)
    % Roll the sequencial dice and store roll counts
    roll = uint16(sum(rem(die:die+2, 100)+1)); c_triple_rolls = c_triple_rolls + uint16(1);
    % Reset the die at 399
    die = die + 3; if die >= 399, die = die - 300; end
    % Update current player position and score
    position(player) = rem(position(player)+roll-uint16(1), uint16(10)) + uint16(1);
    scores(player) = scores(player) + position(player);
    % Switch players
    if player == uint8(1), player = uint8(2); else, player = uint8(1); end
end

r = 3 .* uint32(c_triple_rolls) .* uint32(min(scores));
disp("Part 1: The score of the losing player times die rolls is "+r)
if ~nargin, assert(r == 739785, "Part 1 is incorrect."), end % Validate example puzzle
if nargin, assert(r == 989352, "Part 1 is incorrect."), end % Validate personal puzzle

%% Part 2
scores = uint8([0; 0]); % Player scores (max 21)
position = uint8([data(1, 2); data(2, 2)]); % Player positions (1-10)
player = uint8(1); % Starting player
results = struct('a', false); % Initialize a memoization struct with dummy data
% Process game rounds
[winners, results] = next_game_round(player, position, scores, results);
[r, i] = max(winners); % Get max value and arry position

disp("Part 2: Player "+i+" wins the most, in "+r+" universes (vs the other player in "+min(winners)+" universes)")
if ~nargin, assert(r == 444356092776315, "Part 2 is incorrect."), end % Validate example puzzle
if nargin, assert(r == 430229563871565, "Part 2 is incorrect."), end % Validate personal puzzle
end

%% Auxiliary functions

%% Process game rounds
function [winners, results] = next_game_round(player, position, scores, results)
% End recursion if any score >= 21
if scores(1) >= uint8(21)
    winners = uint64([1; 0]);
elseif scores(2) >= uint8(21)
    winners = uint64([0; 1]);
else % Process next player and game state
    % Get a unique player + position + score key
    key = "p" + player + strjoin("_"+position.'+"_"+scores.', "");
    % Check if already exists in the memoization struct
    if isfield(results, key)
        winners = results.(key);
    else
        % Initialize the winners counter
        winners = uint64([0; 0]);
        % Swap players
        if player == uint8(1), player_ = uint8(2); else, player_ = uint8(1); end
        % Process die rolls
        for i = uint8(1:3)
            for j = uint8(1:3)
                for k = uint8(1:3)
                    roll = i + j + k;
                    % Update player position and scores
                    position_ = position;
                    position_(player) = rem(position_(player)+roll-uint8(1), uint8(10)) + uint8(1);
                    scores_ = scores;
                    scores_(player) = scores(player) + position_(player);
                    % Process next round
                    [w, results] = next_game_round(player_, position_, scores_, results);
                    % Sum winner counts
                    winners = winners + w;
                end
            end
        end
        % Memoize winner counts for the processed conditions
        results.(key) = winners;
    end
end
end
