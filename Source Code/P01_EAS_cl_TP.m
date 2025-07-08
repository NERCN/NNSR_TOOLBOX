function [clEEG, Temp] = P01_EAS_cl_TP(app, rawEEG, ECG, fsEEG, fsECG, klength)

    rawEEG = double(rawEEG); % Ensure rawEEG is of type double
    ECG = double(ECG);
    ECG(rawEEG == 0) = 0;

    % Calculate QRS points using ECG
    [~, QRS_point, ~] = P01_pan_tompkin(app, ECG, fsECG, 0); 
    QRS_point = round((QRS_point + 1) * fsEEG / fsECG); % Recalculate QRS points for EEG

    % Set default klength if not provided
    if klength == 0
        klength = round(min(diff(QRS_point)) / 1.5); % Calculate distance around QRS peaks
    end

    % Adjust EEG length to ensure sufficient padding around QRS points
    Reallength = [1, length(rawEEG)];
    if QRS_point(end) + klength > length(rawEEG)
        rawEEG = [rawEEG, zeros(1, QRS_point(end) + klength - length(rawEEG))];
    end
    if QRS_point(1) - klength < 1
        rawEEG = [zeros(1, klength - QRS_point(1) + 1), rawEEG];
        Reallength = Reallength + klength - QRS_point(1) + 1;
        QRS_point = QRS_point + klength - QRS_point(1) + 1;
    end

    % Get temporary signal and clean EEG signal
    Temp = P01_get_temp(app, rawEEG, QRS_point, klength);
    clEEG = P01_remove_temp(app, rawEEG, QRS_point, Temp, klength);

    % Set zero values back to the original rawEEG signal positions
    clEEG(rawEEG == 0) = 0;
    clEEG = clEEG(Reallength(1):Reallength(2));
end
