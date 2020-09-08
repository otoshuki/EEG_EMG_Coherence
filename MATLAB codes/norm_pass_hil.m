function out = norm_pass_hil(signal, trial, band, Fs, f1, f2)
    a = signal(trial-(2*Fs-1) : trial+(5*Fs-1));     
    b = (a - min(a))/(max(a)-min(a));                %Mean normalize signal
    c = filter(f1, f2, b);                           %Notch filter
    d = bandpass(b, band, Fs);                       %Bandpass filter
    out = real(hilbert(d));                           %Hilbert transform to get analytic signal