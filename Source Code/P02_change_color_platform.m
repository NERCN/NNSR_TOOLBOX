      function P02_change_color_platform(app, INPUT)

            if INPUT == 1
                colorPrimary =  [0.93, 0.93, 0.96];   % 主背景色
                colorSecondary = [0.93, 0.93, 0.96];    % 次要背景色
                colorText = [0.13,0.13,0.13];                  % 文字颜色
                colorBorder = [0.75, 0.75, 0.78];       % 边框颜色
                colorTable = [1, 1, 1];                 % 表格颜色
                app.Image.UserData = 'E:\05_Platform\Verson_0.2.0\Electrode_ORI.jpg';
                app.Image.ImageSource = 'E:\05_Platform\Verson_0.2.0\Electrode_ORI.jpg';
                app.MainFigure.Color = [0.88,0.86,0.91];
                colorbacks = colorSecondary;
                colorbacks2 = [0.98,0.98,0.98];
                % text(app.axis_pre,0.1,0.5,'脑电数据离线分析系统','Color',[0.98,0.98,0.98],"BackgroundColor",[0.76,0.73,0.82],"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.axis_pre,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.axis_preprocessing_now,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",27,"FontSmoothing","on","FontWeight","bold")
                text(app.DATA_PSD,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",13,"FontSmoothing","on","FontWeight","bold")
                text(app.PSD_figure,0.12,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",22,"FontSmoothing","on","FontWeight","bold")
                text(app.Phase_feature,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.TIME_FREQUENCY,0.18,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",34,"FontSmoothing","on","FontWeight","bold")
                text(app.PLV_plot,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")

            elseif INPUT == 2
                colorPrimary = [1, 1, 1];
                colorSecondary = [0.98, 0.98, 0.98];
                colorText = [0.13,0.13,0.13];
                colorBorder = [0.85, 0.85, 0.85];
                colorTable = [1, 1, 1];
                app.Image.ImageSource = 'E:\05_Platform\Verson_0.2.0\Electrode_White.jpg';
                app.Image.UserData = 'E:\05_Platform\Verson_0.2.0\Electrode_White.jpg';
                app.MainFigure.Color = [0.85, 0.85, 0.85];
                colorbacks = colorSecondary;
                colorbacks2 = [0.38,0.38,0.38];
                % text(app.axis_pre,0.1,0.5,'脑电数据离线分析系统','Color',[0.98,0.98,0.98],"BackgroundColor",[0.76,0.73,0.82],"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.axis_pre,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.axis_preprocessing_now,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",27,"FontSmoothing","on","FontWeight","bold")
                text(app.DATA_PSD,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",13,"FontSmoothing","on","FontWeight","bold")
                text(app.PSD_figure,0.12,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",22,"FontSmoothing","on","FontWeight","bold")
                text(app.Phase_feature,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.TIME_FREQUENCY,0.18,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",34,"FontSmoothing","on","FontWeight","bold")
                text(app.PLV_plot,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")

            elseif INPUT == 3
                colorPrimary = [0.4, 0.4, 0.4];
                colorSecondary = [0.5, 0.5, 0.5];
                colorText = [1, 1, 1];
                colorBorder = [0.6, 0.6, 0.6];
                colorTable = [0.85, 0.85, 0.85];
                app.MainFigure.Color = [0.4, 0.4, 0.4];
                colorbacks = colorSecondary;
                colorbacks2 = [0.98,0.98,0.98];
                app.Image.UserData = 'E:\05_Platform\Verson_0.2.0\Electrode_White.jpg';
                app.Image.ImageSource = 'E:\05_Platform\Verson_0.2.0\Electrode_White.jpg';
                % text(app.axis_pre,0.1,0.5,'脑电数据离线分析系统','Color',[0.98,0.98,0.98],"BackgroundColor",[0.76,0.73,0.82],"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.axis_pre,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.axis_preprocessing_now,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",27,"FontSmoothing","on","FontWeight","bold")
                text(app.DATA_PSD,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",13,"FontSmoothing","on","FontWeight","bold")
                text(app.PSD_figure,0.12,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",22,"FontSmoothing","on","FontWeight","bold")
                text(app.Phase_feature,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")
                text(app.TIME_FREQUENCY,0.18,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",34,"FontSmoothing","on","FontWeight","bold")
                text(app.PLV_plot,0.1,0.5,'脑电数据离线分析系统','Color',colorbacks2,"BackgroundColor",colorbacks,"FontSize",18,"FontSmoothing","on","FontWeight","bold")

            end
            % redraw(app.Image)
            % 获取所有UI组件
            allComponents = findall(app.MainFigure);
            
            % 遍历所有轴对象并设置颜色
            axesComponents = findobj(allComponents, 'Type', 'axes');
            for i = 1:length(axesComponents)
                ax = axesComponents(i);
                ax.Color = colorPrimary;
                if isprop(ax, 'XColor')
                    ax.XColor = colorText;
                end
                if isprop(ax, 'YColor')
                    ax.YColor = colorText;
                end
                if isprop(ax, 'GridColor')
                    ax.GridColor = colorBorder;
                end
            end
            
            % 设置表格颜色
            tables = findobj(allComponents, 'Type', 'uitable');
            for i = 1:length(tables)
                table = tables(i);
                table.BackgroundColor = colorTable;
                table.ForegroundColor = colorText;
            end

            % 遍历所有组件并设置颜色
            for i = 1:length(allComponents)
                comp = allComponents(i);
        
                % 通用颜色属性设置
                if isprop(comp, 'BackgroundColor')
                    comp.BackgroundColor = colorSecondary;
                end
                if isprop(comp, 'FontColor')
                    comp.FontColor = colorText;
                end
                if isprop(comp, 'ForegroundColor')
                    comp.ForegroundColor = colorText;
                end
                if isprop(comp, 'HighlightColor')
                    comp.HighlightColor = colorBorder;
                end
                if isprop(comp, 'BorderColor')
                    comp.BorderColor = colorBorder;
                end
                if isprop(comp, 'GridColor')
                    comp.GridColor = colorBorder;
                end
                
                % 设置选项卡标题颜色为黑色
                if isa(comp, 'matlab.ui.container.TabGroup')
                    tabs = findall(comp, 'Type', 'matlab.ui.container.Tab');
                    for j = 1:length(tabs)
                        tab = tabs(j);
                        if isprop(tab, 'Title')
                            tab.Title.FontColor = colorText;  % 设置Tab标题的字体颜色为黑色
                        end
                    end
                end
                
                % 设置菜单项字体颜色为黑色
                if isa(comp, 'matlab.ui.container.Menu')
                    comp.ForegroundColor = [0,0,0];  % 设置菜单项字体颜色为黑色
                end
            end
            
            if INPUT == 1 || INPUT == 2
                colornowss = [0.81,0.88,0.85];
                app.More_info.BackgroundColor = colornowss;
                app.Batch_Procecces.BackgroundColor = colornowss;
                app.Comparation_TOOL_2.BackgroundColor = colornowss;
                app.data_cut_tool.BackgroundColor = colornowss;
                app.comfirm_detrend2.BackgroundColor = colornowss;
                app.STMartifactremove_confirm.BackgroundColor = colornowss;
                app.confirm_EAS.BackgroundColor = colornowss;
                app.Data_re_finish.BackgroundColor = [0.78,0.90,0.91];
                app.PreProcess_Tool.ForegroundColor = [0.13,0.13,0.13];
                app.FeatureProcess_Tool.ForegroundColor = [0.13,0.13,0.13];
                app.PSD_analisis.ForegroundColor = [0.13,0.13,0.13];
                app.Phase_Value_analisis.ForegroundColor = [0.13,0.13,0.13];
                app.Tab_for_detrend.ForegroundColor = [0.13,0.13,0.13];
                app.Tab_for_stim_artifacts.ForegroundColor = [0.13,0.13,0.13];
                app.Tab_for_ECG_artifacts.ForegroundColor = [0.13,0.13,0.13];
                app.current_IPGfile.BackgroundColor = [0.83,0.92,0.98];
            elseif INPUT == 3
                colornowss = [0.41,0.48,0.45];
                app.More_info.BackgroundColor = colornowss;
                app.Batch_Procecces.BackgroundColor = colornowss;
                app.Comparation_TOOL_2.BackgroundColor = colornowss;
                app.data_cut_tool.BackgroundColor = colornowss;
                app.comfirm_detrend2.BackgroundColor = colornowss;
                app.STMartifactremove_confirm.BackgroundColor = colornowss;
                app.confirm_EAS.BackgroundColor = colornowss;
                app.Data_re_finish.BackgroundColor = [0.48,0.50,0.51];
                app.PreProcess_Tool.ForegroundColor = [0.13,0.13,0.13];
                app.FeatureProcess_Tool.ForegroundColor = [0.13,0.13,0.13];
                app.PSD_analisis.ForegroundColor = [0.13,0.13,0.13];
                app.Phase_Value_analisis.ForegroundColor = [0.13,0.13,0.13];
                app.Tab_for_detrend.ForegroundColor = [0.13,0.13,0.13];
                app.Tab_for_stim_artifacts.ForegroundColor = [0.13,0.13,0.13];
                app.Tab_for_ECG_artifacts.ForegroundColor = [0.13,0.13,0.13];
                app.IS_OLD_VERSON.FontColor = [0.13,0.13,0.13];
                app.InseartNAN.FontColor = [0.13,0.13,0.13];
            end
            app.NNSRLabel.BackgroundColor = 'none';
        end
    