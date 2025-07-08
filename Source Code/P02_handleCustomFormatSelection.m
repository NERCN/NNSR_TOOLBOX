      function P02_handleCustomFormatSelection(~,fileFormatDropDown, customFormatEditField)
            if strcmp(fileFormatDropDown.Value, '自定义')
                customFormatEditField.Visible = 'on';
            else
                customFormatEditField.Visible = 'off';
            end
        end