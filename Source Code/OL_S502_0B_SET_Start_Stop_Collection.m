    function buffer = OL_S502_0B_SET_Start_Stop_Collection(~,start_stop, sample_options, sample_type, sample_duration)

        if start_stop ~= 0 && start_stop ~= 1
            error('开始/停止标识范围错误，应为0或1');
        end
        if sample_options < 0 || sample_options > 255
            error('采样选项范围错误，应为0 ~ 255');
        end
        if sample_type ~= 1
            error('采样类型范围错误，应为1');
        end

        buffer = zeros(1, 9);

        buffer(1) = uint8(0x0B);
        buffer(2) = uint8(9);
        buffer(3) = 0;
        
        buffer(4) = start_stop;
    
        if sample_options == 0
           accel_collect = '0';
           eeg_collect = '0';
        elseif sample_options == 1
           accel_collect = '0';
           eeg_collect = '1';
        elseif sample_options == 2
           accel_collect = '1';
           eeg_collect = '0';
        elseif sample_options == 3
           accel_collect = '1';
           eeg_collect = '1';
        end

        hexNumber = '00';

        decimalNumber = hex2dec(hexNumber);

        binaryString = dec2bin(decimalNumber, 8);

        binaryString(end) = eeg_collect;
        binaryString(end-2) = accel_collect;
        modifiedDecimalNumber = bin2dec(binaryString);
        buffer(5) = dec2hex(modifiedDecimalNumber);
    
        buffer(6) = sample_type; 
        buffer(7) = sample_duration;
    end