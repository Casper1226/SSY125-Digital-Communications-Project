% ======================================================================= %
% SSY125 Project Part 2
% main 
% ======================================================================= %

clear;
clc;

% ======================================================================= %
% Simulation Options
% ======================================================================= %
N = 1e6;                % simulated bits number
maxNumErrs = 100;       % max errors number
maxNum = 1e6;           % max number 
EbN0 = -1:1:8;          % Eb/N0 range (dB)

% ======================================================================= %
% define the combinations of codeing, modulate and receiver
% ======================================================================= %
% coding type
% 0: uncode/ receiver using 0
% 1,2,3: sigma 1 2 3
% 4
% Modulate type
% 1: BPSK
% 2: QPSK
% 3: AMPM
%receiver type
%0 uncoded
%1 hard-viterbi  2 soft-vitebi

%every row  [enc_type, modulation_type, rec_type]
%Please uncomment the test you want and comment the others
%test1
combinations = [
    0, 2, 0;
    2, 2, 1;
    2, 2, 2
];
%test2
% combinations = [
%     1, 2, 2;
%     2, 2, 2;
%     3, 2, 2
% ];
%test3
% combinations = [
%     0, 1, 0;
%     3, 1, 2;
%     0, 2, 0;
%     3, 2, 2;
%     0, 3, 0;
%     4, 3, 2
% ];

num_combinations = size(combinations, 1);

% BER matrix
BER_all = zeros(num_combinations, length(EbN0));  % [combination, EbN0]

% ======================================================================= %
% simulate
% ======================================================================= %
for comb_idx = 1:num_combinations
    enc_type = combinations(comb_idx, 1);
    modulation_type = combinations(comb_idx, 2);
    rec_type = combinations(comb_idx, 3);
    
    fprintf('Simulating: enc_type=%d, Modulation=%d, receiver_type =%d\n', enc_type, modulation_type, rec_type);
    
    % run simulate_ber function
    BER_sim = simulate_ber(enc_type, modulation_type,rec_type, EbN0, N, maxNumErrs, maxNum);
    
    % write BER
    BER_all(comb_idx, :) = BER_sim;
    disp(BER_sim);
end

% ======================================================================= %
% simulated BER  theory 曲线 (only QPSK)
% ======================================================================= %
%BER_theory = qfunc(sqrt(2 * 10.^(EbN0/10)));
%theory_type = 'QPSK_uncode_upperbound'


% ======================================================================= %
% plot BER figure
% ======================================================================= %
figure;

colors = lines(num_combinations +1);  

for comb_idx = 1:num_combinations
    enc_type = combinations(comb_idx, 1);
    modulation_type = combinations(comb_idx, 2);
    rec_type = combinations(comb_idx, 3);
    BER_sim = BER_all(comb_idx, :);
    
    if enc_type == 0
        label = sprintf('Uncoded (Mod %d)', modulation_type);
        marker = 'o-';
    else
        label = sprintf('Coded (enc_type=%d, Mod %d, receiver %d)', enc_type, modulation_type, rec_type);
        marker = 'x-';
    end
    
    semilogy(EbN0, BER_sim, marker, 'Color', colors(comb_idx, :), ...
             'LineWidth', 1.5, 'MarkerSize', 8, 'DisplayName', label);
    hold on;
end

% plot ber-theory
% upper bound soft-receiver
%1,2,3,4 correspond
% BER_theory = cal_upperbound(2);
% theory_type2 = sprintf('Coded theory soft receiver (enc_type=%d)', 2);
% 
% semilogy(EbN0, BER_theory, 'k--', 'LineWidth', 2, 'DisplayName', theory_type2);
% 
% BER_theory = cal_upperbound(1);
% theory_type1 = sprintf('Coded theory soft receiver (enc_type=%d)', 1);
% semilogy(EbN0, BER_theory, '--', 'LineWidth', 2, 'DisplayName', theory_type1);
% 
% BER_theory = cal_upperbound(3);
% theory_type3 = sprintf('Coded theory soft receiver (enc_type=%d)', 3);
% semilogy(EbN0, BER_theory, '--', 'LineWidth', 2, 'DisplayName', theory_type3);


xlabel('Eb/N0 [dB]');
ylabel('BER');
ylim([1e-4 1]);    % set ylim

grid on;
title('BER versus Eb/N0 for Different Systems');
legend('show', 'Location', 'best');
hold off;
