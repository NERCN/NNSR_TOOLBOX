    function processed_data = P01_cut_artifact_segments(~, data, fs, labels, del_mode, keep_mode)
            % data: n x m matrix, n = channels, m = samples
            % fs: Sampling rate
            % labels: n x L matrix, L = 10s segments
            % del_mode: 1: delete all segments with artifacts, 2: threshold-based trimming using 1-4Hz energy
            % keep_mode: 1: delete, 2: replace with NaN
            
            segment_length = fs * 10;  % 10 seconds per segment
            [n_channels, n_segments] = size(labels);
            [~, n_samples] = size(data);
            
            processed_data = data;  % Initialize processed data
            
            % Mode 1: Delete segments with artifacts
            if del_mode == 1
                for ch = 1:n_channels
                    for i = 1:n_segments
                        if labels(ch, i) == 1  % Artifact detected
                            start_idx = (i - 1) * segment_length + 1;
                            end_idx = i * segment_length;
                            if keep_mode == 1
                                processed_data(ch, start_idx:end_idx) = [];  % Delete
                            elseif keep_mode == 2
                                processed_data(ch, start_idx:end_idx) = NaN;  % Replace with NaN
                            end
                        end
                    end
                end
            end
            
            % Mode 2: Threshold-based trimming using 1-4Hz energy
            if del_mode == 2

            % Calculate baseline energy for each channel (using non-artifact segments)
            baseline_energy = zeros(n_channels, 1);
            
            for ch = 1:n_channels
                baseline_data = [];
                for i = 1:n_segments
                    if labels(ch, i) == 0  % No artifact
                        start_idx = (i - 1) * segment_length + 1;
                        end_idx = i * segment_length;
                        baseline_data = [baseline_data, data(ch, start_idx:end_idx)];
                    end
                end
                
                % Filter baseline data (1-4Hz) and calculate energy
                [b, a] = butter(4, [1, 4] / (fs / 2), 'bandpass');
                filtered_baseline_data = filtfilt(b, a, baseline_data);
                baseline_energy(ch) = mean(bandpower(filtered_baseline_data, fs, [1 4]));  % Baseline energy
            end

                for ch = 1:n_channels
                    for i = 1:n_segments
                        if labels(ch, i) == 1  % Artifact detected
                            start_idx = (i - 1) * segment_length + 1;
                            end_idx = i * segment_length;
                            segment_data = data(ch, start_idx:end_idx);
                            
                            % Filter the segment (1-4Hz)
                            [b, a] = butter(4, [1, 4] / (fs / 2), 'bandpass');
                            filtered_data = filtfilt(b, a, segment_data);
                            
                            % Calculate energy of the segment
                            segment_energy = bandpower(filtered_data, fs, [1 4]);
                            
                            % Calculate energy threshold (2x standard deviation of baseline energy)
                            baseline_std = std(baseline_energy(ch));
                            energy_threshold = baseline_energy(ch) + 2 * baseline_std;
                            
                            if segment_energy > energy_threshold  % Artifact detected
                                % Trim the segment (3 seconds before and after artifact)
                                delete_window = round(3 * fs);  % 3 seconds
                                delete_start = max(1, start_idx - delete_window);
                                delete_end = min(n_samples, end_idx + delete_window);
                                
                                if keep_mode == 1
                                    processed_data(ch, delete_start:delete_end) = [];  % Delete
                                elseif keep_mode == 2
                                    processed_data(ch, delete_start:delete_end) = NaN;  % Replace with NaN
                                end
                            else
                                % If no energy threshold detected, use peak detection
                                [peaks, peak_locs] = findpeaks(segment_data);
                                
                                if ~isempty(peak_locs)
                                    peak_window = round(2 * fs);  % 2 seconds window
                                    for peak_idx = 1:length(peak_locs)
                                        peak_time = peak_locs(peak_idx);
                                        delete_start = max(peak_time - peak_window, 1);
                                        delete_end = min(peak_time + peak_window, segment_length);
                                        
                                        % Protect last segment from exceeding data length
                                        if i == n_segments
                                            delete_end = min(delete_end, n_samples);
                                        end
                                        
                                        if keep_mode == 1
                                            segment_data(delete_start:delete_end) = [];  % Delete
                                        elseif keep_mode == 2
                                            segment_data(delete_start:delete_end) = NaN;  % Replace with NaN
                                        end
                                    end
                                end
                            end
                            
                            % Update processed data
                            processed_data(ch, start_idx:end_idx) = segment_data;
                        end
                    end
                end
            end
        end