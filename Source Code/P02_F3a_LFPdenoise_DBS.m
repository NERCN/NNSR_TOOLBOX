function cl = P02_F3a_LFPdenoise_DBS(app,raw,channel,set_divfs,set_win)
    % set_divfs = 1;
    % set_win = 2000;
    set_mode = "seg_smooth";% "smooth"|"origin"|"mean"; for version 2;% "smooth"|"seg_smooth"; for version 3;
    fdfmethod = "FFTm"; % "FFTm-min"|"PARRM"|"LowFre"|"SMSE"|"FFTm"|"PSDm"|"Origin";"Origin" means same as version 2;
    methodtime = "solve";% "Traverse"|"solve"|"solvewithy"
    timerelocate = false; % true|false;
    if size(raw,1) > size(raw,2)
        raw = raw';
    end
    cl = raw;
    L = length(raw);
    noverlength = 1000;
    for i = 1:channel
        if L > set_win
            window_num = floor(L / set_win) - 1;
            clLFP = ones(1 , L) * inf;
            for win_i = 1:window_num
             %   fprintf(['# Processing window num :',num2str(win_i),'\n'])
                LFPtemp = raw(i,set_win * (win_i - 1) + 1 : set_win * win_i + noverlength);
                cltemp = P02_NCSS(app,LFPtemp,set_divfs,fdfmethod,methodtime,timerelocate,set_mode);
                clLFP(set_win * (win_i - 1) + 1 : set_win * win_i + noverlength) = P02_minabs(app,cltemp , clLFP(set_win * (win_i - 1) + 1 : set_win * win_i + noverlength));
            end
            win_i = window_num + 1;
            %fprintf(['# Processing window num :',num2str(win_i),'\n'])
            LFPtemp = raw(i,set_win * (win_i - 1) + 1 : end);
            cltemp = P02_NCSS(app,LFPtemp,set_divfs,fdfmethod,methodtime,timerelocate,set_mode);
            clLFP(set_win * (win_i - 1) + 1 : end) = P02_minabs(app,cltemp , clLFP(set_win * (win_i - 1) + 1 : end));
            cl(i,:) = clLFP;
        else
            cl(i,:) = P02_NCSS(app,raw(i,:),set_divfs,fdfmethod,methodtime,timerelocate,set_mode);
        end
        cl(i,:) = P02_ClearDBSStartEnd(app,cl(i,:));
    end
end