clc
clear
modOrder = 16;               % Modulation order
bps = log2(modOrder);        % Bits per symbol
EbNo = (-1:1:8);            % Energy per bit to noise power spectral density ratio in dB
EsNo = EbNo + 10*log10(bps); % Energy per symbol to noise power spectral density ratio in dB
rng(1963);

turboEnc = comm.TurboEncoder('InterleaverIndicesSource','Input port');
turboDec = comm.TurboDecoder('InterleaverIndicesSource','Input port','NumIterations',4);
trellis = poly2trellis(4,[13 15 17],13);
n = log2(turboEnc.TrellisStructure.numOutputSymbols);
numTails = log2(turboEnc.TrellisStructure.numStates)*n;
errRate = comm.ErrorRate;

ber = zeros(1,length(EbNo));
totalBitTarget = 1e6; % Total number of information bits to transmit

for k = 1:length(EbNo)
    errorStats = zeros(1,3);
    totalBits = 0; % Initialize the total transmitted bits for this Eb/No
    L = 1000;      % Fixed frame length (information bits per frame)
    
    while errorStats(2) < 100 && totalBits < totalBitTarget
        % Encode, modulate, and transmit the frame
        data = randi([0 1],L,1);
        intrlvrIndices = randperm(L);
        encodedData = turboEnc(data,intrlvrIndices);
        M = L*(2*n - 1) + 2*numTails; % Output codeword packet length
        rate = L/M;                   % Coding rate for current packet
        snrdB = EsNo(k) + 10*log10(rate); % Signal-to-noise ratio in dB
        noiseVar = 1./(10.^(snrdB/10));   % Noise variance
        modSignal = qammod(encodedData,modOrder, ...
            'InputType','bit','UnitAveragePower',true);
        rxSignal = awgn(modSignal,snrdB);
        demodSignal = qamdemod(rxSignal,modOrder,'OutputType','llr', ...
            'UnitAveragePower',true,'NoiseVariance',noiseVar);
        rxBits = turboDec(-demodSignal,intrlvrIndices); % Demodulated signal is negated
        
        % Update error statistics and total transmitted bits
        errorStats = errRate(data,rxBits);
        totalBits = totalBits + L; % Accumulate the total transmitted bits
    end
    
    % Save the BER data and reset the bit error rate object
    ber(k) = errorStats(1);
    reset(errRate)
end

%system2 with qpsk simulation
N = 1e6;                % simulated bits number
maxNumErrs = 100;       % max errors number
maxNum = 1e6;           % max number 
EbN0 = -1:1:8;          % Eb/N0 range (dB)
BER_sys2 = simulate_ber(2, 2, 2, EbN0, N, maxNumErrs, maxNum);


% Plot the results
figure
semilogy(EbNo,ber,'o-','MarkerSize', 8)
grid
xlabel('Eb/No (dB)')
ylabel('Bit Error Rate')
hold on
semilogy(EbN0, BER_sys2, 'x-','MarkerSize',8)
ylim([1e-5, 1])
legend('Turbo','System2 qpsk','location','sw')
