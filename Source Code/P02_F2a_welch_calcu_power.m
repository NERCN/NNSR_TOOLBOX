function [Pxxmat,linemat,f] = P02_F2a_welch_calcu_power(app,Data,nfft,fs,noverlap,window)
    % Data is one channel，IF not
    % nargin - return the num of inputs
    try
    [Pxxmat,f] = pwelch(Data,window,noverlap,nfft,fs);
    catch
    [Pxxmat,f] = pwelch(Data);
    end
    % window = hanning(fs);% defult
       if app.Is_Log_Plot.Value == 1
          linemat = 10*log10(Pxxmat);
       elseif app.Is_Log_Plot.Value == 0
          linemat = (Pxxmat);
       end
end