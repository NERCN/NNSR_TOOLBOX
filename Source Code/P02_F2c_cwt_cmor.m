function coefs = P02_F2c_cwt_cmor(~,z,Fb,Fc,f,fs)
    z = z(:)'; % 强行变成行向量,避免前面出错
    L = length(z);
    
    %2 计算尺度
    scal = fs*Fc./f;
    
    %3 计算小波
    shuaijian = 0.001; % 取小波衰减长度为0.1%
    tlow2low = sqrt(Fb*log(1/shuaijian)); % 单边cmor衰减至0.1%时的时间长度
    
    %3 小波的积分函数
    iter = 10; % 小波函数的区间划分精度
    xWAV = linspace(-tlow2low, tlow2low, 2^iter);
    stepWAV = xWAV(2) - xWAV(1);
    
    % 替代cmorwavf函数 - 生成复Morlet小波
    cmor_wav = cmorwavf_replacement(-tlow2low, tlow2low, 2^iter, Fb, Fc);
    val_WAV = cumsum(cmor_wav) * stepWAV;
    
    % 卷积前准备
    xWAV = xWAV - xWAV(1);
    xMaxWAV = xWAV(end);
    coefs = zeros(length(scal), L); % 预初设coefs
    
    %4 小波与信号的卷积
    for k = 1:length(scal)
        % 一个scal一行
        a_SIG = scal(k); % a是这一行的尺度函数
        j = 1 + floor((0:a_SIG*xMaxWAV)/(a_SIG*stepWAV));
        if length(j) == 1
            j = [1 1];
        end
        waveinscal = fliplr(val_WAV(j)); % 把积分值扩展到j区间,然后左右颠倒
        
        %5 最重要的一步 - 使用替代的wkeep1函数
        conv_result = conv2(z, waveinscal, 'full');
        diff_result = diff(conv_result);
        coefs(k,:) = -sqrt(a_SIG) * wkeep1_replacement(diff_result, L);
    end

    % ===== 嵌套函数：替代cmorwavf =====
    function wav = cmorwavf_replacement(lb, ub, n, Fb, Fc)
        % 替代cmorwavf函数 - 生成复Morlet小波
        % 输入参数:
        %   lb, ub: 时间范围的下界和上界
        %   n: 采样点数
        %   Fb: 带宽参数
        %   Fc: 中心频率参数
        % 输出:
        %   wav: 复Morlet小波值
        
        % 生成时间向量
        t = linspace(lb, ub, n);
        
        % 复Morlet小波的数学表达式:
        % ψ(t) = (1/√(πFb)) * exp(2πiFct) * exp(-t²/Fb)
        
        % 计算复Morlet小波
        wav = (1/sqrt(pi*Fb)) * exp(2*pi*1i*Fc*t) .* exp(-t.^2/Fb);
    end

    % ===== 嵌套函数：替代wkeep1 =====
    function y = wkeep1_replacement(x, n)
        % 替代wkeep1函数 - 保留1D信号的中间n个元素
        % 输入参数:
        %   x: 输入向量
        %   n: 要保留的元素个数
        % 输出:
        %   y: 保留的中间n个元素
        
        x = x(:)'; % 确保是行向量
        lx = length(x);
        
        if n >= lx
            y = x;
            return;
        end
        
        % 计算起始和结束索引，保留中间部分
        first = floor((lx - n)/2) + 1;
        last = first + n - 1;
        
        y = x(first:last);
    end

end


% function coefs = P02_F2c_cwt_cmor(~,z,Fb,Fc,f,fs)
%         %1 小波的归一信号准备
%         z=z(:)';%强行变成y向量，避免前面出错
%         L=length(z);
%         %2 计算尺度
%         scal=fs*Fc./f;
% 
%         %3计算小波
%         shuaijian=0.001;%取小波衰减长度为0.1%
%         tlow2low=sqrt(Fb*log(1/shuaijian));%单边cmor衰减至0.1%时的时间长度，参照cmor的表达式
% 
%         %3小波的积分函数
%         iter=10;%小波函数的区间划分精度
%         xWAV=linspace(-tlow2low,tlow2low,2^iter);
%         stepWAV = xWAV(2)-xWAV(1);
%         val_WAV=cumsum(cmorwavf(-tlow2low,tlow2low,2^iter,Fb,Fc))*stepWAV;
%         %卷积前准备
%         xWAV = xWAV-xWAV(1);
%         xMaxWAV = xWAV(end);
%         coefs     = zeros(length(scal),L);%预初设coefs
% 
%         %4小波与信号的卷积
%         for k = 1:length(scal)    %一个scal一行
%             a_SIG = scal(k); %a是这一行的尺度函数
% 
%            j = 1+floor((0:a_SIG*xMaxWAV)/(a_SIG*stepWAV));
%                %j的最大值为是确定的，尺度越大，划分的越密。相当于把一个小波拉伸的越长。
%            if length(j)==1 , j = [1 1]; end
% 
%             waveinscal = fliplr(val_WAV(j));%把积分值扩展到j区间，然后左右颠倒。f为当下尺度的积分小波函数
% 
%             %5 最重要的一步 wkeep1取diff(wconv1(ySIG,f))里长度为lenSIG的中间一段
%             %conv(ySIG,f)卷积。
%            coefs(k,:) = -sqrt(a_SIG)*wkeep1(diff(conv2(z,waveinscal, 'full')),L);
%            %
%         end
% end
