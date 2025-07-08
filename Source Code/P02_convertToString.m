      function value = P02_convertToString(~,inputValue)
            if ischar(inputValue) % 如果是字符向量
                value = string(inputValue); % 转为字符串数组
            elseif isstring(inputValue) % 如果是字符串数组
                value = inputValue;
            else % 其他类型，转换为字符串
                value = string(inputValue);
            end
      end