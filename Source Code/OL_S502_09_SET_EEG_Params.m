    function buffer = OL_S502_09_SET_EEG_Params(~,electrode_contacts, advanced_params, special_mode, sampling_rate, collection_delay)

            if electrode_contacts < 0 || electrode_contacts > 255
                error('电极采集触点范围错误，应为0 ~ 255');
            end
            if advanced_params < 0 || advanced_params > 255
                error('高级采集参数设置范围错误，应为0 ~ 255');
            end
            if special_mode < 0 || special_mode > 255
                error('采集特殊模式设置范围错误，应为0 ~ 255');
            end
            if collection_delay < 3 || collection_delay > 150
                error('采集延时设置范围错误，应为3 ~ 150');
            end
        
            buffer = zeros(1, 21);
        
            buffer(1) = 0x09;
            buffer(2) = 21;
            buffer(3) = 0; 
            buffer(4) = electrode_contacts; 
            buffer(5) = advanced_params; 
            buffer(6) = special_mode; 
        
            buffer(7) = sampling_rate;
            buffer(8) = collection_delay;
    end