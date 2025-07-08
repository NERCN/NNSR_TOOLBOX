    function [ECG_result, MOVE_result, STM_result, ECG_info, MOVE_info, STM_info] = P01_detect_artifacts(~,IS_ECG, IS_MOVE, IS_STM)

        [n, m] = size(IS_ECG);

        ECG_result = zeros(n, 1); 
        MOVE_result = zeros(n, 1); 
        STM_result = zeros(n, 1);   
        ECG_info = cell(n, 1);     
        MOVE_info = cell(n, 1);    
        STM_info = cell(n, 1);     

        for i = 1:n
            ECG_result(i) = sum(IS_ECG(i, :) == 1) / m > 0.6;
        end

        for i = 1:n
            MOVE_result(i) = sum(IS_MOVE(i, :) == 1) > 2;
        end

        for i = 1:n
            STM_result(i) = sum(IS_STM(i, :) == 1) / m > 0.6;
        end

        for i = 1:n
            move_ratio = sum(IS_MOVE(i, :) == 1) / m;  

            if move_ratio > 0.3
                MOVE_info{i} = sprintf('通道%d存在大量体动伪迹 (体动占比 > 30%%)', i);
            else
                MOVE_info{i} = '';
            end

            if ECG_result(i) == 1
                ECG_info{i} = sprintf('通道%d检测到心电伪迹', i);
            else
                ECG_info{i} = sprintf('通道%d未检测到心电伪迹', i);
            end

            if STM_result(i) == 1
                STM_info{i} = sprintf('通道%d检测到STM伪迹', i);
            else
                STM_info{i} = sprintf('通道%d未检测到STM伪迹', i);
            end
        end
    end