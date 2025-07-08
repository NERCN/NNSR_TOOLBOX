    function [fileName, betaPeakFreq, betaPeakValue, betaPeakWidth, deltaP, thetaP, alphaP, betaP, gammaP, betaPeakBandP] = P01_generateChannelAnalysisFigure(app,imgDir, ch, channelName, dataMatrix, data_fs, bands, colors, window_length, overlap, nfft, imgSettings, TEXT,IS_MOVES)
        % fprintf('处理通道 %d (%s) 图形...\n', ch, channelName);
        fileName = fullfile(imgDir, ['channel_', num2str(ch), '.png']);
        
        fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 800]);
        set(fig, 'Color', 'white'); % 明确设置背景为白色
        
        % 时域波形图 - 顶部
        subplot(3, 1, 1);
        time = (0:length(dataMatrix(ch ,:))-1) / data_fs; % 计算时间轴
        plot(time, dataMatrix(ch ,:), 'LineWidth', imgSettings.lineWidth, 'Color', [0.2, 0.5, 0.8]);
        title(sprintf('%s %s %s', TEXT.channel, channelName, TEXT.ch_time_domain), 'FontSize', imgSettings.fontSizeTitle, 'FontWeight', 'bold');
        xlabel(TEXT.time_sec, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylabel('幅度', 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        grid on;
        box on;

        subplot(3, 1, 2);
        [s, f, t, ps] = spectrogram(dataMatrix(ch ,:), window_length, overlap, nfft, data_fs, 'yaxis');
        ps_dB = 10 * log10(abs(ps));
        
        % 使用更好的颜色映射, 并确保是默认的jet颜色图
        imagesc(t, f, ps_dB);
        colormap(jet); % 使用jet颜色映射
        
        [pxx, f_psd] = pwelch(dataMatrix(ch ,:), round(data_fs/2), round(data_fs*0.75/2), round(data_fs/2), data_fs);
        [betaPeakFreq, betaPeakValue, betaPeakWidth] = P01_detectBetaPeak(app,f_psd, pxx);
        
        % 添加Beta峰值标记
        if betaPeakFreq > 0
            hold on;
            plot([t(1), t(end)], [betaPeakFreq, betaPeakFreq], 'r-', 'LineWidth', 1.5);
            text(t(end)*0.98, betaPeakFreq+1, [num2str(betaPeakFreq,'%.1f'), ' Hz'], 'Color', 'red', 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
            hold off;
        end

        set(gca, 'YDir', 'normal');
        
        % 美化坐标轴和标签
        axis tight;
        c = colorbar;
        c.Label.String = TEXT.power_db;
        c.Label.FontWeight = 'bold';
        caxis([max(ps_dB(:))-50, max(ps_dB(:))]); % 调整颜色范围以增强对比度
        title(sprintf('%s %s %s', TEXT.channel, channelName, TEXT.ch_time_freq), 'FontSize', imgSettings.fontSizeTitle, 'FontWeight', 'bold');
        xlabel(TEXT.time_sec, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylabel(TEXT.freq_hz, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylim([0 80]); % 限制频率显示范围为0-80Hz
        
        % 功率谱密度 (PSD) - 底部
        subplot(3, 1, 3);
        
        del_mode = 1; % 1 = deletsegements； 2 = delete thereholds
        keep_mode = 2;%  1 = deleted ; 2 = set NaN;
        Data_out = P01_cut_artifact_segments(app, dataMatrix, data_fs,IS_MOVES, del_mode, keep_mode);

        % 检测Beta峰值（先放在这里检测, 后面会用到）

        data_calcu = Data_out(ch ,:);
        [pxx, f] = pwelch(data_calcu(~isnan(data_calcu)), round(data_fs/2), round(data_fs*0.75/2), round(data_fs/2), data_fs);
        % 使用75%重叠的Welch方法
        % [pxx, f] = pwelch(Data_out(ch ,:), round(data_fs/2), round(data_fs*0.75/2), round(data_fs/2), data_fs);
        
        % 归一化处理, 基于4-45Hz的范围
        norm_range = (f >= 5 & f <= 45);
        pxx_norm = pxx / max(pxx(norm_range)); % 归一化为a.u.单位
        
        % 绘制PSD曲线
        plot(f, pxx_norm, 'LineWidth', imgSettings.lineWidth, 'Color', [0.2, 0.5, 0.8]);
        hold on;
        
        % 获取Y轴范围, 针对a.u.单位进行调整
        y_limits = [0,  betaPeakValue+0.25*betaPeakValue]; 
        ylim(y_limits);
        
        % 添加频段填充
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
        
        % 频段标签 - 改为横跨每个频段底部的标签以便更清晰显示
        text(mean(bands.delta), 0.05, 'Delta', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.delta*0.7);
        text(mean(bands.theta), 0.05, 'Theta', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.theta*0.7);
        text(mean(bands.alpha), 0.05, 'Alpha', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.alpha*0.7);
        text(mean(bands.beta), 0.05, 'Beta', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.beta*0.7);
        text(mean(bands.gamma), 0.05, 'Gamma', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', colors.gamma*0.7);
        
        % 定义Beta峰值频带 (±2Hz)
        betaPeakBand_lower = max(bands.beta(1), betaPeakFreq - 2);
        betaPeakBand_upper = min(bands.beta(2), betaPeakFreq + 2);
        
        % 查找最接近Beta峰值频率的索引
        [~, peakFreqIndex] = min(abs(f - betaPeakFreq));
        peakValue = pxx_norm(peakFreqIndex);
        
        % 标记Beta峰值
        plot(betaPeakFreq, peakValue, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
        text(betaPeakFreq, peakValue + 0.05, [num2str(betaPeakFreq, '%.1f'), ' Hz'], ...
            'Color', 'red', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        
        % 标记Beta峰值频带 (±2Hz)
        betaPeakBand_idx = (f >= betaPeakBand_lower & f <= betaPeakBand_upper);
        if any(betaPeakBand_idx)
            area(f(betaPeakBand_idx), pxx_norm(betaPeakBand_idx), 'FaceColor', 'r', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            text(mean([betaPeakBand_lower, betaPeakBand_upper]), 0.15, [TEXT.peak_band, ' ', num2str(betaPeakBand_lower, '%.1f'), '-', num2str(betaPeakBand_upper, '%.1f'), ' Hz'], ...
                'Color', 'red', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
        
        % 计算频段能量
        % 找到相应频率范围的索引
        deltaIdx = (f >= bands.delta(1) & f <= bands.delta(2));
        thetaIdx = (f >= bands.theta(1) & f <= bands.theta(2));
        alphaIdx = (f >= bands.alpha(1) & f <= bands.alpha(2));
        betaIdx = (f >= bands.beta(1) & f <= bands.beta(2));
        gammaIdx = (f >= bands.gamma(1) & f <= bands.gamma(2));
        totalIdx = (f >= 0.5 & f <= 80); % 总功率范围0.5-80Hz
        
        % 计算每个频段的能量
        deltaEnergy = sum(pxx(deltaIdx));
        thetaEnergy = sum(pxx(thetaIdx));
        alphaEnergy = sum(pxx(alphaIdx));
        betaEnergy = sum(pxx(betaIdx));
        gammaEnergy = sum(pxx(gammaIdx));
        totalEnergy = sum(pxx(totalIdx));
        
        % 计算百分比
        deltaP = (deltaEnergy / totalEnergy) * 100;
        thetaP = (thetaEnergy / totalEnergy) * 100;
        alphaP = (alphaEnergy / totalEnergy) * 100;
        betaP = (betaEnergy / totalEnergy) * 100;
        gammaP = (gammaEnergy / totalEnergy) * 100;
        
        % 计算Beta峰值频带的能量占比
        betaPeakBand_idx = (f >= betaPeakBand_lower & f <= betaPeakBand_upper);
        betaPeakBandEnergy = sum(pxx(betaPeakBand_idx));
        betaPeakBandP = (betaPeakBandEnergy / totalEnergy) * 100;
        
        title(sprintf('%s %s %s', TEXT.channel, channelName, TEXT.ch_psd), 'FontSize', imgSettings.fontSizeTitle, 'FontWeight', 'bold');
        xlabel(TEXT.freq_hz, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylabel(TEXT.norm_power, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        xlim([0.5 80]); % 限制在0.5到80Hz之间
        grid on;
        box on;
        
        % 添加总体标题
        sgtitle(sprintf('%s %s %s', TEXT.channel, channelName, TEXT.analysis), 'FontSize', imgSettings.fontSizeTitle+2, 'FontWeight', 'bold');
        
        % 确保图形渲染完成
        drawnow;
        
        % 使用最基本的保存方式
        saveas(fig, fileName);
        close(fig);
        
        % 打印信息以帮助调试
        fprintf('已保存通道 %d (%s) 的图像至: %s\n', ch, channelName, fileName);
    end
