function BER = simulate_ber(enc_type, modu, rec_type, EbN0, N, maxNumErrs, maxNum)
    % simulate_ber
    %
    % input:
    %   enc_type         - encode type
    %   modu             - modulation type
    %   EbN0             - Eb/N0
    %   N                - bits number
    %   maxNumErrs       - 
    %   maxNum           - 
    %
    % output:
    %   BER              

    BER = zeros(1, length(EbN0));
    
    % construct trellis
    if enc_type ~= 0
        switch enc_type
            case 1
                G = [1 0 1; 1 1 1];
                CL = 3;
            case 2
                G = [1 0 1 1 1; 1 0 1 1 0];
                CL = 5;
            case 3
                G = [1 0 0 1 1; 1 1 0 1 1];
                CL = 5;
            case 4
                trellis = construct_trellis_e4();
        end
        
        if enc_type ~= 4
            trellis = construct_trellis(CL, G);
        end
    else
        trellis = [];
    end
    
    for i = 1:length(EbN0) % use parfor ('help parfor') to parallelize  
        totErr = 0;  % Number of errors observed
        num = 0; % Number of bits processed

        while((totErr < maxNumErrs) && (num < maxNum))
            % ===================================================================== %
            % Begin processing one block of information
              % ===================================================================== %
              % [SRC] generate N information bits 
              % Use sigma1 encoder
              % ...
            information_bits = randsrc(1, N, [0 1]);
            
            [bits_enc,~]=conv_encoder(information_bits, enc_type);

            symbols = symbol_mapper(bits_enc,modu, enc_type);
            
            y = Add_asgn(symbols, modu, EbN0(i), rec_type, enc_type);

            if rec_type == 0
                %uncoded
                y = demapping(y, modu);
                bits_decoded = y;
                bits_decoded = bits_decoded(1:end-(length(bits_decoded)-length(information_bits)));
            elseif rec_type ==1
                y = demapping(y, modu);
                bits_decoded = Hard_Viterbi(y, trellis);

            elseif rec_type ==2
                noiseVar = 10^(-EbN0(i)/10);
                channel_noise_std = sqrt(noiseVar);          
                bits_decoded = Soft_Viterbi(y, trellis, channel_noise_std, modu, enc_type);
            end
            bits_decoded = bits_decoded(1:length(information_bits));
            BitErrs = length(find((bits_decoded-information_bits)~=0));
            totErr = totErr + BitErrs;
            num = num + N;
        end
        BER(i) = totErr/num;
    end
end
