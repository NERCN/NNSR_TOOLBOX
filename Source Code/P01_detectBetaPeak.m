    function [betaPeakFreq, betaPeakValue, betaPeakWidth] = P01_detectBetaPeak(~,f, pxx)

        pxx = abs(pxx);

        beta_range = [13 30];
        idx_beta = (f >= beta_range(1) & f <= beta_range(2));
        f_beta = f(idx_beta);
        pxx_beta = pxx(idx_beta);

        idx_fit = (f >= 6 & f <= 40);
        x = f(idx_fit);
        y = pxx(idx_fit);

        fitType = fittype(@(a,b,c,x) a + b./(c+x), ...
                         'independent', 'x', ...
                         'dependent', 'y');

        try
            [fitResult, ~] = fit(x, y, fitType, 'StartPoint', [1,1,1]);

            a = fitResult.a;
            b = fitResult.b;
            c = fitResult.c;

            y_fit = a + b./(c + x);

            OCI = y - y_fit;

            idx_beta_in_fit = (x >= beta_range(1) & x <= beta_range(2));
            OCI_beta = OCI(idx_beta_in_fit);
            x_beta = x(idx_beta_in_fit);
            y_beta = y(idx_beta_in_fit);

            [PKS, LOCS] = findpeaks(OCI_beta);

            if ~isempty(PKS)
                [~, max_idx] = max(PKS);
                peak_loc = LOCS(max_idx);
                betaPeakFreq = x_beta(peak_loc);
                betaPeakValue = y_beta(peak_loc);

                half_max = PKS(max_idx) / 2;
                idx_left = find(OCI_beta(1:peak_loc) <= half_max, 1, 'last');
                if isempty(idx_left)
                    idx_left = 1;
                end
                
                idx_right = find(OCI_beta(peak_loc:end) <= half_max, 1, 'first') + peak_loc - 1;
                if isempty(idx_right)
                    idx_right = length(OCI_beta);
                end
                
                betaPeakWidth = x_beta(idx_right) - x_beta(idx_left);
            else

                [maxVal, maxIdx] = max(pxx_beta);
                betaPeakFreq = f_beta(maxIdx);
                betaPeakValue = maxVal;
                betaPeakWidth = 4;
            end
        catch

            [maxVal, maxIdx] = max(pxx_beta);
            betaPeakFreq = f_beta(maxIdx);
            betaPeakValue = maxVal;
            betaPeakWidth = 4; 
        end
    end
