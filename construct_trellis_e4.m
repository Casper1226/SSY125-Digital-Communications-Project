function trellis = construct_trellis_e4()
    % ==================== E4: rate=2/3  ====================
    % 
    CL = 5;  % 
    numStates = 8;  % 2^(CL-2)=2^3=8
    numInputSymbols = 4;  % (2bits inout => 0..3)
    numOutputSymbols= 8;  % (3bits output => 0..7)

    nextStates = zeros(numStates,numInputSymbols);
    outputs    = zeros(numStates,numInputSymbols);

    for state = 1:numStates
        for input = 1:numInputSymbols
             %initialize register
             reg_1 = de2bi(state-1, CL-2, 'left-msb'); 
             
             G1 = de2bi(input-1, 2, 'left-msb');  % [b0 b1]
           
             % reg(2,2) = bitxor(G1(2), reg(1,1));
             % reg(2,3) = bitxor(G1(1), reg(1,2));
             % reg(2,1) = reg(1,3);
  
             new_reg = zeros(1,3,'logical'); 
             new_reg(1) = reg_1(3);                % (2,1) = (1,3)
             new_reg(2) = bitxor(G1(2), reg_1(1));  % (2,2) = bitxor
             new_reg(3) = bitxor(G1(1), reg_1(2));  % (2,3)

             % compute nextState:
             nextStates(state, input) = bi2de(new_reg, 'left-msb') ;

             % compute output
             % G0 = reg(1,3)
             G0 = reg_1(3);
             % output_3bits => [G0 G1(2bits)]
             out_bits = [G0, G1(1), G1(2)];
             out_sym  = bi2de(out_bits, 'left-msb');  % => 0..7
             outputs(state, input) = out_sym;
             
        end
    end

    trellis = struct('numInputSymbols',numInputSymbols,...
                         'numOutputSymbols',numOutputSymbols,...
                         'numStates',numStates,...
                         'nextStates',nextStates,...
                         'outputs',outputs);
end
