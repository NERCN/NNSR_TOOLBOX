    function [Isokay,mark,servertime,CRC] = OL_S502_02_Ping_Back(~,buffer)
    % 执行是否成功 0x81，成功 ; 0x82，指令编码错误 ; 0x83，指令参数错误 ; 0x84，指令执行超时
    
    try
    result = buffer(1);
    if dec2hex(result)=="81"
        % 成功
        Isokay = 1;
        mark = 'Ping：成功';
    elseif dec2hex(result)=="82"
        % 错误
        Isokay = 0;
        mark = 'Ping：指令编码错误';
    elseif dec2hex(result)=="83"
        % 错误
        Isokay = 0;
        mark = 'Ping：指令参数错误';
    elseif dec2hex(result)=="84"
        % 错误
        Isokay = 0;
        mark = 'Ping：指令执行超时';
    end

    % 服务端返回请求的时间 1(时)+1(分)+1(秒)+2(毫秒),用于校准通信双方的时间
    pingStartTime = buffer(4:8);
    % 提取时间信息
    hours = pingStartTime(1);     % 时
    minutes = pingStartTime(2);   % 分
    seconds = pingStartTime(3);   % 秒
    milliseconds = pingStartTime(4) * 256 + pingStartTime(5); 

    % 将时间转换为 MATLAB 的 datetime 对象
    timeString = sprintf('%02d:%02d:%02d.%03d', hours, minutes, seconds, milliseconds);
    servertime = datetime(timeString, 'InputFormat', 'HH:mm:ss.SSS');

    % CRC校验值
    cRC = uint16(buffer(9:10));

    % PongStartTime = pongStartTime;
    CRC = cRC;
    catch
        % 解析失败
        Isokay = 0;
        mark = 'Ping：连接失败';
        % pingStartTime = [];
        servertime = [];
        CRC = [];
    end
    end

    %  function [result] = OL_S502_03_GET_EEG_Prog(~)
    function [result] = OL_S502_03_GET_EEG_Prog(~)
        buffers = uint8(zeros(1,5,'uint8'));
        Length = uint8([5,0]); % Lenght 255
        buffers(1) = 0x3;
        buffers(2:3) = Length;
        % buffers(4:5) = CRC; % 保留
        % buffers(9:10) = CRC 保留
        result = buffers;
    end

    % function [result] = OL_S502_03_GET_EEG_Prog_Back(~,buffer)    
    function [result] = OL_S502_03_GET_EEG_Prog_Back(~,buffer)
        % 解析刺激器响应数据
        result = struct();
    
        define_channel_Un = {'C+1-','C+2-','C+3-','C+4-','C+5-','C+6-','C+7-','C+8-'};
        define_channel_bi = {'1+3-','2+4-','3+2-','4+1-','5+7-','6+8-','7+6-','8+5-'};
        define_channel_Un2 = {'8+1-','8+2-','8+3-','8+4-','8+5-','8+6-','8+7-','C+8-'};
        define_channel_C7 = {'7+6-','7+C-'};
        % define_channel_common = {'C+','8+'};
        % define_mode = {'双极模式 ','单极模式 '};
        define_acq_mode = {'固定频率 ','同步采集 ','任意频率采集 '};
        % define_switch = {'关闭 ','开启 '};
        define_freq_fixed = [250,500,1000,2000,4000,8000];
        
        try
            % 执行是否成功
            IsOk = buffer(1);
            switch IsOk
                case 0x81
                    IsOkMSG = '成功';
                case 0x82
                    IsOkMSG = '指令编码错误';
                case 0x83
                    IsOkMSG = '指令参数错误';
                case 0x84
                    IsOkMSG = '指令执行超时';
                otherwise
                    IsOkMSG = '未知错误';
            end
            % data_length = uint16(buffer(2)) * 256 + uint16(buffer(3));
            % 刺激器型号
            StimuModel = buffer(4);
    
            % 刺激状态
            StimulatorState = buffer(5);
            switch StimulatorState
                case 1
                    ISStimulatorON = 'DBS ON';
                case 0
                    ISStimulatorON = 'DBS OFF';
                otherwise
                    ISStimulatorON = '未知错误';
            end
    
            % 当前使能程序组编号
            programGroup = buffer(6); % 组别
    
            % 电极采集触点
            electrodeContacts = buffer(9);
            head_electrode = bitget(electrodeContacts,1:1:8);
    
            % 高级采集参数设置
            advancedParams = buffer(10);
            head_advanced = bitget(advancedParams,1:1:8);
    
            ACQ_mode = head_advanced(1); % 0双极 1单极
            ECG_disc = head_advanced(2); % 心电伪迹优化 0关闭 1打开
            if ECG_disc == 0
                ECG_INFO = '心电伪迹优化：关闭';
            elseif ECG_disc == 1
                ECG_INFO = '心电伪迹优化：打开';
            end
            % stim_elec_disc = head_advanced(3); % 保留
    
            charge = head_advanced(4); % 主动电荷平衡0关闭 1打开
            if charge == 0
                charge_Balan = '主动电荷平衡：关闭';
            elseif charge == 1
                charge_Balan = '主动电荷平衡：打开';
            end
    
            samplingRate = buffer(12);% 采样率
    
            acq_mode = bin2dec(reverse(strrep(num2str(head_advanced(5:6)),' ',''))); % 采集模式 00固定 01同步 10任意
            Frequency_mode = define_acq_mode{acq_mode+1};
            if acq_mode == 0 % 固定频率
               % ACQ_mode_info = '固定频率 ';
               Frequency = define_freq_fixed(samplingRate);
            else % 同步或任意频率
               % ACQ_mode_info = '同步采集 ';
               Frequency = '同步采集';
            end
            % Reserve1 = head_advanced(7); % 保留
            % Reserve2 = head_advanced(8); % 保留
    
            % 采集特殊模式设置
            specialMode = buffer(11);
            head_specialMode = bitget(specialMode,1:1:8);
            channel7_set = head_specialMode(1);
            channelPub_set = head_specialMode(2);
            % channel_others = head_specialMode(3:8);
            
            if ACQ_mode == 0 % 0 双极
                polor_info = "2";
                define_channel_bi{7} = define_channel_C7{channel7_set+1};
                channel_bin = define_channel_bi(head_electrode==1);
            elseif ACQ_mode == 1 % 0 双极
                polor_info = "1";
                if channelPub_set == 0
                   channel_bin = define_channel_Un(head_electrode==1);
                elseif channelPub_set == 1
                   channel_bin = define_channel_Un2(head_electrode==1);
                   polor_info = "3";
                end
            end
            
            % 采集延时设置
            collectionDelay = 10 * buffer(13);
    
            % 保留字段
            % result.reserved1 = buffer(12:15);
            % result.reserved2 = buffer(16:22);
            
            % 总结输出
            result.Is_OK = IsOk;
            result.Is_OK_Msg = IsOkMSG;
            result.Stimu_Model = StimuModel;
            result.IS_Stimulator_ON = ISStimulatorON;
            result.Program_Group = programGroup;
            result.Frequency = Frequency;
            result.Channel_Bin = channel_bin;
            result.Channel_Bin_ORI = head_electrode;
            result.Polor_Info = polor_info;
            result.ECG_INFO = ECG_INFO;
            result.Charge_Balan = charge_Balan;
            result.Collection_Delay = collectionDelay;
            % CRC 校验值
            result.crc = uint16(buffer(25)) * 256 + uint16(buffer(26));
            
        catch
            % 解析失败
            result.Is_OK = 0;
            result.Is_OK_Msg = '解析失败';
            result.Stimu_Model = [];
            result.IS_Stimulator_ON = [] ;
            result.Program_Group = [];
            result.Frequency = [];
            result.Channel_Bin = [];
            result.Polor_Info = [];
            result.ECG_INFO = [];
            result.Charge_Balan = [];
            result.Collection_Delay = [];
            result.crc = [];
        end
    end