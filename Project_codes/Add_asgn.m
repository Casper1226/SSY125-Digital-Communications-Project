function [y] = Add_asgn(x, modul_type, EbN0,  rec, enc)
    % x: input symbol vector
    % modul_type: 1 (BPSK), 2 (QPSK), 3 (AMPM)
    % EbN0: signal-to-noise energy ratio (dB)
    % rec: receiver type
    % enc: coding type
    % y: output symbol (after adding noise)

    % Determine bits per symbol (R) based on modulation type
    switch modul_type
        case 1 % BPSK
            R = log2(2);
        case 2 % QPSK
            R = log2(4);
        case 3 % AMPM
            R = log2(8);
        otherwise
            error('Invalid modulation type. Use 0 (BPSK), 1 (QPSK), or 2 (AMPM).');
    end

    %%
    Es = mean(abs(x).^2);
    snr = 10^(EbN0/10);
    
    if rec==0 && modul_type==1
        sigma = Es/(snr*0.5*R*2);
        n = sqrt(sigma)*1./sqrt(2)*(randn(1,length(x)));
    elseif rec == 0 && modul_type~=1
        sigma = Es/(snr*0.5*R*2);
        n = sqrt(sigma)*1./sqrt(2)*(randn(1,length(x)) + 1i*randn(1,length(x)));
    elseif (rec == 1 || rec == 2) && (enc==1 || enc==2 || enc==3) && (modul_type ==1)
        sigma = Es/(snr*0.5*R*2*0.5);
        n  = sqrt(sigma)*1./sqrt(2)*(randn(1,length(x)) );
    elseif (rec == 1 || rec == 2) && (enc==1 || enc==2 || enc==3) && (modul_type ~=1)
        sigma = Es/(snr*0.5*R*2*0.5);
        n  = sqrt(sigma)*1./sqrt(2)*(randn(1,length(x)) + 1i*randn(1,length(x)));
    elseif rec == 2 && (enc==4)
        sigma = Es/(snr*0.5*R*2/3);  
        n  = sqrt(sigma)*1./sqrt(4)*(randn(1,length(x)) + 1i*randn(1,length(x)));
    end   

    y=x+n;
end
