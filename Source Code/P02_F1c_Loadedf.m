      function varargout = P02_F1c_Loadedf(~,varargin)
        % %------------------------------------------------------------ Process input
        % assignin("base","varargin",varargin)
        
        % Opertion Flags
        RETURN_PHYSICAL_VALUES = 1;
        
        % Defaults for optional parameters
        signalLabels = {};      % Labels of signals to return
        epochs = [];            % Start and end epoch to return
        nargout = 3;
        
        % Process input 
        if nargin == 1
           edfFN = varargin{2};
           signalLabels = {};
        elseif nargin == 2 & nargout == 3 
           edfFN = varargin{2};
%            signalLabels = varargin{3};
        elseif nargin == 3 & nargout == 4 
           edfFN = varargin{2};
%            signalLabels = varargin{3};  
%            epochs = varargin{4};
        else
            % Echo supported function prototypes to console
            fprintf('header = blockEdfLoad(edfFN)\n');
            fprintf('[header, signalHeader] = blockEdfLoad(edfFN)\n');
            fprintf('[header, signalHeader, signalCell] = blockEdfLoad(edfFN)\n');
            fprintf('[header, signalHeader, signalCell] = blockEdfLoad(edfFN, signalLabels)\n');
            fprintf('[header, signalHeader, signalCell] = blockEdfLoad(edfFN, signalLabels, epochs)\n');
            
            % Call MATLAB error function
            error('Function prototype not valid');
        end
        % assignin("base","edfFN",edfFN)
        %-------------------------------------------------------------- Input check
        % Check that first argument is a string

        if   ~ischar(edfFN)
            msg = ('First argument is not a string.');
            error(msg);
        end
        % Check that first argument is a string
        if  ~iscellstr(signalLabels)
            msg = ('Second argument is not a valid text string.');
            error(msg);
        end
        % Check that first argument is a string
        if  and(nargin ==3, length(epochs)~=2)
            msg = ('Specify epochs = [Start_Epoch End_Epoch.');
            error(msg);
        end
        
        %---------------------------------------------------  Load File Information
        % Load edf header to memory
        [fid, msg] = fopen(edfFN);
        
        % Proceed if file is valid
        if fid <0
            % file id is not valid
            error(msg);    
        end
        
        
        % Open file for reading
        % Load file information not used in this version but will be used in
        % class version
        [filename, permission, machineformat, encoding] = fopen(fid);
        
        %-------------------------------------------------------------- Load Header
        try
            % Load header information in one call
            edfHeaderSize = 256;
            [A count] = fread(fid, edfHeaderSize);
        catch exception
            msg = 'File load error. Check available memory.';
            error(msg);
        end
        
        %----------------------------------------------------- Process Header Block
        % Create array/cells to create struct with loop
        headerVariables = {...
            'edf_ver';            'patient_id';         'local_rec_id'; ...
            'recording_startdate';'recording_starttime';'num_header_bytes'; ...
            'reserve_1';          'num_data_records';   'data_record_duration';...
            'num_signals'};
        headerVariablesConF = {...
            @strtrim;   @strtrim;   @strtrim; ...
            @strtrim;   @strtrim;   @str2num; ...
            @strtrim;   @str2num;   @str2num;...
            @str2num};
        headerVariableSize = [ 8; 80; 80; 8; 8; 8; 44; 8; 8; 4];
        headerVarLoc = vertcat([0],cumsum(headerVariableSize));
        headerSize = sum(headerVariableSize);
        
        % Create Header Structure
        header = struct();
        for h = 1:length(headerVariables)
            conF = headerVariablesConF{h};
            value = conF(char((A(headerVarLoc(h)+1:headerVarLoc(h+1)))'));
            header = setfield(header, headerVariables{h}, value);
        end
        
        % End Header Load section
        
        %------------------------------------------------------- Load Signal Header
                nargout = 3;
        if nargout >= 2
            try 
                % Load signal header into memory in one load
                edfSignalHeaderSize = header.num_header_bytes - headerSize;
                [A count] = fread(fid, edfSignalHeaderSize);
            catch exception
                msg = 'File load error. Check available memory.';
                error(msg);
            end
        
            %------------------------------------------ Process Signal Header Block
            % Create arrau/cells to create struct with loop
            signalHeaderVar = {...
                'signal_labels'; 'tranducer_type'; 'physical_dimension'; ...
                'physical_min'; 'physical_max'; 'digital_min'; ...
                'digital_max'; 'prefiltering'; 'samples_in_record'; ...
                'reserve_2' };
            signalHeaderVarConvF = {...
                @strtrim; @strtrim; @strtrim; ... 
                @str2num; @str2num; @str2num; ...
                @str2num; @strtrim; @str2num; ...
                @strtrim };
            num_signal_header_vars = length(signalHeaderVar);
            num_signals = header.num_signals;
            signalHeaderVarSize = [16; 80; 8; 8; 8; 8; 8; 80; 8; 32];
            signalHeaderBlockSize = sum(signalHeaderVarSize)*num_signals;
            signalHeaderVarLoc = vertcat([0],cumsum(signalHeaderVarSize*num_signals));
            signalHeaderRecordSize = sum(signalHeaderVarSize);
        
            % Create Signal Header Struct
            signalHeader = struct(...
                'signal_labels', {},'tranducer_type', {},'physical_dimension', {}, ...
                'physical_min', {},'physical_max', {},'digital_min', {},...
                'digital_max', {},'prefiltering', {},'samples_in_record', {},...
                'reserve_2', {});
        
            % Get each signal header varaible
            for v = 1:num_signal_header_vars
                varBlock = A(signalHeaderVarLoc(v)+1:signalHeaderVarLoc(v+1))';
                varSize = signalHeaderVarSize(v);
                conF = signalHeaderVarConvF{v};
                for s = 1:num_signals
                    varStart = varSize*(s-1)+1;
                    varEnd = varSize*s;
                    value = conF(char(varBlock(varStart:varEnd)));
        
                    structCmd = ...
                        sprintf('signalHeader(%.0f).%s = value;',s, signalHeaderVar{v});
                    eval(structCmd);
                end
            end
        end % End Signal Load Section
        
        %-------------------------------------------------------- Load Signal Block
                nargout = 3;
        if nargout >=3
            % Read digital values to the end of the file
            try
                % Set default error mesage
                errMsg = 'File load error. Check available memory.';
                
                % Load strategy is dependent on input
                if nargin == 1
                    % Load entire file
                    [A count] = fread(fid, 'int16');
                else 
                    % Get signal label information
                    edfSignalLabels = arrayfun(...
                        @(x)signalHeader(x).signal_labels, [1:header.num_signals],...
                            'UniformOutput', false);
                    signalIndexes = arrayfun(...
                        @(x)find(strcmp(x,edfSignalLabels)), signalLabels,...
                            'UniformOutput', false);
                    
                    % Check that specified signals are present
                    signalIndexesCheck = cellfun(...
                        @(x)~isempty(x), signalIndexes, 'UniformOutput', false);
                    signalIndexesCheck = int16(cell2mat(signalIndexesCheck));
                    if sum(signalIndexesCheck) == length(signalIndexes)
                        % Indices are specified
                        signalIndexes = cell2mat(signalIndexes);
                    else
                        % Couldn't find at least one signal label
                        errMsg = 'Could not identify signal label';
                        error(errMsg);
                    end
                        
                    edfSignalSizes = arrayfun(...
                        @(x)signalHeader(x).samples_in_record, [1:header.num_signals]);
                    edfRecordSize = sum(edfSignalSizes);
                    
                    % Identify memory locations to record
                    endLocs = cumsum(edfSignalSizes)';
                    startLocs = [1;endLocs(1:end-1)+1];
                    signalLocs = [];
                    for s = signalIndexes
                        signalLocs = [signalLocs; [startLocs(s):1:endLocs(s)]'];
                    end
                    sizeSignalLocs = length(signalLocs);
                    
                    % Load only required signals reduce memory calls
                    loadedSignalMemory = header.num_data_records*...
                        sum(edfSignalSizes(signalIndexes));
                    A = zeros(loadedSignalMemory,1);
                    for r = 1:header.num_data_records
                        [a count] = fread(fid, edfRecordSize, 'int16');
                        A([1+sizeSignalLocs*(r-1):sizeSignalLocs*r]) = a(signalLocs);
                    end
                    
                    % Reset global varaibles, which enable reshape functions to
                    % work correctly
                    header.num_signals = length(signalLabels);
                    signalHeader = signalHeader(signalIndexes);
                    num_signals = length(signalIndexes);
                end
                
                %num_data_records
            catch exception
                error(errMsg);
            end
            %------------------------------------------------- Process Signal Block
            % Get values to reshape block
            num_data_records = header.num_data_records;
            getSignalSamplesF = @(x)signalHeader(x).samples_in_record;
            signalSamplesPerRecord = arrayfun(getSignalSamplesF,[1:num_signals]);
            recordWidth = sum(signalSamplesPerRecord);
        
            % Reshape - Each row is a data record
            A = reshape(A, recordWidth, num_data_records)';
        
            % Create raw signal cell array
            signalCell = cell(1,num_signals);
            signalLocPerRow = horzcat([0],cumsum(signalSamplesPerRecord));
            for s = 1:num_signals
                % Get signal location
                signalRowWidth = signalSamplesPerRecord(s);
                signalRowStart = signalLocPerRow(s)+1;
                signaRowEnd = signalLocPerRow(s+1);
        
                % Create Signal
                signal = reshape(A(:,signalRowStart:signaRowEnd)',...
                    signalRowWidth*num_data_records, 1);
        
                % Get scaling factors
                dig_min = signalHeader(s).digital_min;
                dig_max = signalHeader(s).digital_max;
                phy_min = signalHeader(s).physical_min;
                phy_max = signalHeader(s).physical_max;
        
                % Assign signal value
                value = signal;
                
                % Convert to phyical units
                if RETURN_PHYSICAL_VALUES == 1
                    % Convert from digital to physical values
                    value = (signal-dig_min)/(dig_max-dig_min);
                    value = value.*double(phy_max-phy_min)+phy_min; 
                else
                    fprintf('Digital to Physical conversion is NOT performned: %s\n',...
                        edfFN);
                end
            
                signalCell{s} = value;
            end
        
        end % End Signal Load Section
        
        %------------------------------------------------------ Create return value
                nargout = 3;
        if nargout < 2
           varargout{1} = header;
        elseif nargout == 2
           varargout{1} = header;
           varargout{2} = signalHeader;
        elseif nargout == 3
            
           % Check if a reduce signal set is requested
           if ~isempty(epochs)
               % Determine signal sampling rate      
               signalSamples = arrayfun(...
                   @(x)signalHeader(x).samples_in_record, [1:num_signals]);
               signalIndex = ones(num_signals, 1)*[epochs(1)-1 epochs(2)]*30;
               samplesPerSecond = (signalSamples/header.data_record_duration)';
               signalIndex = signalIndex .* [samplesPerSecond samplesPerSecond];
               signalIndex(:,1) = signalIndex(:,1)+1;
               
               % Redefine signals to include specified epochs 
               signalIndex = int64(signalIndex);
               for s = 1:num_signals
                   signal = signalCell{s};
                   index = [signalIndex(s,1):signalIndex(s,2)];
                   signalCell{s} = signal(index);
               end
           end
           
           % Create Output Structure
           varargout{1} = header;
           varargout{2} = signalHeader;
           varargout{3} = signalCell;
        end % End Return Value Function
        
        % Close file explicitly
        if fid > 0 
            fclose(fid);
        end
 end