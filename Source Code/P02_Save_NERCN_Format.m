      function DBS_Data = P02_Save_NERCN_Format(app,DBS_Data_In, para, Starttime, Fs_LFP, Data_LFP, Processed_LFP, Channel_LFP, Fs_ACC, Data_ACC, Processed_ACC, Channel_ACC, Fs_C_EEG, Data_C_EEG, Processed_C_EEG, Channel_C_EEG, Savetime, appendMode)
                % Save_NERCN_Format - 保存或追加解析后的数据到标准格式的结构体中
                %
                % 功能：
                % 该函数用于将解析后的数据保存为特定格式的结构体(DBS_Data)，支持初始化数据或以追加模式存储。
                % 在追加模式下，支持检查新数据的 IPG 编号是否与已有数据一致，并根据用户选择进行处理。
                %
                % 输入参数：
                %   DBS_Data_In  - 已存在的 DBS_Data 结构体，若时设置为 0
                %   para         - 包含元信息的结构体，需包含以下字段：
                %                  * ori_dataname：原始文件名
                %                  * IPG_NUM：IPG 编号
                %   Starttime    - 数据的起始时间 (datetime)
                %   Fs_LFP       - LFP 数据采样频率
                %   Data_LFP     - LFP 原始数据
                %   Processed_LFP - LFP 处理后的数据
                %   Channel_LFP  - LFP 通道信息
                %   Fs_ACC       - 加速度计数据采样频率
                %   Data_ACC     - 加速度计原始数据
                %   Processed_ACC - 加速度计处理后的数据
                %   Channel_ACC  - 加速度计通道信息
                %   Fs_C_EEG     - EEG 数据采样频率
                %   Data_C_EEG   - EEG 原始数据
                %   Processed_C_EEG - EEG 处理后的数据
                %   Channel_C_EEG - EEG 通道信息
                %   Savetime     - 数据保存时间 (datetime)
                %   appendMode   - 是否以追加模式存储 (0 = 非追加模式，1 = 追加模式)
                %
                % 输出结果：
                %   DBS_Data - 存储解析后数据的结构体，包括以下字段：
                %              * Data_LFP：LFP 数据表格
                %              * Data_ACC：加速度计数据表格
                %              * Data_C_EEG：EEG 数据表格
                %              * INFO：元信息表格
                %              * AppendLog：追加记录表格，包含追加索引和保存时间
                %              * IPG_NUM：IPG 编号
                %              * Savetime：保存时间
                %
                % 注意事项：
                % 1. 如果 appendMode 为 1（追加模式），将检查新数据的 IPG_NUM 是否与已有数据一致。
                %    若不一致，将弹出对话框，用户可选择以下三种操作：
                %      a. 合并并覆盖：覆盖已有数据的 IPG_NUM，并继续追加。
                %      b. 不合并：取消追加模式，仅存储当前数据为新数据集。
                %      c. 退出：终止操作，不存储数据。
                % 2. 在初始化模式下 (appendMode = 0)，会清空已有数据并重新创建结构体。
                % 3. 追加模式下每种数据类型 (LFP, ACC, EEG) 的 Index 独立递增。
                if appendMode == 0
                        DBS_Data = struct();
                        DBS_Data.Data_LFP = table();
                        DBS_Data.Data_ACC = table();
                        DBS_Data.Data_C_EEG = table();
                        DBS_Data.INFO = table();
                        DBS_Data.AppendLog = table(); % 用于存储追加记录的索引和保存时间
                        DBS_Data.Savetime = []; % 初始化保存时间
                        DBS_Data.AppendMode = false; % 初始化为非追加模式
                        DBS_Data.IPG_NUM = para.IPG_NUM; % 初始化 IPG_NUM
                        currentIndex_LFP = 1; % 初始化 Data_LFP 索引
                        currentIndex_ACC = 1; % 初始化 Data_ACC 索引
                        currentIndex_EEG = 1; % 初始化 Data_C_EEG 索引
                        currentIndex_INFO = 1; % 初始化 INFO 索引
                else
                        DBS_Data = DBS_Data_In; % 使用已有数据结构
                        DBS_Data.AppendMode = appendMode; % 设置当前模式
            
                    % 检查 IPG_NUM 是否一致
                        if isfield(DBS_Data, 'IPG_NUM') && ~strcmp(DBS_Data.IPG_NUM, para.IPG_NUM)
                        % 弹出对话框，提示用户选择操作
                        choice = questdlg(...
                            sprintf('当前 IPG 编号 (%s) 与已有数据的 IPG 编号 (%s) 不一致，是否继续？', para.IPG_NUM, DBS_Data.IPG_NUM), ...
                            'IPG 编号冲突', ...
                            '合并并覆盖', '不合并', '退出', '合并并覆盖');
                        
                            switch choice
                            case '合并并覆盖'
                                DBS_Data.IPG_NUM = para.IPG_NUM; % 覆盖 IPG_NUM
                            case '不合并'
                                appendMode = 0; % 取消追加模式，重新初始化数据
                                DBS_Data = Save_NERCN_Format(0, para, Starttime, Fs_LFP, Data_LFP, Processed_LFP, Channel_LFP, ...
                                                             Fs_ACC, Data_ACC, Processed_ACC, Channel_ACC, ...
                                                             Fs_C_EEG, Data_C_EEG, Processed_C_EEG, Channel_C_EEG, Savetime, appendMode);
                                return; % 退出函数，存储当前数据
                            case '退出'
                                error('存储操作已取消。');
                            end
                         end
    
                    % 如果是追加模式，从每个表中获取当前最大索引值
                    try
                        currentIndex_LFP = max(cell2mat(DBS_Data.Data_LFP.Index)) + 1;
                    catch
                        currentIndex_LFP = 1;
                    end
            
                    try
                        currentIndex_ACC = max(cell2mat(DBS_Data.Data_ACC.Index)) + 1;
                    catch
                        currentIndex_ACC = 1; % 初始化索引
                    end
                    
                    try
                        currentIndex_EEG = max(cell2mat(DBS_Data.Data_C_EEG.Index)) + 1;
                    catch
                        currentIndex_EEG = 1; % 初始化索引
                    end
            
                    try
                        currentIndex_INFO = max(cell2mat(DBS_Data.INFO.Index)) + 1;
                    catch
                        currentIndex_INFO = 1; % 初始化索引
                    end
                end
                
                DBS_Data.IPG_NUM = para.IPG_NUM;
                
                % 更新保存时间
                DBS_Data.Savetime = Savetime;
            
                % 获取文件名
                OriginalFileName = P02_validateInput(app,para.ori_dataname, 'Unknown');
            
                % 添加 Data_LFP 数据
                newRowLFP = table(...
                    {currentIndex_LFP}, ... % 数据索引
                    {'Realtime acquisition'}, ... % 数据类型
                    {Starttime}, ... % 开始时间
                    {P02_validateInput(app,Fs_LFP, [])}, ... % 采样频率
                    {P02_validateInput(app,Channel_LFP, [])}, ... % 通道
                    {OriginalFileName}, ... % 原始文件名
                    {P02_validateInput(app,Data_LFP, [])}, ... % 原始数据
                    {P02_validateInput(app,Processed_LFP, [])}, ... % 处理后的数据
                    'VariableNames', {'Index', 'Type', 'StartTime', 'Fs', 'Channel', 'OriginalFileName', 'RawData', 'ProcessedData'} ...
                );
                DBS_Data.Data_LFP = [DBS_Data.Data_LFP; newRowLFP];
            
                % 添加 Data_ACC 数据
                newRowACC = table(...
                    {currentIndex_ACC}, ... % 数据索引
                    {'Realtime acquisition'}, ... % 数据类型
                    {Starttime}, ... % 开始时间
                    {P02_validateInput(app,Fs_ACC, 'No data')}, ... % 采样频率
                    {P02_validateInput(app,Channel_ACC, 'No data')}, ... % 通道
                    {OriginalFileName}, ... % 原始文件名
                    {P02_validateInput(app,Data_ACC, 'No data')}, ... % 原始数据
                    {P02_validateInput(app,Processed_ACC, 'No data')}, ... % 处理后的数据
                    'VariableNames', {'Index', 'Type', 'StartTime', 'Fs', 'Channel', 'OriginalFileName', 'RawData', 'ProcessedData'} ...
                );
                DBS_Data.Data_ACC = [DBS_Data.Data_ACC; newRowACC];
            
                % 添加 Data_C_EEG 数据
                newRowEEG = table(...
                    {currentIndex_EEG}, ... % 数据索引
                    {'Realtime acquisition'}, ... % 数据类型
                    {Starttime}, ... % 开始时间
                    {P02_validateInput(app,Fs_C_EEG, 'No data')}, ... % 采样频率
                    {P02_validateInput(app,Channel_C_EEG, 'No data')}, ... % 通道
                    {OriginalFileName}, ... % 原始文件名
                    {P02_validateInput(app,Data_C_EEG, 'No data')}, ... % 原始数据
                    {P02_validateInput(app,Processed_C_EEG, 'No data')}, ... % 处理后的数据
                    'VariableNames', {'Index', 'Type', 'StartTime', 'Fs', 'Channel', 'OriginalFileName', 'RawData', 'ProcessedData'} ...
                );
                DBS_Data.Data_C_EEG = [DBS_Data.Data_C_EEG; newRowEEG];
            
                % 添加 INFO 数据
                infoFields = {'Index','acq_info1', 'acq_info2', 'Stim_onoff_info', 'ori_dataname', 'save_type', 'IPG_NUM'};
                infoData = cell(1, numel(infoFields)); % 初始化数据为 cell
                for i = 1:numel(infoFields)
                    if isfield(para, infoFields{i})
                        % 确保每个字段的值为字符串数组
                        infoData{i} = P02_convertToString(app,para.(infoFields{i}));
                    else
                        infoData{i} = 'No data'; % 如果字段不存在，标记为 'No data'
                    end
                end
                newRowINFO = table(...
                    {currentIndex_INFO}, ... % 数据索引
                    infoData{:}, ... % 动态填充字段数据
                    'VariableNames', infoFields ... % 动态设置表头
                );
                DBS_Data.INFO = [DBS_Data.INFO; newRowINFO];
            
                % 如果是追加模式，记录保存时间和追加的索引到 AppendLog 表格
                if appendMode
                    newLogEntry = table(... % 存储追加记录
                        {currentIndex_LFP}, ... % 记录 LFP 的索引
                        {Savetime}, ... % 保存时间
                        'VariableNames', {'Index', 'Savetime'} ...
                    );
                    DBS_Data.AppendLog = [DBS_Data.AppendLog; newLogEntry];
                end
        end