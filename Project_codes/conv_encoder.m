function [bits_enc,x_hard]=conv_encoder(bits, enc_type)


% x_hard: Hard-decision output values for Viterbi decoding (fixed mapping).
x_hard=[];

% d1 and d2: represent the generator matrices for encoding
d1 = []; % polynomial:g1(x)=1 + x^2
d2 = []; % polynomial:g2(x)=1 + x + x^2

% Initialize parameters based on the specified encoding type
switch enc_type
    case 0
        % Uncoded transmission: No encoding is performed
        bits_enc = bits; % Directly assign the input bits to output
        % Note: Hard and soft Viterbi decoding are not applicable here
        
    case 1
        % Initialize the input bits for convolution
        bits_conv = bits;
        
        % Define generator polynomials
        d1 = [1, 0, 1]; % Polynomial g1 with octal value 5
        d2 = [1, 1, 1]; % Polynomial g2 with octal value 7
        
        % Define hard and soft Viterbi decoding outputs (example patterns)
        x_hard = [0 0; 1 1; 0 1; 1 0; 1 1; 0 0; 1 0; 0 1];
        
    case 2
        % Initialize the input bits for convolution
        bits_conv = bits;
        
        % Define generator polynomials
        d1 = [1, 0, 1, 1, 1]; % Polynomial g1 with octal value 27
        d2 = [1, 0, 1, 1, 0]; % Polynomial g2 with octal value 26
        
        % Define hard and soft Viterbi decoding outputs (example patterns)
        x_hard = [0 0; 1 0; 1 1; 0 1; 1 1; 0 1; 0 0; 1 0; 
                  0 0; 1 0; 1 1; 0 1; 1 1; 0 1; 0 0; 1 0; 
                  1 1; 0 1; 0 0; 1 0; 0 0; 1 0; 1 1; 0 1;
                  1 1; 0 1; 0 0; 1 0; 0 0; 1 0; 1 1; 0 1];
        
    case 3
        % Initialize the input bits for convolution
        bits_conv = bits;
        
        % Define generator polynomials
        d1 = [1, 0, 0, 1, 1]; % Polynomial g1 with octal value 23
        d2 = [1, 1, 0, 1, 1]; % Polynomial g2 with octal value 33
        
        % Define hard and soft Viterbi decoding outputs (example patterns)
        x_hard = [0 0; 1 1; 1 1; 0 0; 0 0; 1 1; 1 1; 0 0; 
                  0 1; 1 0; 1 0; 0 1; 0 1; 1 0; 1 0; 0 1; 
                  1 1; 0 0; 0 0; 1 1; 1 1; 0 0; 0 0; 1 1;
                  1 0; 0 1; 0 1; 1 0; 1 0; 0 1; 0 1; 1 0];
        
end


% Encoding data for encoder types 1, 2, and 3
if enc_type == 1 || enc_type == 2 || enc_type == 3
    % Perform convolution of the input bits with generator polynomials
    c1 = mod(conv(bits_conv, d1), 2); % Convolve with generator d1 and apply modulo-2
    c2 = mod(conv(bits_conv, d2), 2); % Convolve with generator d2 and apply modulo-2
    
    % Truncate the convolution outputs to match the input length
    truncation_length = length(d1) - 1; % Length of the shift register
    c1 = c1(1:end-truncation_length);
    c2 = c2(1:end-truncation_length);
    
    % Combine the two streams into a single interleaved encoded sequence
    bits_enc = [c1; c2]; % Arrange c1 and c2 in rows
    bits_enc = reshape(bits_enc, 1, []); % Convert to a single row (interleaving)
end

% Encoding data for encoder type 4
if enc_type == 4
    % Initialize the shift register
    shift_register = [0, 0, 0];
    
    % Extract alternating bits for c2 and c3
    c2 = bits(1:2:end); % Take odd-indexed bits
    c3 = bits(2:2:end); % Take even-indexed bits
    
    % Initialize c1 for storing computed values
    c1 = zeros(length(bits)/2, 1); % Length is half the input bits
    
    % Calculate c1 using the shift register and XOR operations
    for i = 1:length(bits)/2
        c1(i) = shift_register(3); % Output the last register value
        % Update the shift register based on current input bits
        shift_register(3) = bitxor(shift_register(2), bits(2*i-1));
        shift_register(2) = bitxor(shift_register(1), bits(2*i));
        shift_register(1) = c1(i); % Update with the latest c1 value
    end
    
    % Combine c1, c2, and c3 into the final encoded sequence
    bits_enc = zeros(1, length(c1) + length(c2) + length(c3)); % Preallocate space
    bits_enc(1:3:end) = c1; % Assign c1 to every third position
    bits_enc(2:3:end) = c2; % Assign c2 to every third position (offset by 1)
    bits_enc(3:3:end) = c3; % Assign c3 to every third position (offset by 2)
    
    % Convert to a column vector
    bits_enc = bits_enc(:); 
end


end