      function value = P02_validateInput(~,inputValue, defaultValue)
            if nargin < 1 || isempty(inputValue)
                value = defaultValue;
            else
                value = inputValue;
            end
      end