function decoded_bits = Hard_Viterbi(received_sym, trellis)
    % received_sym: received symbols in decimal
    % trellis: generated trellis construction
    
    qpsk_bits = [0 0;0 1;1 0;1 1];

    numStates = trellis.numStates;
    numInputSymbols = trellis.numInputSymbols;
    numOutputSymbols = trellis.numOutputSymbols;
    nextStates = trellis.nextStates + 1;
    outputs = trellis.outputs;

    numSteps = length(received_sym)/2;
     
    large_number = 1e8;
    pathMetrics = large_number * ones(1, numStates);
    pathMetrics(1) = 0; % Assuming initial state is state 1

    prestates = zeros(numStates, numSteps);

    % Start Viterbi algorithm
    for t = 1:numSteps
        updatePathMetrics = large_number * ones(1, numStates);
        newPrestates = zeros(1, numStates);

        for state = 1:numStates
            currentMetric = pathMetrics(state);

            for input = 1:numInputSymbols
                nextState = nextStates(state, input);
                output_symbol = outputs(state, input);

                % Convert symbol to bits
                received_bits = received_sym(2*t-1:2*t);

                output_bits = qpsk_bits(output_symbol+1,:);

                % Compute Hamming distance for hard-decision
                Hamming_dis = sum(received_bits ~= output_bits);

                metric = currentMetric + Hamming_dis;
                if metric < updatePathMetrics(nextState)
                    updatePathMetrics(nextState) = metric;
                    newPrestates(nextState) = state;
                end
            end
        end

        pathMetrics = updatePathMetrics;
        prestates(:, t) = newPrestates;
    end

    % Traceback
    [~, state] = min(pathMetrics);

    decoded_bits = zeros(1, numSteps);
    for t = numSteps:-1:1
        previousState = prestates(state, t);
        if previousState == 0
            error('Invalid previous state encountered during traceback.');
        end
        input = -1;
        for i = 1:numInputSymbols
            if nextStates(previousState, i) == state
                input = i - 1;
                break;
            end
        end
        if input == -1
            error('Failed to find input leading to state %d from state %d at time %d.', state, previousState, t);
        end
        decoded_bits(t) = input;
        state = previousState;
    end
end
