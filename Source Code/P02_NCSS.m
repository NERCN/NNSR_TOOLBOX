      function cleanLFP = P02_NCSS(app,LFP1,set_divfs,fdfmethod,methodtime,timerelocate,set_mode)
        % findpeaklist;
        LFP1 = LFP1 - mean(LFP1) * ones(1,length(LFP1));
        [~, locs] = findpeaks(LFP1);
        num_pks = length(locs);
        locsleft = zeros(1, num_pks);
        [~, locsleft(1)] = min(LFP1(1, 1:locs(1)));
        for ii = 1:num_pks - 1
            [~, M] = min(LFP1(1, locs(ii):locs(ii+1)));
            locsleft(ii+1) = M + locs(ii) - 1;
        end
        % Using template to remove artifact;
            [~, right_pkindex] = getnum_seg(app,num_pks, set_divfs);
            fsdivft = getfdf(app,LFP1(1, locsleft(2):locsleft(right_pkindex)-1),locsleft, right_pkindex,fdfmethod,set_divfs);  
        
            template_raw = get_template_calculate(app,LFP1(1, locsleft(2):locsleft(right_pkindex)-1), fsdivft);
        if timerelocate
            % template_relocate = Template_timerelocate(app,template_raw, fsdivft, locsleft, right_pkindex,methodtime);
        else 
            template_relocate = template_raw;
        end
        noise = Smooth_template(app,template_relocate,set_mode);
        cleanLFP = remove_template_v3(app,LFP1, noise, locsleft,right_pkindex);
        end
