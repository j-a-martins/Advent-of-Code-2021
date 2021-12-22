% (): Run example puzzle, (<anything>): Run personal puzzle
function day20(~)

%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin, case 0, file = p + "_example.txt"; otherwise, file = p + "_data.txt"; end

data = strrep(strrep(readmatrix(file, Delimiter = "", OutputType = 'char', NumHeaderLines = 0), '.', '0'), '#', '1');

% Get the enhancement algorithm
enh_algo.algo = data{1};
% Signal inverted space
if enh_algo.algo(1) == '1' && enh_algo.algo(end) == '0', enh_algo.invert = true; else, enh_algo.invert = false; end
% Get the input image
I = logical(char(data{2:end})-'0');

%% Part 1
steps = 2;
img_sum = sum(enhance_image(I, enh_algo, steps) == 1, 'all');

disp("Part 1: The resulting image at "+steps+" steps has "+img_sum+" lit pixels")
if ~nargin, assert(img_sum == 35, "Part 1 is incorrect."), end % Validate example puzzle
if nargin, assert(img_sum == 5884, "Part 1 is incorrect."), end % Validate personal puzzle

%% Part 2
steps = 50;
img_sum = sum(enhance_image(I, enh_algo, steps) == 1, 'all');

disp("Part 2: The resulting image at "+steps+" steps has "+img_sum+" lit pixels")
if ~nargin, assert(img_sum == 3351, "Part 2 is incorrect."), end % Validate example puzzle
if nargin, assert(img_sum == 19043, "Part 2 is incorrect."), end % Validate personal puzzle

end

function I = enhance_image(I, enh_algo, steps)
enh_al = enh_algo.algo; invert = enh_algo.invert;
inverted = false;

I = padarray(I, [2 2], false);

for s = 1:steps
    Inew = I;
    for i = 2:height(I) - 1
        for j = 2:width(I) - 1
            % Get image window and flip (Matlab is column major)
            window = I(i-1:i+1, j-1:j+1).';
            % Get window as 9x1, convert logical to char, and convert to bin char
            window_code = bin2dec(char(window(:).'+'0'));
            % Replace (i, j) with the image enhancement value
            % (+1 because Matlab arrays start at 1, not 0)
            Inew(i, j) = enh_al(window_code+1) - '0';
        end
    end
    I = Inew;
    % Invert borders, if needed
    if invert, inverted = ~inverted; end
    % Pad I with the correct borders for the next step & clear incorrect ones
    % If inversion is used, only even steps have finite lit pixels, and vice-versa
    I = padarray(I(2:height(I)-1, 2:width(I)-1), [2 2], inverted);
end
end