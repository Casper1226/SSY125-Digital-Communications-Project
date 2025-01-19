function bits_decoded = Soft_Viterbi(received_sym, trellis, channel_noise_std, mod, enc_type)
    % received_sym: received symbols in decimal
    % trellis: generated trellis construction
    % channel_noise_std: standard deviation of the channel noise

    numStates = trellis.numStates;
    numInputSymbols = trellis.numInputSymbols;
    numOutputSymbols = trellis.numOutputSymbols;
    nextStates = trellis.nextStates +1;
    outputs = trellis.outputs;
    
    switch mod
        case 1
            bits_perstep = 2;
            constellation = [-1, 1];
        case 2
            bits_perstep = 1;
            constellation = [(1+1j)/sqrt(2), (-1+1j)/sqrt(2), ...
                              (1-1j)/sqrt(2), (-1-1j)/sqrt(2)];
        case 3
            bits_perstep = 1;
            constellation = [(1 - 1i), (-3 + 3i), (1 + 3i), (-3 - 1i), ...
                             (3 - 3i), (-1 + 1i), (3 + 1i), (-1 - 3i)] / sqrt(10);
        otherwise
            error('Unknown mod')
    end

    numSteps = length(received_sym)/bits_perstep;

    large_positive_number = 1e8;
    pathMetrics = large_positive_number * ones(1, numStates);
    pathMetrics(1) = 0; % Assuming initial state is state 1

    prestates = zeros(numStates, numSteps);

    % Start Viterbi algorithm
    for t = 1:numSteps
        updatePathMetrics = large_positive_number * ones(1, numStates);
        newPrestates = zeros(1, numStates);

        for state = 1:numStates
            currentMetric = pathMetrics(state);
            
            
            for input = 1:numInputSymbols
                nextState = nextStates(state, input);
                output_Input = outputs(state, input);
                
                soft_metric = cal_soft_metric(received_sym, t, output_Input, mod, channel_noise_std, constellation);
                
                metric = currentMetric + soft_metric;
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

    if enc_type == 1 || enc_type == 2 || enc_type == 3
        bits_decoded = zeros(1, numSteps);
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
            bits_decoded(t) = input;
            state = previousState;
        end
    elseif enc_type == 4
        bits_decoded = zeros(1, 2*numSteps); % 每个输入符号对应2个比特
        idx = 2*numSteps;
        for t = numSteps:-1:1
            previousState = prestates(state, t);
             if previousState == 0
                 error('Invalid previous state encountered during traceback.');
             end
            input = -1;
            for i = 1:numInputSymbols
                if nextStates(previousState, i) == state
                    input = i - 1; % 输入符号范围: 0..3
                    break;
                end
            end
            if input == -1
                error('Failed to find input leading to state %d from state %d at time %d.', state, previousState, t);
            end
            bits2 = de2bi(input, 2, 'left-msb'); % 将输入符号转换为2个比特
            bits_decoded(idx-1 : idx) = bits2;
            idx = idx - 2;
            state = previousState;
        end
        bits_decoded = bits_decoded.'; % 转置为列向量
        bits_decoded = bits_decoded(:).'; % 确保是行向量
    else
        error('Unknown enc_type');
    end
end

