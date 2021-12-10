format rational

%% Read Day 1 data
data = readtable('day2_data.txt');

%% Part 1 (vectorial)
data.Direction = string(data.Direction);

t = tic;
forward = data.Direction == "forward";
up = data.Direction == "up";

x = sum(data.X(forward));
d = sum(data.X(data.Direction == "down")) - sum(data.X(up));
e = toc(t);

disp("Part 1 (vec): The final horizontal position by the final depth is " + d*x + " [time: " + e + "]")

%% Part 2 (vectorial)
t = tic;
x = sum(data.X(forward));

aim = data.X;
aim(forward) = 0;
aim(up) = -aim(up);
aim = cumsum(aim);

d = sum(aim(forward).*data.X(forward));
e = toc(t);

disp("Part 2 (vec): The final horizontal position by the final depth is " + d*x + " [time: " + e + "]")

%% Part 1 (iterative)
x = 0;
d = 0;

t = tic;
for i = 1:height(data)
    switch data.Direction{i}
        case 'forward'
            x = x + data.X(i);
        case 'down'
            d = d + data.X(i);
        case 'up'
            d = d - data.X(i);
    end
end
e = toc(t);

disp("Part 1 (iter): The final horizontal position by the final depth is " + d*x + " [time: " + e + "]")

%% Part 2 (iterative)
x = 0;
d = 0;
aim = 0;

t = tic;
for i = 1:height(data)
    switch data.Direction{i}
        case 'forward'
            x = x + data.X(i);
            d = d + aim.*data.X(i);
        case 'down'
            aim = aim + data.X(i);
        case 'up'
            aim = aim - data.X(i);
    end
end
e = toc(t);

disp("Part 2 (iter): The final horizontal position by the final depth is " + d*x + " [time: " + e + "]")


%% Reset format
format default