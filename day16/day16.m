% (): Run example puzzle, (<anything>): Run personal puzzle
function day16(~)

%% Read data from current folder
p = cd; p = p(end-4:end);
switch nargin
    case 0
        file = p + "_example.txt";
        data = readtable(file, Delimiter = ",", TextType = 'char');
    otherwise
        file = p + "_data.txt";
        data = readtable(file, Delimiter = "", TextType = 'char', ReadVariableNames = 0);
        data.Properties.VariableNames{1} = 'packet';
end

% Convert packets from string to numeric representation
cell_enc_packets = binarize_packets(data.packet);

% Decode packets
for i = numel(cell_enc_packets):-1:1
    [dec_packet(i), ~, c_version(i)] = process_packet(cell_enc_packets{i}, Inf, 0);

    %% Part 1
    disp("Part 1: The sum of version numbers is " + c_version(i))
    if nargin, assert(c_version(i) == 981, "Part 1 is incorrect."), end % Validate personal puzzle
    if ~nargin, assert(c_version(i) == data.version_sum(i), "Part 1 is incorrect."), end % Validate example puzzles

    %% Part 2
    disp("Part 2: The transmission value is " + dec_packet(i).value)
    if nargin, assert(dec_packet(i).value == 299227024091, "Part 2 is incorrect."), end % Validate personal puzzle
    if ~nargin, assert(dec_packet(i).value == data.eval(i), "Part 2 is incorrect."), end % Validate example puzzles
end
end

%% Auxiliar functions
% Converts each hex value into a char(4), e.g., '1111'
function cell_p = binarize_packets(p)
cell_p = {};
for i = numel(p):-1:1
    t = dec2bin(hex2dec(compose("%c", p{i})), 4).';
    cell_p(i) = {t(:).'};
end
end

% Defines the number of bits for each packet grouping
function fmt = get_packet_format()
fmt_lv = struct('more', 1, 'lv', 4);
fmt_op_lt0 = struct('total_length', 15);
fmt_op_lt1 = struct('nr_subpackets', 11);
fmt_op = struct('length_type_id', 1, 'lt0', fmt_op_lt0, 'lt1', fmt_op_lt1);
fmt = struct('version', 3, 'type_id', 3, 'type_op', fmt_op, 'type_lv', fmt_lv);
end

% Defines the operator functions
function f = op_funcs(op_type)
switch op_type
    case 0, f = @sum;
    case 1, f = @prod;
    case 2, f = @min;
    case 3, f = @max;
    case 5, f = @(x) cast(x(1) > x(2), 'like', x(1));
    case 6, f = @(x) cast(x(1) < x(2), 'like', x(1));
    case 7, f = @(x) cast(x(1) == x(2), 'like', x(1));
end
end

% Process a binary encoded packet
function [dec_packet, i, c_ver] = process_packet(enc_packet, c_proc_limit, c_ver)
fmt = get_packet_format(); % Packets format
i = 1; % Bit pointer
p = 1; % Packet counter
while true
    % Break if a #packets limit is defined
    if p > c_proc_limit, break, end
    % Break if bit pointer is above the min packet size (11 bits)
    if i - 1 > numel(enc_packet) - 11, break, end
    % Read version
    [dec_packet(p).version, i] = read_field_dec(enc_packet, i, fmt.version);
    c_ver = c_ver + dec_packet(p).version; % Count versions for Part 1
    % Read type_id
    [dec_packet(p).type_id, i] = read_field_dec(enc_packet, i, fmt.type_id);
    % Process type_id
    switch dec_packet(p).type_id
        case 4 % Literal value
            [dec_packet(p).value, i] = read_lv_dec(enc_packet, i, fmt.type_lv);
            %dec_subpackets = [];
        otherwise % Operator
            % Read length type id
            [length_type_id, i] = read_field_dec(enc_packet, i, fmt.type_op.length_type_id);
            % Process length type id
            switch length_type_id
                case 0 % Sub-packets are bounded by a total length in bits
                    [total_length, i] = read_field_dec(enc_packet, i, fmt.type_op.lt0.total_length);
                    [dec_subpackets, j, c_ver] = process_packet(enc_packet(i:i+total_length-1), Inf, c_ver);
                case 1 % Sub-packets are bounded by a total number of sub-packets
                    [c_subpackets, i] = read_field_dec(enc_packet, i, fmt.type_op.lt1.nr_subpackets);
                    [dec_subpackets, j, c_ver] = process_packet(enc_packet(i:end), c_subpackets, c_ver);
            end
            % Adjust the bit pointer after sub-packets processing
            i = i + j - 1;
            % Get the operator function to apply from the type_id
            op_fun = op_funcs(dec_packet(p).type_id);
            % Apply op_fun to an array of sub-packet resolved values
            dec_packet(p).value = op_fun(arrayfun(@(x) dec_subpackets(x).value, 1:numel(dec_subpackets)));
    end
    %dec_packet(p).subpckts = dec_subpackets;
    p = p + 1;
end
end

% Read a binary char of size fsize
function [val, next_pos] = read_field_bin(data, pos, fsize)
end_pos = pos + fsize - 1;
val = data(pos:end_pos);
next_pos = end_pos + 1;
end

% Convert a binary char of size fsize into a decimal value
function [vald, next_pos] = read_field_dec(data, pos, fsize)
[val, next_pos] = read_field_bin(data, pos, fsize);
vald = bin2dec(val);
end

% Process a literal value type_id
function [val, pos] = read_lv_dec(data, pos, s)
lv = '';
while true
    % Check if more groups are next
    [more, pos] = read_field_dec(data, pos, s.more);
    % Get the bits for the group
    [lv(:, end+1), pos] = read_field_bin(data, pos, s.lv);
    if ~more, break, end
end
val = bin2dec(lv(:).');
end
