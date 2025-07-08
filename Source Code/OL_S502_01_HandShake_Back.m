    function [Isokay,NamePlat,VersionPlat,DiscTime] = OL_S502_01_HandShake_Back(~,input_buffer)
    
        try
            if dec2hex(input_buffer(1))=="81"
                % 成功
                Isokay = 1;
            elseif dec2hex(input_buffer(1))=="82"
                % 指令编码错误
                Isokay = 2;
            elseif dec2hex(input_buffer(1))=="83"
                % 指令参数错误
                Isokay = 3;
            elseif dec2hex(input_buffer(1))=="84"
                % 指令超时
                Isokay = 4;
            else
                % 请重新停止采集
                Isokay = 5;
            end
            
            int8_names = input_buffer(5:84);
            nonZeroIndex = find(int8_names ~= 0, 1, 'last');
            NamePlat = char(int8_names(1:nonZeroIndex));
            int8_version = input_buffer(85:134);
            nonZeroIndex = find(int8_version ~= 0, 1, 'last');
            VersionPlat = char(int8_version(1:nonZeroIndex));
            DiscTime = input_buffer(135);
        catch
            Isokay = 0;
            NamePlat = [''];
            VersionPlat = ['识别失败，请重试'];
        end
    end