    function [result] = OL_S502_02_Ping(~)
        buffers = uint8(zeros(1,10,'uint8'));
        % buffer = uint8(zeros(1,255,'uint8'));
        Length = uint8([10,0]); % Lenght 255
        % 客户端发起请求的时间 1(时)+1(分)+1(秒)+2(毫秒),用于校准通信双方的时间
        currentTimes = datestr(now,'mmmm dd,yyyy HH:MM:SS.FFF');
        first_1 = hour(currentTimes);
        first_2 = min(currentTimes);
        first_3 = second(currentTimes);
        first_mid = currentTimes(end-2:end);
        first_4 = str2double(first_mid(1));
        first_5 = str2double(first_mid(2:3));
        PingStartTime = [uint8(first_1),uint8(first_2),uint8(first_3),uint8(first_4),uint8(first_5)];
        buffers(1) = 0x2;
        buffers(2:3) = Length;
        buffers(4:8) = PingStartTime;
        % buffers(9:10) = CRC 保留
        result = buffers;
    end