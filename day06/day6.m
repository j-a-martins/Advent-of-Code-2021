function day6(days)

%% Read data
%file = 'day6_example.txt';
file = 'day6_data.txt';

data = uint8(readmatrix(file));
% Format fish into 9 buckets
for i = 8:-1:0
    fish(i+1) = sum(data == i);
end

%% Part 1
for d = 1:days
    new_fish = fish(1);
    if new_fish > 0
        fish(1) = 0;
        fish = circshift(fish, -1); % Circular shift left
        fish(7) = fish(7) + new_fish;
        fish(9) = fish(9) + new_fish;
    else
        fish = circshift(fish, -1); % Circular shift left
    end
end

disp("Part 1+2: Number of fish after " + days + " days is: " + sum(fish))