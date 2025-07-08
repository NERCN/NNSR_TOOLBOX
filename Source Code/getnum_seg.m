      function [num_seg,right] = getnum_seg(~,num_pks,A)

        C = mod(num_pks - 2,A); % 考虑余数，将之去除
        right = num_pks - C;
        num_seg = (right - 2)/A; % 2指的是开始的节点。
        
        end