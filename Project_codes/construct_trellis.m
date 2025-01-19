function trellis = construct_trellis(CL, G)
    % CL: constraint length
    % G: generator matrix

    numInputSymbols = 2;
    numOutputSymbols = 2^size(G, 1);
    numStates = 2^(CL - 1);

    nextStates = [];
    outputs = [];

    for state = 1:numStates

        reg = de2bi(state - 1, CL - 1, 'left-msb');

        nextStates_row = [];
        outputs_row = [];

        for input = 0:1
            update_reg = [input, reg(1:end - 1)];

            nextState_bits = update_reg;
            nextState = bi2de(nextState_bits, 'left-msb') ;

            nextStates_row = [nextStates_row, nextState];

            full_reg = [input, reg];
            output_bits = mod(G * full_reg', 2)';

            output_symbol = bi2de(output_bits, 'left-msb');
            outputs_row = [outputs_row, output_symbol];
        end
        nextStates = [nextStates; nextStates_row];
        outputs = [outputs; outputs_row];
    end

    trellis.numInputSymbols = numInputSymbols;
    trellis.numOutputSymbols = numOutputSymbols;
    trellis.numStates = numStates;
    trellis.nextStates = nextStates;
    trellis.outputs = outputs;
end

