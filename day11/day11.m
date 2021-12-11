%% Read data
file = 'day11_example.txt';
%file = 'day11_data.txt';

data = readmatrix(file, VariableWidth = ones(100,1), OutputType = 'single');
numel_orig_data = numel(data);

data = padarray(data, [1 1], NaN);

%% Part 1 & 2
steps = 1000;
flashes_count = 0;

for i = 1:steps
    % Increase energy levels
    data = data + 1;

    % Find elements at energy level 10 and flash them
    [a,b] = find(data == 10);
    for j = 1:numel(a)
        data = flash(a(j), b(j), data);
    end

    % Determine flashed elements and count them
    flashed = data==-Inf;
    sum_flashed = sum(flashed(:));
    % Update the total flashes count
    flashes_count = flashes_count + sum_flashed;

    % Reset the flashed elements from -Inf to zero for the next iteration
    data(flashed) = 0;

    % Part 1: Report the total flashes at 100 steps
    if i == 100
        disp("Part 1: Total flashes after 100 steps is " + flashes_count)
    end

    % Part 2: Report simultaneous flashes
    if sum_flashed == numel_orig_data
        disp("Part 2: First simultaneous flash at step " + i)
        break  % Break after finding the first occurence
    end
end

%% Recursive function to flash elements
function data = flash(i, j, data)
    d = data(i,j);
    
    % Stop condition: element is <10 or is NaN (for the padding)
    if d<10 || isnan(d), return, end
    
    % Flash! Add 1 to all surrounding elements
    data(i-1:i+1,j-1:j+1) = data(i-1:i+1,j-1:j+1) + 1;
    % Mark the current element as -Inf so that it doesn't flash again
    % in the current step (-Inf + x = -Inf) and is easier to identify
    data(i,j) = -Inf;

    % Call flash to all surrounding elements
    data = flash(i-1, j-1, flash(i, j-1, flash(i+1, j-1, data)));
    data = flash(i-1, j, flash(i+1, j, data));
    data = flash(i-1, j+1, flash(i, j+1, flash(i+1, j+1, data)));
end
