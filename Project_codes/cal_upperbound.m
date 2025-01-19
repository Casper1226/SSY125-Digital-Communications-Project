function P = cal_upperbound(num)
% num: which encoder you want to plot the upper bound

EbN0 = -1:1:8; % power efficiency range1
n=9;

switch num
    case 1
        G = [1 0 1; 1 1 1];
        CL = 3;
        trellis = construct_trellis(CL,G);
        spect = distspec(trellis,n);
        w = spect.weight;
        d = spect.dfree:(n+spect.dfree-1);

    case 2
        G = [1 0 1 1 1; 1 0 1 1 0];
        CL = 5;
        trellis = construct_trellis(CL,G);
        spect = distspec(trellis,n);
        w = spect.weight;
        d = spect.dfree:(n+spect.dfree-1);

    case 3
        G = [1 0 0 1 1; 1 1 0 1 1];
        CL = 5;
        trellis = construct_trellis(CL,G);
        spect = distspec(trellis,n);
        w = spect.weight;
        d = spect.dfree:(n+spect.dfree-1);

    case 4
        trellis = construct_trellis_e4();
        spect = distspec(trellis,n);
        w = spect.weight;
        d = spect.dfree:(n+spect.dfree-1);
end

P=zeros(1,length(EbN0));
for h = 1:length(EbN0) % use parfor ('help parfor') to parallelize
    snr = 10^(EbN0(h)/10);
    inside = (2.*d.*0.5.*snr);%qpsk
    %inside = (2.*d.*snr);
    P(h) = sum(w .* qfunc(sqrt(inside)));
end

end