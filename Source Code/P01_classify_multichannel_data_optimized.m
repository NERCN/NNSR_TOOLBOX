function [IS_ECG, IS_STM, IS_MOVE] = P01_classify_multichannel_data_optimized(~, data, input_sampleRate, net, bpFilt)
    % Inputs:
    %   data: n*m input signal, where n is the number of channels and m is the length of data for each channel
    %   input_sampleRate: The sampling rate of the input data (arbitrary sampling rate)
    %   net: The trained CNN network
    %   bpFilt: The bandpass filter
    % Outputs:
    %   IS_ECG, IS_STM, IS_MOVE: The label sequences for each channel
    
    wides = 91;
    overlap = 0.9;
    imageSize = [121, wides, 1];

    numChannels = size(data, 1);  % Number of channels
    dataLength = size(data, 2);   % Data length for each channel
    target_sampleRate = 250;      % Target sample rate (250 Hz)
    expected_data_length = 10 * input_sampleRate;  % Expected length of each segment (10 seconds)
    numSegments = floor(dataLength / expected_data_length);  % Number of segments per channel
    
    % Initialize result arrays, storing by channel and segment
    IS_ECG = zeros(numChannels, numSegments);
    IS_STM = zeros(numChannels, numSegments);
    IS_MOVE = zeros(numChannels, numSegments);
    
    % Perform filtering for all channels and segments at once
    data_filtered = filtfilt(bpFilt, data');  % Apply bandpass filter
    
    % Resample data if necessary
    if input_sampleRate ~= target_sampleRate
        data_resampled = resample(data_filtered, target_sampleRate, input_sampleRate)';  % Resample for all channels at once
    else
        data_resampled = data_filtered;
    end
    
    % Length of each resampled channel's data
    resampled_length = size(data_resampled, 2);
    resampled_segment_length = 10 * target_sampleRate;  % Length of each segment in resampled data
    numSegments_resampled = floor(resampled_length / resampled_segment_length);  % Number of segments (based on 250 Hz)
    
    % Process data for each channel
    for ch = 1:numChannels
        % Process each segment of the current channel's data
        for seg = 1:numSegments_resampled
            % Extract the data for the current segment (10 seconds)
            segment_start = (seg-1) * resampled_segment_length + 1;
            segment_end = seg * resampled_segment_length;
            segment_data = data_resampled(ch, segment_start:segment_end);
            
            % 1D time domain input
            data1DProcessed = segment_data;  % Ensure 1D data length is 2500

            % Generate 2D spectrogram data
            [B, f, ~] = spectrogram(data1DProcessed, 250, overlap * 250, 250, 250);
            B = B(f <= 120, :);  % Limit the spectrogram to frequencies below 120 Hz
            B_log = 10 * log10(abs(B));
            B_log_norm = (B_log - min(B_log(:))) / (max(B_log(:)) - min(B_log(:)));
            image2DProcessed = imresize(B_log_norm, [121, wides]);
        
            % Format data to fit the network input format
            data2DInput = reshape(image2DProcessed, imageSize);  % 2D data
            data1DInput = reshape(data1DProcessed, [2500, 1]);   % 1D data
        
            % Create arrayDatastore for 2D and 1D data
            ds2D = arrayDatastore(data2DInput, 'IterationDimension', 4);
            ds1D = arrayDatastore(data1DInput, 'IterationDimension', 2);
        
            % Combine and format data for storage
            dsCombined = combine_function_new(ds2D, ds1D);
            dsTransformed = transform(dsCombined, @P01_formatForPrediction);
        
            % Classify using the trained network model
            predictedLabel = classify(net, dsTransformed);
    
            % Set IS_ECG, IS_STM, IS_MOVE based on classification result
            switch string(predictedLabel)
                case "0"
                    IS_ECG(ch, seg) = 0;
                    IS_STM(ch, seg) = 0;
                    IS_MOVE(ch, seg) = 0;
                case "1"
                    IS_ECG(ch, seg) = 0;
                    IS_STM(ch, seg) = 1;
                    IS_MOVE(ch, seg) = 0;
                case "2"
                    IS_ECG(ch, seg) = 1;
                    IS_STM(ch, seg) = 0;
                    IS_MOVE(ch, seg) = 0;
                case "3"
                    IS_ECG(ch, seg) = 0;
                    IS_STM(ch, seg) = 0;
                    IS_MOVE(ch, seg) = 1;
                case "4"
                    IS_ECG(ch, seg) = 1;
                    IS_STM(ch, seg) = 1;
                    IS_MOVE(ch, seg) = 0;
            end
        end
    end
end
