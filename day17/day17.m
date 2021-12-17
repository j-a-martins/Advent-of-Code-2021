% (): Run example puzzle, (<anything>): Run personal puzzle
function day17(~)

%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

f_id = fopen(file, 'r'); data = fscanf(f_id, 'target area: x=%d..%d, y=%d..%d', [4 Inf])'; fclose(f_id);
% data(1) < x < data(2), data(3) < y < data(4)

g_max_y = 0; % Store the global max y for Part 1
solutions = []; % Store found solutions
for v0_x = 1:data(2) % From 1 to x_max
    for v0_y = data(3):-data(3) % From y_min to -y_min
        max_y = 0;
        t = 0;
        while true % Calculate trajectory
            t = t + 1;
            [posx, posy] = find_probe_pos(v0_x, v0_y, t);
            % Break if target is overshot
            if posx > data(2) || posy < data(3), break, end
            % Store max posy of the current trajectory
            if posy > max_y, max_y = posy; end
            % Check if solution is found
            if posx >= data(1) && posx <= data(2) && posy >= data(3) && posy <= data(4)
                % Store the current solution
                solutions(end+1, :) = [v0_x v0_y];
                % Update the global max y if the trajectory was valid
                if max_y > g_max_y, g_max_y = max_y; end
            end
        end
    end
end
% Clear repeated solutions
solutions = height(unique(solutions, 'rows'));

disp("Part 1: The max y was " + g_max_y)
disp("Part 2: There are " + solutions + " solutions")
end

%% Aux functions
function [pos_x, pos_y] = find_probe_pos(v0_x, v0_y, t)
sum_int_0_to_n = @(n) 0.5 * n .* (n + 1);
drag = t - 1;
vx = max(0, abs(v0_x) - drag);
pos_x = sign(v0_x) .* (abs(vx) .* t + min(sum_int_0_to_n(drag), sum_int_0_to_n(v0_x)));
pos_y = v0_y .* t - sum_int_0_to_n(t-1);
end
