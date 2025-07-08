      function [num_seg,right] = P02_getnum_seg(~,num_pks,A)

        C = mod(num_pks - 2,A); % 考虑余数，将之去除
        right = num_pks - C;
        num_seg = (right - 2)/A; % 2指的是开始的节点。
        
        end
        
      function C = P02_minabs(~,A,B)
        M = size(A,2);
        N = size(B,2);
        if M ~= N
            disp("ERROR INPUT!");
        end
        C = A - A;
        for i = 1:M
            if abs(A(i)) < abs(B(i))
                C(i) = A(i);
            else 
                C(i) = B(i);
            end
        end
        end
        
       % function cleanLFP = P02_NCSS(app,LFP1,set_divfs,fdfmethod,methodtime,timerelocate,set_mode)
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
            [~, right_pkindex] = P02_getnum_seg(app,num_pks, set_divfs);
            fsdivft = P02_getfdf(app,LFP1(1, locsleft(2):locsleft(right_pkindex)-1),locsleft, right_pkindex,fdfmethod,set_divfs);  
        
            template_raw = P02_get_template_calculate(app,LFP1(1, locsleft(2):locsleft(right_pkindex)-1), fsdivft);
        if timerelocate
            template_relocate = P02_Template_timerelocate(app,template_raw, fsdivft, locsleft, right_pkindex,methodtime);
        else 
            template_relocate = template_raw;
        end
        noise = P02_Smooth_template(app,template_relocate,set_mode);
        cleanLFP = P02_remove_template_v3(app,LFP1, noise, locsleft,right_pkindex);
        end

      % function cllfp = P02_remove_template_v3(~,raw,noise,locsleft,right_pkindex)
      function cllfp = P02_remove_template_v3(~,raw,noise,locsleft,right_pkindex)
        % 不改变顺序时候，template就是raw本身
        cllfp = raw;
        cllfp(1, locsleft(2):locsleft(right_pkindex)-1) = ...
            raw(1, locsleft(2):locsleft(right_pkindex)-1) - noise;
        %disp("# Removing noise succeed ! ");
        %fprintf('\n');
        end

      % function noise = P02_Smooth_template(~,temp,set_mode)  
      function noise = P02_Smooth_template(~,temp,set_mode)
        switch set_mode
            case "smooth"
                noise = smooth(temp(1,:),temp(2,:))';
            case "seg_smooth"
                noise = temp(2,:) - temp(2,:);
                [sorttemp1,index] = sort(temp(1,:));
                sorttemp2 = temp(2,index);
                z = sorttemp2(1)/abs(sorttemp2(1));
                l = 1;
                for i = 2:size(sorttemp2,2)
                    if sorttemp2(i)  == 0
                        continue;
                    elseif sorttemp2(i)/abs(sorttemp2(i)) == z
                        continue;
                    elseif l == i - 1
                        noise(i - 1) = sorttemp2(i - 1);
                        l = i;
                        z = -z;
                    elseif z == -1
                        N = min(30,i-l);
                        D = min(3,N-1);
                        noise(l:i - 1) = smooth(sorttemp1(l:i - 1) * 1000,sorttemp2(l:i - 1),N,'sgolay' ,D);
                        l = i;
                        z = 1;
                    elseif z == 1
                        N = min(15,i-l);
                        D = min(9,N-1);
                        noise(l:i - 1) = smooth(sorttemp1(l:i - 1)* 1000,sorttemp2(l:i - 1),N,'sgolay' ,D);
                        l = i;
                        z = -1;
                    end
                end
                if l == i
                    noise(l) = sorttemp2(l);
                elseif z == -1
                    N = min(15,i-l+1);
                    D = min(5,N-1);
                    noise(l:i) = smooth(sorttemp1(l:i),sorttemp2(l:i),N,'sgolay' ,D);
                elseif z == 1
                    N = min(30,i-l+1);
                    D = min(25,N-1);
                    noise(l:i) = smooth(sorttemp1(l:i),sorttemp2(l:i),N,'sgolay' ,D);
                end
                [~,index2] = sort(index);
                noise = noise(index2);
            otherwise
        %           disp("# ERROR TEMP PROCESSING MODE ! RESET TEMP PROCESSING MODE . ");
                return;
        end
      end