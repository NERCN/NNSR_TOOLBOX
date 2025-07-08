      function file_count = P02_collect_files(~,source_folder, target_folder, file_format)

            if ~exist(target_folder, 'dir')
                mkdir(target_folder);
            end
        

            file_list = dir(fullfile(source_folder, '**', '*.*')); % 仅获取下一级文件
        

            file_count = 0;

            for i = 1:length(file_list)
                if ~file_list(i).isdir
                    [~, ~, ext] = fileparts(file_list(i).name);
   
                    if strcmpi(ext, file_format)
                        % 源文件的完整路径
                        source_file = fullfile(file_list(i).folder, file_list(i).name);
        
                        % 目标文件的完整路径
                        target_file = fullfile(target_folder, file_list(i).name);
        
                        % 复制文件到目标文件夹
                        copyfile(source_file, target_file);
                        % 每次复制成功，计数器加1
                        file_count = file_count + 1;
                    end
                end
            end
            if file_count == 0
                % disp('未找到符合格式的文件。');
            else
                % disp(['所有文件已复制完成！共复制了 ', num2str(file_count), ' 个文件。']);
            end
        end