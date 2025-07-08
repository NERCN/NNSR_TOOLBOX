      function cllfp = remove_template_v3(~,raw,noise,locsleft,right_pkindex)
        % 不改变顺序时候，template就是raw本身
        cllfp = raw;
        cllfp(1, locsleft(2):locsleft(right_pkindex)-1) = ...
            raw(1, locsleft(2):locsleft(right_pkindex)-1) - noise;
        %disp("# Removing noise succeed ! ");
        %fprintf('\n');
        end