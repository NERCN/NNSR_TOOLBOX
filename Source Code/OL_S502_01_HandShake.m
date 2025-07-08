    function result = OL_S502_01_HandShake(~,clientName,clientVersion,Isconnect)
        buffer = uint8(zeros(1,256,'uint8'));
        Length = uint8([0,1]); % Lenght 255
        % clientName = 'NERCN Online Toolbox';
        utf8Name_clientName = uint8(clientName); % replace 4-24 bit
        names_UINT8 = uint8(zeros(1,80,'uint8'));
        names_UINT8(1:length(utf8Name_clientName)) = utf8Name_clientName;
        % clientVersion = 'V0.1.5';
        utf8Name_clientVersion = uint8(clientVersion); % replace 4-24 bit
        versons_UINT8 = uint8(zeros(1,50,'uint8'));
        versons_UINT8(1:length(utf8Name_clientVersion)) = utf8Name_clientVersion;
        
        buffer(1) = 0x01;           % 01 Para
        buffer(2:3) = Length;       % Length
        buffer(4:83) = names_UINT8; 
        buffer(84:133) = versons_UINT8;
        buffer(134) = Isconnect;
        % buffer(134:253) = Res; % 保留
        % buffer(254:255) = CRC; % CRC校验
        result = buffer;
    end