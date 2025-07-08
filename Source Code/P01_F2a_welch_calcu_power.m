function [Pxxmat, linemat, f] = P01_F2a_welch_calcu_power(~, Data, nfft, fs, noverlap, window, ISLOG)
    try
        [Pxxmat, f] = pwelch(Data, window, noverlap, nfft, fs);
    catch
        [Pxxmat, f] = pwelch(Data);
    end

    % Convert to logarithmic scale if requested
    if ISLOG == 1
        linemat = 10 * log10(Pxxmat);
    else
        linemat = Pxxmat;
    end
end
