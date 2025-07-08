function [qrs_amp_raw, qrs_i_raw, delay] = P01_pan_tompkin(~, ecg, fs, gr)
    % Inputs:
    %   ecg: ECG signal (vector)
    %   fs: Sampling frequency
    %   gr: If 1, plots the results; if 0, no plot

    % Check if ecg is a vector
    if ~isvector(ecg)
        error('ecg must be a row or column vector');
    end
    if nargin < 3
        gr = 1; % Default value, the function always plots
    end
    ecg = ecg(:); % Vectorize
    
    % ===================== Initialize ============================ %
    delay = 0;
    skip = 0; % Becomes 1 when a T wave is detected
    m_selected_RR = 0;
    mean_RR = 0;
    ser_back = 0;
    ax = zeros(1,6);

    % ============ Noise Cancellation (Filtering) (5-15 Hz) ========== %
    if fs == 200
        % Remove the mean of the signal
        ecg = ecg - mean(ecg);
        
        % Low Pass Filter: H(z) = ((1 - z^(-6))^2)/(1 - z^(-1))^2
        Wn = 12*2/fs;
        N = 3; % Order of 3 for less processing
        [a, b] = butter(N, Wn, 'low'); % Bandpass filtering
        ecg_l = filtfilt(a, b, ecg);
        ecg_l = ecg_l / max(abs(ecg_l));

        % High Pass Filter: H(z) = (-1 + 32z^(-16) + z^(-32))/(1 + z^(-1))
        Wn = 5*2/fs;
        N = 3; % Order of 3 for less processing
        [a, b] = butter(N, Wn, 'high'); % Bandpass filtering
        ecg_h = filtfilt(a, b, ecg_l);
        ecg_h = ecg_h / max(abs(ecg_h));
        
        % Plot filtered signal if gr is 1
        if gr
            ax(3) = subplot(323);
            plot(ecg_h);
            axis tight;
            title('High Pass Filtered');
        end
    else
        % Bandpass filter for other sampling frequencies
        f1 = 5; % Low frequency cutoff to remove baseline wander
        f2 = 15; % High frequency cutoff to remove noise
        Wn = [f1 f2] * 2 / fs; % Cutoff based on fs
        N = 3; % Order of 3 for less processing
        [a, b] = butter(N, Wn); % Bandpass filtering
        ecg_h = filtfilt(a, b, ecg);
        ecg_h = ecg_h / max(abs(ecg_h));
    end
    
    % ================== Derivative Filter ========================== %
    % H(z) = (1/8T)(-z^(-2) - 2z^(-1) + 2z + z^(2))
    if fs ~= 200
        int_c = (5 - 1) / (fs * 1 / 40);
        b = interp1(1:5, [1 2 0 -2 -1] * (1/8) * fs, 1:int_c:5);
    else
        b = [1 2 0 -2 -1] * (1/8) * fs;
    end

    ecg_d = filtfilt(b, 1, ecg_h);
    ecg_d = ecg_d / max(ecg_d);
    
    % ========== Squaring to Enhance Dominant Peaks ================== %
    ecg_s = ecg_d.^2;
    ecg_m = conv(ecg_s, ones(1, round(0.150 * fs)) / round(0.150 * fs));
    delay = delay + round(0.150 * fs) / 2;

    [pks, locs] = findpeaks(ecg_m, 'MINPEAKDISTANCE', round(0.2 * fs));

    % ================== Initialize Other Parameters =============== %
    LLp = length(pks);
    
    % ---------------- Stores QRS wrt Signal and Filtered Signal ------------------ %
    qrs_c = zeros(1, LLp);           % Amplitude of R
    qrs_i = zeros(1, LLp);           % Index
    qrs_i_raw = zeros(1, LLp);       % Raw index of R
    qrs_amp_raw = zeros(1, LLp);     % Amplitude of Raw R
    nois_c = zeros(1, LLp);          % Noise amplitude
    nois_i = zeros(1, LLp);          % Noise index
    SIGL_buf = zeros(1, LLp);        % Signal buffer
    NOISL_buf = zeros(1, LLp);       % Noise buffer
    SIGL_buf1 = zeros(1, LLp);       % Signal buffer 1
    NOISL_buf1 = zeros(1, LLp);      % Noise buffer 1
    THRS_buf1 = zeros(1, LLp);       % Threshold buffer 1
    THRS_buf = zeros(1, LLp);        % Threshold buffer
    
    % Initialize the training phase (2 seconds of the signal)
    THR_SIG = max(ecg_m(1:2 * fs)) * 1 / 3; % 0.25 of max amplitude
    THR_NOISE = mean(ecg_m(1:2 * fs)) * 1 / 2; % 0.5 of mean considered noise
    SIG_LEV = THR_SIG;
    NOISE_LEV = THR_NOISE;
    
    % Initialize bandpass filter threshold (2 seconds of the bandpass signal)
    THR_SIG1 = max(ecg_h(1:2 * fs)) * 1 / 3;
    THR_NOISE1 = mean(ecg_h(1:2 * fs)) * 1 / 2;
    SIG_LEV1 = THR_SIG1;
    NOISE_LEV1 = THR_NOISE1;
    
    % ================== Thresholding and Decision Rule ============= %
    Beat_C = 0; % Raw Beats
    Beat_C1 = 0; % Filtered Beats
    Noise_Count = 0; % Noise Counter
    
    for i = 1:LLp
        % ===== Locate the corresponding peak in the filtered signal === %
        if locs(i) - round(0.150 * fs) >= 1 && locs(i) <= length(ecg_h)
            [y_i, x_i] = max(ecg_h(locs(i) - round(0.150 * fs):locs(i)));
        else
            if i == 1
                [y_i, x_i] = max(ecg_h(1:locs(i)));
                ser_back = 1;
            elseif locs(i) >= length(ecg_h)
                [y_i, x_i] = max(ecg_h(locs(i) - round(0.150 * fs):end));
            end
        end
        
        % ================= Update Heart Rate ==================== %
        if Beat_C >= 9
            diffRR = diff(qrs_i(Beat_C - 8:Beat_C)); % Calculate RR interval
            mean_RR = mean(diffRR); % Mean of previous 8 RR intervals
            comp = qrs_i(Beat_C) - qrs_i(Beat_C - 1); % Latest RR
            
            if comp <= 0.92 * mean_RR || comp >= 1.16 * mean_RR
                % Lower thresholds to detect better in MVI
                THR_SIG = 0.5 * (THR_SIG);
                THR_SIG1 = 0.5 * (THR_SIG1);
            else
                m_selected_RR = mean_RR; % Regular beats mean
            end
        end

        % =================== Locate Noise and QRS Peaks ================== %
        if pks(i) >= THR_SIG
            % If no QRS in 360ms of the previous QRS, see if T wave is present
            if Beat_C >= 3
                if (locs(i) - qrs_i(Beat_C)) <= round(0.3600 * fs)
                    Slope1 = mean(diff(ecg_m(locs(i) - round(0.075 * fs):locs(i)))); % Slope of the waveform at the current position
                    Slope2 = mean(diff(ecg_m(qrs_i(Beat_C) - round(0.075 * fs):qrs_i(Beat_C)))); % Slope of the previous R wave
                    if abs(Slope1) <= abs(0.5 * (Slope2)) % Slope less than 0.5 of previous R
                        Noise_Count = Noise_Count + 1;
                        nois_c(Noise_Count) = pks(i);
                        nois_i(Noise_Count) = locs(i);
                        skip = 1; % T wave identification
                        % Adjust noise levels
                        NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1;
                        NOISE_LEV = 0.125 * pks(i) + 0.875 * NOISE_LEV;
                    else
                        skip = 0;
                    end
                end
            end

            if skip == 0
                Beat_C = Beat_C + 1;
                qrs_c(Beat_C) = pks(i);
                qrs_i(Beat_C) = locs(i);
                
                if y_i >= THR_SIG1
                    Beat_C1 = Beat_C1 + 1;
                    if ser_back
                        qrs_i_raw(Beat_C1) = x_i; % Save index of bandpass
                    else
                        qrs_i_raw(Beat_C1) = locs(i) - round(0.150 * fs) + (x_i - 1); % Save index of bandpass
                    end
                    qrs_amp_raw(Beat_C1) = y_i; % Save amplitude of bandpass
                    SIG_LEV1 = 0.125 * y_i + 0.875 * SIG_LEV1; % Adjust threshold for bandpass filtered signal
                end
                SIG_LEV = 0.125 * pks(i) + 0.875 * SIG_LEV; % Adjust Signal level
            end
        elseif (THR_NOISE <= pks(i)) && (pks(i) < THR_SIG)
            % Adjust Noise level in filtered and MVI signals
            NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1;
            NOISE_LEV = 0.125 * pks(i) + 0.875 * NOISE_LEV;
        elseif pks(i) < THR_NOISE
            Noise_Count = Noise_Count + 1;
            nois_c(Noise_Count) = pks(i);
            nois_i(Noise_Count) = locs(i);
            NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1; % Adjust noise level in filtered signal
            NOISE_LEV = 0.125 * pks(i) + 0.875 * NOISE_LEV; % Adjust noise level in MVI
        end

        % Update thresholds for signal and noise
        if NOISE_LEV ~= 0 || SIG_LEV ~= 0
            THR_SIG = NOISE_LEV + 0.25 * (abs(SIG_LEV - NOISE_LEV));
            THR_NOISE = 0.5 * (THR_SIG);
        end

        if NOISE_LEV1 ~= 0 || SIG_LEV1 ~= 0
            THR_SIG1 = NOISE_LEV1 + 0.25 * (abs(SIG_LEV1 - NOISE_LEV1));
            THR_NOISE1 = 0.5 * (THR_SIG1);
        end
        
        SIGL_buf(i) = SIG_LEV;
        NOISL_buf(i) = NOISE_LEV;
        THRS_buf(i) = THR_SIG;
        
        SIGL_buf1(i) = SIG_LEV1;
        NOISL_buf1(i) = NOISE_LEV1;
        THRS_buf1(i) = THR_SIG1;

        skip = 0; % Reset skip
        ser_back = 0; % Reset ser_back
    end

    % Trim results to valid ranges
    qrs_i_raw = qrs_i_raw(1:Beat_C1);
    qrs_amp_raw = qrs_amp_raw(1:Beat_C1);
    qrs_c = qrs_c(1:Beat_C);
    qrs_i = qrs_i(1:Beat_C);

    % Plot results if gr is 1
    if gr
        hold on;
        scatter(qrs_i, qrs_c, 'm');
        hold on;
        plot(locs, NOISL_buf, '--k', 'LineWidth', 2);
        hold on;
        plot(locs, SIGL_buf, '--r', 'LineWidth', 2);
        hold on;
        plot(locs, THRS_buf, '--g', 'LineWidth', 2);
    end
end
