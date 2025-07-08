function [peakFreq, peakPower, residuals, fittedCurve] = P02_detectBetaPeak(psd, freqs, betaRange, varargin)
    

    p = inputParser;
    addParameter(p, 'UseLog', false, @islogical);
    addParameter(p, 'FreqRange', [5, 40], @(x) isnumeric(x) && length(x) == 2);
    parse(p, varargin{:});
    
    useLog = p.Results.UseLog;
    freqRange = p.Results.FreqRange;
    

    fitIdx = freqs >= freqRange(1) & freqs <= freqRange(2);
    x = freqs(fitIdx);
    y = psd(fitIdx);
    

    if useLog
        y = 10 * log10(y);
    end
    
    if length(x) < 10
        peakFreq = mean(betaRange);
        peakPower = mean(y);
        residuals = [];
        fittedCurve = [];
        return;
    end
    
    try

        fitType = fittype(@(a,b,c,x) a + b./(c+x), ...
                          'independent', 'x', 'dependent', 'y');
        

        [fitResult, ~] = fit(x, y, fitType, 'StartPoint', [1, 1, 1]);
        

        a = fitResult.a;
        b = fitResult.b;
        c = fitResult.c;

        fittedCurve = a + b./(c + x);
        residuals = y - fittedCurve;

        betaIdx = x >= betaRange(1) & x <= betaRange(2);
        betaResiduals = residuals(betaIdx);
        betaFreqs = x(betaIdx);
        betaOriginal = y(betaIdx);

        [PKS, LOCS] = findpeaks(betaResiduals);
        
        if ~isempty(PKS)

            [~, maxIdx] = max(PKS);
            peakFreq = betaFreqs(LOCS(maxIdx));
            peakPower = betaOriginal(LOCS(maxIdx));
        else

            [peakPower, maxIdx] = max(betaOriginal);
            peakFreq = betaFreqs(maxIdx);
        end
        
    catch

        betaIdx = freqs >= betaRange(1) & freqs <= betaRange(2);
        betaFreqs = freqs(betaIdx);
        betaPsd = psd(betaIdx);
        
        if useLog
            betaPsd = 10 * log10(betaPsd);
        end
        
        [peakPower, maxIdx] = max(betaPsd);
        peakFreq = betaFreqs(maxIdx);
        residuals = [];
        fittedCurve = [];
    end
end