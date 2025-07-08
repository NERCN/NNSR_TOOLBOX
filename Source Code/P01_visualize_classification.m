function P01_visualize_classification(app, IS_ECG, IS_STM, IS_MOVE)
    % Inputs:
    %   IS_ECG: A matrix of size (numChannels x numSegments), indicating whether there is an ECG signal for each channel and segment
    %   IS_STM: A matrix of size (numChannels x numSegments), indicating whether there is a STM signal for each channel and segment
    %   IS_MOVE: A matrix of size (numChannels x numSegments), indicating whether there is a MOVE signal for each channel and segment

    % Determine the image size
    [numChannels, numSegments] = size(IS_ECG);
    
    % Define colors
    greenColor = [224, 236, 236] / 255;  % Light green (when all values are 0)
    yellowColor = [255, 243, 205] / 255; % Yellow (when IS_ECG or IS_STM is 1 and IS_MOVE is 0)
    redColor = [255, 204, 204] / 255;    % Light red (when IS_MOVE is 1)
    
    % Initialize the image matrix
    img = zeros(numChannels, numSegments, 3);  % 3 color channels (RGB) per pixel

    % Iterate through each channel and segment to set the pixel colors based on the classification results
    for ch = 1:numChannels
        for seg = 1:numSegments
            if IS_MOVE(ch, seg) == 1
                img(ch, seg, :) = redColor;  % If MOVE is present, use light red
            elseif (IS_ECG(ch, seg) == 1 || IS_STM(ch, seg) == 1) && IS_MOVE(ch, seg) == 0
                img(ch, seg, :) = yellowColor;  % If either IS_ECG or IS_STM is 1 and no MOVE, use yellow
            elseif IS_ECG(ch, seg) == 0 && IS_STM(ch, seg) == 0 && IS_MOVE(ch, seg) == 0
                img(ch, seg, :) = greenColor;   % If all are 0, use light green
            end
        end
    end
    
    % Use imagesc to display the image, with pixel sizes adjusting to the area size
    imagesc(app.QUANLITY_INDEX, 1:numSegments, 1:numChannels, reshape(img, numChannels, numSegments, 3));
    
    % Flip the Y-axis direction (so the first channel is at the top)
    set(app.QUANLITY_INDEX, 'YDir', 'reverse');
    
    % Adjust the axis ticks
    set(app.QUANLITY_INDEX, 'YTick', 1:numChannels);
    set(app.QUANLITY_INDEX, 'TickLength', [0 0]);  % Ensure axis ticks don't visually protrude
    
    % Set aspect ratio to expand the vertical axis
    ylim(app.QUANLITY_INDEX, [1 - 0.5, numChannels + 0.5]);
    xlim(app.QUANLITY_INDEX, [1, numSegments]);
    % Alternatively, set the figure size ratio
end