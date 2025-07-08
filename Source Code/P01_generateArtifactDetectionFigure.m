    function fileName = P01_generateArtifactDetectionFigure(~,imgDir, IS_ECG, IS_STM, IS_MOVE, imgSettings, TEXT)
        fprintf('生成伪迹识别结果图...\n');
        fileName = fullfile(imgDir, 'artifact_detection.png');
        
        % 创建伪迹识别结果图形
        fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 500]);
        set(fig, 'Color', 'white'); % 明确设置背景为白色
        
        % 定义颜色
        greenColor = [224, 236, 236]/255; % 浅绿色（全部为0时）
        yellowColor = [255, 243, 205]/255; % 黄色（IS_ECG 或 IS_STM为1, IS_MOVE为0）
        redColor = [255, 204, 204]/255; % 淡红色（存在IS_MOVE时）
        
        % 初始化图像矩阵
        [numChannels, numSegments] = size(IS_ECG);
        img = zeros(numChannels, numSegments, 3); % 每个像素点3个颜色通道 (RGB)
        
        % 遍历每个通道和每个片段, 根据分类结果设置图像的颜色
        for ch = 1:numChannels
            for seg = 1:numSegments
                if IS_MOVE(ch, seg) == 1
                    img(ch, seg, :) = redColor; % 如果存在MOVE, 使用淡红色
                elseif (IS_ECG(ch, seg) == 1 || IS_STM(ch, seg) == 1) && IS_MOVE(ch, seg) == 0
                    img(ch, seg, :) = yellowColor; % 如果IS_ECG或IS_STM为1, 且没有MOVE, 使用黄色
                elseif IS_ECG(ch, seg) == 0 && IS_STM(ch, seg) == 0 && IS_MOVE(ch, seg) == 0
                    img(ch, seg, :) = greenColor; % 如果三者都为0, 使用浅绿色
                end
            end
        end
        
        % 主要绘图区域（占据80%的宽度）
        subplot('Position', [0.05, 0.1, 0.8, 0.8]);
        imagesc(1:numSegments, 1:numChannels, reshape(img, numChannels, numSegments, 3));
        
        % 将Y轴方向翻转（使得第一个通道在顶部）
        set(gca, 'YDir', 'reverse');
        
        % 调整坐标轴刻度
        set(gca, 'YTick', 1:numChannels);
        set(gca, 'TickLength', [0 0]); % 使得坐标轴刻度不会突出影响视觉
        
        % 设置坐标轴标签和标题
        xlabel(TEXT.time_sec, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        ylabel(TEXT.channel, 'FontSize', imgSettings.fontSizeLabel, 'FontWeight', 'bold');
        
        % 设置纵横比, 扩大纵轴的比例
        ylim([0.5, numChannels+0.5]);
        xlim([0.5, numSegments+0.5]);
        
        % 添加网格线
        grid on;
        set(gca, 'GridColor', [0.7 0.7 0.7], 'GridAlpha', 0.3);
        
        % 添加图例（右侧, 占据20%的宽度）
        subplot('Position', [0.87, 0.3, 0.1, 0.4]);
        axis off;
        
        % 绘制图例色块和标签
        hold on;
        
        % 无伪迹图例
        rectangle('Position', [0, 3, 0.5, 0.5], 'FaceColor', greenColor, 'EdgeColor', 'k');
        text(0.25, 2.7, TEXT.no_artifact, 'FontSize', imgSettings.fontSizeText, 'HorizontalAlignment', 'center');
        
        % 心电/刺激伪迹图例
        rectangle('Position', [0, 2, 0.5, 0.5], 'FaceColor', yellowColor, 'EdgeColor', 'k');
        text(0.25, 1.7, TEXT.ecg_stim_artifact, 'FontSize', imgSettings.fontSizeText, 'HorizontalAlignment', 'center');
        
        % 运动伪迹图例
        rectangle('Position', [0, 1, 0.5, 0.5], 'FaceColor', redColor, 'EdgeColor', 'k');
        text(0.25, 0.7, TEXT.move_artifact, 'FontSize', imgSettings.fontSizeText, 'HorizontalAlignment', 'center');
        
        % 添加图例标题
        text(0, 4, TEXT.artifact_legend, 'FontWeight', 'bold', 'FontSize', imgSettings.fontSizeText);
        
        % 添加总体标题
        sgtitle(TEXT.artifact_title, 'FontSize', imgSettings.fontSizeTitle+2, 'FontWeight', 'bold');
        
        % 确保图形渲染完成
        drawnow;
        
        % 使用最基本的保存方式
        saveas(fig, fileName);
        close(fig);
        
        % 打印信息以帮助调试
        fprintf('已保存伪迹检测图像至: %s\n', fileName);
    end
