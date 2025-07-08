    function result = OL_S502_09_SET_EEG_Params_Back(~,buffer)

            result = struct();
        
            try
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
                result.Is_OK = IsOk;
                result.Is_OK_Msg = IsOkMSG;
        
                command_length = buffer(2) * 256 + buffer(3);
                result.Command_Length = command_length;
        
                crc = uint16(buffer(4)) * 256 + uint16(buffer(5));
                result.CRC = crc;
                
            catch
                result.Is_OK = 0;
                result.Is_OK_Msg = '解析失败';
            end
    end