%% 美敦力JSON到MAT转换脚本
% 简化版本，结构清晰便于调整
% 生成的.mat文件格式匹配特定系统的P02_F1b_load_mat函数
% 数据格式：[channels x samples]
clear; clc;

%% ===== 参数设置区域 (可根据需要调整) =====
input_json_file = 'File_example.json';  % 输入JSON文件名
output_folder = './output';              % 输出文件夹
save_separate_files = true;              % true=每个时间戳单独保存, false=合并保存

% 默认填充值设置
default_stim_info = 0;
default_stim_onoff = 0;
default_stim_electrode = 0;
default_stim_frequency = 0;

%% ===== 主处理流程 =====
fprintf('开始转换: %s\n', input_json_file);

% 1. 读取JSON文件
try
    fid = fopen(input_json_file, 'r');
    if fid == -1
        error('无法打开文件: %s', input_json_file);
    end
    raw = fread(fid, inf);
    fclose(fid);
    jsonStr = char(raw');
    jsonData = jsondecode(jsonStr);
    fprintf('✓ JSON文件读取成功\n');
catch ME
    error('读取JSON文件失败: %s', ME.message);
end

% 2. 检查数据结构
if ~isfield(jsonData, 'BrainSenseTimeDomain') || isempty(jsonData.BrainSenseTimeDomain)
    error('未找到BrainSenseTimeDomain数据');
end

senseData = jsonData.BrainSenseTimeDomain;
fprintf('✓ 找到 %d 条BrainSenseTimeDomain记录\n', length(senseData));

% 3. 按时间戳组织数据
timestamps = unique({senseData.FirstPacketDateTime});
fprintf('✓ 发现 %d 个唯一时间戳\n', length(timestamps));

% 4. 创建输出文件夹
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 5. 处理每个时间戳的数据
[~, base_name, ~] = fileparts(input_json_file);

for t = 1:length(timestamps)
    current_timestamp = timestamps{t};
    fprintf('\n处理时间戳 %d/%d: %s\n', t, length(timestamps), current_timestamp);
    
    % 筛选当前时间戳的数据
    mask = strcmp({senseData.FirstPacketDateTime}, current_timestamp);
    current_entries = senseData(mask);
    
    % 提取数据
    channels = {current_entries.Channel};
    sample_rates = [current_entries.SampleRateInHz];
    
    % 构建数据矩阵
    all_data = {};
    for i = 1:length(current_entries)
        all_data{i} = current_entries(i).TimeDomainData(:); % 确保为列向量
    end
    
    % 统一数据长度（取最短）
    data_lengths = cellfun(@length, all_data);
    min_length = min(data_lengths);
    
    % 组装数据矩阵 [channels x samples] - 匹配你的系统格式
    DATA_ori = zeros(length(all_data), min_length);
    for i = 1:length(all_data)
        DATA_ori(i, :) = all_data{i}(1:min_length)';
    end
    
    Data_Processed = DATA_ori; % 这里假设处理后数据与原始相同
    samplerate = sample_rates(1); % 假设所有通道采样率相同
    
    % 6. 构建保存数据结构
    data_saved_time = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    
    if length(channels) >= 2
        % 完整格式
        chi_info = {'DATA_ori','Data_Processed','samplerate','stim_info','acq_info',...
                   'Stim_onoff_info','stim_electrode_info','stim_frequency_info',...
                   'recoding_parameter_info','Record_Channel','ori_dataname',...
                   'processdate','save_type'};
        
        % 构建acq_info
        acq_info_struct = struct();
        acq_info_struct.channels = channels;
        acq_info_struct.samplerate = samplerate;
        acq_info_struct.timestamp = current_timestamp;
        acq_info_struct.data_length = min_length;
        
        % 构建recording parameter info (通道信息)
        rec_param_info = channels; % 直接使用通道名称列表，匹配你的系统
        
        data = {DATA_ori, Data_Processed, samplerate, default_stim_info, acq_info_struct,...
               default_stim_onoff, default_stim_electrode, default_stim_frequency,...
               rec_param_info, channels, base_name, data_saved_time, 'full'};
    else
        % 简化格式
        chi_info = {'DATA_ori','Data_Processed','samplerate','save_time','save_type'};
        data = {DATA_ori, Data_Processed, samplerate, data_saved_time, 'only_data'};
    end
    
    % 7. 保存文件 - 只保存data变量以匹配你的读取函数
    if save_separate_files
        % 每个时间戳单独保存
        timestamp_clean = regexprep(current_timestamp, '[: ]', '_');
        output_filename = sprintf('%s_timestamp_%d_%s.mat', base_name, t, timestamp_clean);
    else
        % 合并保存（这里仍然分别保存，可根据需要修改）
        output_filename = sprintf('%s_combined_data_%d.mat', base_name, t);
    end
    
    output_path = fullfile(output_folder, output_filename);
    save(output_path, 'data'); % 只保存data变量，匹配你的系统读取方式
    
    fprintf('✓ 已保存: %s\n', output_filename);
    fprintf('  - 通道数: %d\n', length(channels));
    fprintf('  - 采样率: %d Hz\n', samplerate);
    fprintf('  - 数据长度: %d samples\n', min_length);
    fprintf('  - 数据格式: [%d channels x %d samples]\n', length(channels), min_length);
    fprintf('  - 通道名称: %s\n', strjoin(channels, ', '));
end

%% ===== 完成信息 =====
fprintf('\n🎉 转换完成！\n');
fprintf('总共处理了 %d 个时间戳\n', length(timestamps));
fprintf('输出文件保存在: %s\n', output_folder);

% 显示输出文件列表
mat_files = dir(fullfile(output_folder, '*.mat'));
fprintf('\n生成的MAT文件:\n');
for i = 1:length(mat_files)
    fprintf('  %d. %s\n', i, mat_files(i).name);
end