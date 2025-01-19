function bits_hat = demapping(symbols, mod)
    % DEMAPPING: Maps received symbols to corresponding decimal symbols.
    %
    % Inputs:
    %   received_symbols: Received complex symbols (vector).
    %   modulation_scheme: Modulation type (1-'BPSK', 2-'QPSK', 3-'AMPM').
    %
    % Output:
    %   demapped_symbols: Decimal symbol indices after demapping (vector).
    
    BPSK = [-1 1];
    QPSK = [(+1 + 1i) (-1 + 1i) (+1 - 1i) (-1 - 1i)]/sqrt(2);
    AMPM = [(1 + -1i) (-3 + 3i) (1 +  3i) (-3 - 1i) (3 - 3i) (-1 + 1i) (+3 + 1i) (-1 - 3i)]/sqrt(10);

    symbol_length = length(symbols);
        switch mod
    case 1
        y_mat = repmat(symbols,2,1);
        const_mat = repmat(transpose(BPSK),1,symbol_length);
        x_abs_mat = abs(y_mat - const_mat);
        [~,symbol_index_hat] = min(x_abs_mat);
        bits_hat = de2bi((symbol_index_hat-1)','left-msb');
        bits_hat = reshape(bits_hat',1,symbol_length);
    case 2
        y_mat = repmat(symbols,4,1);
        const_mat = repmat(transpose(QPSK),1,symbol_length);
        x_abs_mat = abs(y_mat - const_mat);
        [~,symbol_index_hat] = min(x_abs_mat);
        bits_hat = de2bi((symbol_index_hat-1)','left-msb');
        bits_hat = reshape(bits_hat',1,2*symbol_length);
    case 3
        y_mat = repmat(symbols,8,1);
        const_mat = repmat(transpose(AMPM),1,symbol_length);
        x_abs_mat = abs(y_mat - const_mat);
        [~,symbol_index_hat] = min(x_abs_mat);
        bits_hat = de2bi((symbol_index_hat-1)','left-msb');
        bits_hat = reshape(bits_hat',1,3*symbol_length);
    otherwise
        error('demapper???')
        end
    
end


