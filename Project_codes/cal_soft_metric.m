function softMetric = cal_soft_metric(received_sym, t, outputSymbol, mod, channel_noise_std, constellation)
    switch mod
        case 1  % BPSK
            bpsk_bits = [0 0;0 1;1 0;1 1];
            symbol1 = constellation(bpsk_bits(outputSymbol+1,1) + 1);
            symbol2 = constellation(bpsk_bits(outputSymbol+1,2) + 1);
            dist2 = abs(received_sym(2*t - 1) - symbol1)^2 + ...
                    abs(received_sym(2*t) - symbol2)^2;
        case 2  % QPSK
            symbol = constellation(outputSymbol + 1);
            dist2 = abs(received_sym(t) - symbol)^2;
        case 3  % AMPM
            symbol = constellation(outputSymbol + 1);
            dist2 = abs(received_sym(t) - symbol)^2;
    end
    softMetric = (dist2 / (2 * channel_noise_std^2));  % positive distance
end