    function fileName = P01_generateSummaryChartFigure(~,imgDir, allDeltaP, allThetaP, allAlphaP, allBetaP, allGammaP, channel_montage, bandNames, colors, imgSettings, TEXT)
        fileName = fullfile(imgDir, 'summary_chart.png');
        
        % 创建频谱总结图形
        fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
        set(fig, 'Color', 'white'); % 明确设置背景为白色
        
        num_channels = length(allDeltaP);
        x = 1:5; % 五个频段
        
        % 绘制每个通道的频段能量
        hold on;
        legendEntries = cell(1, num_channels);
        
        for ch = 1:num_channels
            % 获取该通道的所有频段能量
            channelData = [allDeltaP(ch), allThetaP(ch), allAlphaP(ch), allBetaP(ch), allGammaP(ch)];
            
            % 绘制线条
            plot(x, channelData, 'o-', 'LineWidth', 1.5, 'Color', colors.line(ch,:), 'MarkerFaceColor', colors.line(ch,:));
            
            % 保存图例项
            legendEntries{ch} = [TEXT.channel, ' ', channel_montage{ch}];
        end
        
        % 美化图形
        set(gca, 'XTick', 1:5, 'XTickLabel', bandNames);
        ylabel(TEXT.avg_energy, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        title(TEXT.band_energy_dist, 'FontSize', imgSettings.fontSizeTitle, 'FontWeight', 'bold');
        grid on;
        box on;
        
        % 添加图例
        legend(legendEntries, 'Location', 'northeast', 'FontSize', imgSettings.fontSizeText);
        
        % 确保图形渲染完成
        drawnow;
        
        % 使用最基本的保存方式
        saveas(fig, fileName);
        close(fig);
        
        % 打印信息以帮助调试
        fprintf('已保存频段分布图像至: %s\n', fileName);
    end