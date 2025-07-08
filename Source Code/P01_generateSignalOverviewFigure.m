    function fileName = P01_generateSignalOverviewFigure(app,imgDir, dataMatrix, data_fs, bands, colors, imgSettings, TEXT, IS_MOVES)
        fileName = fullfile(imgDir, 'overview.png');
        
        % 创建总览图形 - 使用更大的尺寸
        fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
        set(fig, 'Color', 'white'); % 明确设置背景为白色
        
        % 使用subplot代替tiledlayout以确保更好的兼容性
        % 绘制每个通道的功率谱密度
        subplot(2, 1, 1);
        hold on;
        legendEntries = cell(1, size(dataMatrix, 1));
        
        % 检测Beta峰值（先放在这里检测, 后面会用到）
        
        del_mode = 1; % 1 = deletsegements； 2 = delete thereholds
        keep_mode = 2;%  1 = deleted ; 2 = set NaN;
        Data_out = P01_cut_artifact_segments(app, dataMatrix, data_fs,IS_MOVES, del_mode, keep_mode);

        for ch = 1:size(Data_out, 1)
            % 更新为使用75%重叠
            data_calcu = Data_out(ch ,:);
            [pxx, f] = pwelch(data_calcu(~isnan(data_calcu)), round(data_fs/2), round(data_fs*0.75/2), round(data_fs/2), data_fs);
            % 使用对数刻度以便更好地查看
            plot(f, abs(pxx), 'LineWidth', imgSettings.lineWidth, 'Color', colors.line(ch,:));
            legendEntries{ch} = [TEXT.channel, ' ', num2str(ch)];
        end
        
        % 限制频率范围在0.5 Hz到80 Hz之间
        xlim([0.5 80]);
        xlabel(TEXT.freq_hz, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylabel(TEXT.power_density, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        title(TEXT.psd_overview, 'FontSize', imgSettings.fontSizeTitle, 'FontWeight', 'bold');
        
        % 获取当前的 y 轴范围, 用于填充频率段
        y_limits = ylim;
        
        % 在图中标注频段
        fill([bands.delta(1) bands.delta(2) bands.delta(2) bands.delta(1)], ...
            [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], colors.delta, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
        fill([bands.theta(1) bands.theta(2) bands.theta(2) bands.theta(1)], ...
            [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], colors.theta, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
        fill([bands.alpha(1) bands.alpha(2) bands.alpha(2) bands.alpha(1)], ...
            [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], colors.alpha, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
        fill([bands.beta(1) bands.beta(2) bands.beta(2) bands.beta(1)], ...
            [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], colors.beta, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
        fill([bands.gamma(1) bands.gamma(2) bands.gamma(2) bands.gamma(1)], ...
            [y_limits(1) y_limits(1) y_limits(2) y_limits(2)], colors.gamma, 'FaceAlpha', 0.15, 'EdgeColor', 'none');
        
        % 添加频段标签
        text(mean(bands.delta), y_limits(2)-5, 'Delta', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.delta*0.7);
        text(mean(bands.theta), y_limits(2)-5, 'Theta', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.theta*0.7);
        text(mean(bands.alpha), y_limits(2)-5, 'Alpha', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.alpha*0.7);
        text(mean(bands.beta), y_limits(2)-5, 'Beta', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.beta*0.7);
        text(mean(bands.gamma), y_limits(2)-5, 'Gamma', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.gamma*0.7);
        
        % 添加通道图例
        legend(legendEntries, 'Location', 'northeast', 'FontSize', imgSettings.fontSizeText);
        grid on;
        box on;
        
        % 绘制每个通道的时域信号
        subplot(2, 1, 2);
        hold on;
        time = (0:size(dataMatrix, 2)-1) / data_fs; % 计算时间轴
        
        % 不进行归一化, 但控制y轴范围以避免异常值影响视图
        % 计算每个通道的合理振幅范围
        yMax = zeros(1, size(dataMatrix, 1));
        yMin = zeros(1, size(dataMatrix, 1));
        
        for ch = 1:size(dataMatrix, 1)
            % 获取每个通道的振幅统计, 去除极端异常值
            sorted_data = sort(dataMatrix(ch ,:));
            lower_cut = ceil(0.005 * length(sorted_data));
            upper_cut = floor(0.995 * length(sorted_data));
            yMin(ch) = sorted_data(max(1, lower_cut));
            yMax(ch) = sorted_data(min(length(sorted_data), upper_cut));
            
            % 绘制时域波形
            plot(time, dataMatrix(ch ,:), 'LineWidth', imgSettings.lineWidth, 'Color', colors.line(ch,:));
        end
        
        % 计算整体y轴范围, 确保异常值不会导致视图难以观察
        y_range = max(yMax) - min(yMin);
        y_center = (max(yMax) + min(yMin)) / 2;
        y_limit = [y_center - y_range*0.6, y_center + y_range*0.6];
        ylim(y_limit);
        
        % 美化坐标轴
        xlabel(TEXT.time_sec, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylabel('幅度', 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        title(TEXT.time_overview, 'FontSize', imgSettings.fontSizeTitle, 'FontWeight', 'bold');
        
        % 添加图例而不是直接在图上标注
        legend(legendEntries, 'Location', 'northeast', 'FontSize', imgSettings.fontSizeText);
        
        % 仅保留X轴网格
        grid on;
        box on;
        
        % 添加总体标题
        sgtitle(TEXT.overview, 'FontSize', imgSettings.fontSizeTitle+2, 'FontWeight', 'bold');
        
        % 确保图形渲染完成
        drawnow;
        
        % 使用最基本的保存方式
        saveas(fig, fileName);
        close(fig);
        
        % 打印信息以帮助调试
        fprintf('已保存信号总览图像至: %s\n', fileName);
    end