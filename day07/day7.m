%function day7()

%% Read data
%file = 'day7_example.txt';
file = 'day7_data.txt';

data = readmatrix(file);

%% Part 1
t = tic;
central_pos = median(data);
fuel = sum(abs(data - central_pos));
t = toc(t);

disp("Part 1: Align on position " + central_pos + " with spent fuel " + fuel + ...
    " [Exec time: " + 1E3 .* t + "ms]")

%% Part 1 (one line)
%disp("Align on position " + median(data) + " with spent fuel " + sum(abs(data-median(data))))

%% Part 2
tri = @(n) 0.5 * n .* (n + 1);
fuel = @(x) sum(tri(abs(data - x)));
central_pos = round(fminsearch(fuel, mean(data)));

disp("Part 2: Align on position " + central_pos + " with spent fuel " + fuel(central_pos) + ...
    " [Exec time: " + 1E3 .* t + "ms]")
