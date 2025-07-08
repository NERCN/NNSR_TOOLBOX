    function bandPower = P02_calculateBandPower(psd, freqs, bandRange)

        idx = freqs >= bandRange(1) & freqs <= bandRange(2);
        bandPower = trapz(freqs(idx), psd(idx));
    end