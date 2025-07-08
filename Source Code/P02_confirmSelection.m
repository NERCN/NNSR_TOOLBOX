      function P02_confirmSelection(app,confirmDlg, source_folder, target_folder, fileFormatDropDown, customFormatEditField)
            % 获取最终的文件格式
            app.waitting_now = uiprogressdlg(app.MainFigure,'Title','请选择检索文件夹与目标文件夹',...
            'Indeterminate','on');
            drawnow
            
            if strcmp(fileFormatDropDown.Value, '自定义')
                file_format = customFormatEditField.Value;
            else
                file_format = fileFormatDropDown.Value;
            end
        
            % 关闭确认对话框
            close(confirmDlg);
        
            % 调用文件复制函数，并返回复制的文件数量
            file_count = P02_collect_files(app,source_folder, target_folder, file_format);
        
            % 显示复制完成和文件数量的消息
            msgbox(['复制完成！共复制了 ', num2str(file_count), ' 个文件。'], '复制结果');

            close(app.waitting_now)
        end
