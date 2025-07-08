      function fdf = getfdf(~,LFP1,dotlist,finaldot,method,set_divfs)
        switch method
            case "SMSE"
                % %smooth and calculating mse error;
                N = (finaldot - 2)/set_divfs;
                L = dotlist(finaldot) - dotlist(2);
                fdflist = N/(L+2):1e-6:N/(L-2);
                n = 1:L;
                temp1 = n'*fdflist - floor(n' * fdflist);
                error = fdflist - fdflist;
                window = L/50;
                for kk = 1:length(fdflist)
                    noise = smooth(temp1(:,kk)',LFP1,window)';
                    %     error(kk) = mean(((LFP1 - noise)./LFP1).^2);
                    error(kk) = mean((LFP1 - noise).^2);
                end
                % [errormin,fdfindex] = min(error);
                [~,fdfindex] = min(error);
                fdf = fdflist(fdfindex);
                % disp(['At this frequency,  MSE is: ',num2str(errormin,10)])
            case "PSDm"
                % Use psd caculating
                L = min(round(length(LFP1)/4),500);
                %     [pxx,m] = pwelch(LFP1,2*L,L,1e8,1000);
                [pxx,m] = pwelch(LFP1,2*L,L,1e8,1000);
                [~,index] = max(pxx);
                fdf = m(index) / 1000 / set_divfs;
            case "FFTm"
                % Use psd caculating
        %         L = max(length(LFP1),16777216);
                L = max(length(LFP1),8388608);
                a = fft(LFP1,L);
                [~,p]=max(abs(a));
                fdf = p / L / set_divfs;
            case "FFTm-min"
                L = max(length(LFP1),8388608);
                a = fft(LFP1,L);
                [~,locsa] = findpeaks(abs(a),'minpeakheight',4e6);
                p = locsa(1);
                fdf = p / L / set_divfs;
            case "Origin"
                N = (finaldot - 2)/set_divfs;
                L = dotlist(finaldot) - dotlist(2);
                fdf = N/L;
            case "LowFre" %对采样率低于1000Hz的情况???
                L = max(length(LFP1),8388608);
                a = fft(LFP1,L);
                [~,p]=max(abs(a));
                fdf = 1000 - p / L / set_divfs;
            % case "PARRM"
            %     stratP = 1000/60;
            %     Period = FindPeriodLFP(LFP1,[1,length(LFP1)-1],stratP);
            %     fdf = 1 / Period / set_divfs;
        end
        fprintf('# Estimating succeed ! With time ');
        disp(['# Frequency may be ',num2str(fdf*1000 * set_divfs,10),' with Method:"',char(method),'".']);
        end