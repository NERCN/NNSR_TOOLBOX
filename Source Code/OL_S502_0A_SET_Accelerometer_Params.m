    function buffer = OL_S502_0A_SET_Accelerometer_Params(~,sample_interval)

        if sample_interval < 1 || sample_interval > 255
            error('采样间隔范围错误，应为0x01 ~ 0xFF');
        end
    
        buffer = zeros(1, 7);
    
        buffer(1) = 0x0A;
        buffer(2) = 7;
        buffer(3) = 0;
        buffer(4) = 0;
        buffer(5) = sample_interval;
    end