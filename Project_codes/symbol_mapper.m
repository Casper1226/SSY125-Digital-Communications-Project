function symbols = symbol_mapper(bits, modulation, enc)
    % Define modulation symbol sets
    % BPSK = [-1, 1];
    QPSK = [(+1 + 1i), (-1 + 1i), (+1 - 1i), (-1 - 1i)] / sqrt(2);
    AMPM = [(1 - 1i), (-3 + 3i), (1 + 3i), (-3 - 1i), ...
            (3 - 3i), (-1 + 1i), (3 + 1i), (-1 - 3i)] / sqrt(10);

    switch modulation
        case 1 % BPSK
            % Map bits directly to BPSK symbols
            symbols = 2 * bits - 1; % 0 -> -1, 1 -> +1

        case 2 % QPSK
            % Group bits into pairs and map to QPSK symbols
            bitPairs = reshape(bits, 2, []).'; % Group into 2 bits per symbol
            indices = bi2de(bitPairs, 'left-msb')+1; % Convert to decimal
            symbols = QPSK(indices); % Map to QPSK symbols

        case 3 % AMPM
            if mod(length(bits), 3) ~=0 && enc==0
                bits = [bits, zeros(1, 3 - mod(length(bits), 3))];
            end
            % Group bits into triplets and map to AMPM symbols
            bitTriplets = reshape(bits, 3, []).'; % Group into 3 bits per symbol
            indices = bi2de(bitTriplets, 'left-msb'); % Convert to decimal
            symbols = AMPM(indices + 1); % Map to AMPM symbols

        otherwise
            error('Unsupported modulation type. Use 1 (BPSK), 2 (QPSK), or 3 (AMPM).');
    end
end
