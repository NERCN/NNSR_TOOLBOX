      function [processed_LFP,Alltemplate] = F4a_LFPdenoise_ECG_EAS_win(app,LFP,fsLFP,win)
        if size(LFP,1) > size(LFP,2)
            LFP = LFP';
        end
        channel = size(LFP,1);
        winnum = 1;
        N_original_LFPlength = length(LFP);
        timelength = N_original_LFPlength/fsLFP;
        time_win_length = floor(timelength/win)+2;
        LFP_timelength_dot = time_win_length * fsLFP * win;
        
        LFP = [zeros(channel,fsLFP),LFP,zeros(channel,LFP_timelength_dot - N_original_LFPlength)]; % 此处在最后多加一整个
        processed_LFP = LFP;
        Alltemplate = cell(channel,time_win_length - 1);
        while winnum <= time_win_length - 1
        %     fprintf('# Now process window - ');
        %     disp(winnum);
            win_Length_dots_LFP = (winnum-1)*win*fsLFP+1:(winnum*win+2)*fsLFP;
            save_win_Length_dots = ((winnum-1)*win+1)*fsLFP+1:(winnum*win+1)*fsLFP;
            if sum(LFP(:,win_Length_dots_LFP) == 0) == length(win_Length_dots_LFP)
                for cha = 1:size(channelLFP,2)
                    processed_LFP(cha,save_win_Length_dots) = 0;
                end
            else
                for cha = 1:channel
                    [clLFP,Template]=P02_EAS_cl_TP(app,LFP(cha,win_Length_dots_LFP),LFP(cha,win_Length_dots_LFP),fsLFP,fsLFP);
                    processed_LFP(cha,save_win_Length_dots) = clLFP(fsLFP+1:(win+1)*fsLFP);
                    Alltemplate{cha,winnum} = Template;
                end
            end
            winnum = winnum + 1;
        end
        processed_LFP = processed_LFP(:,fsLFP+1:N_original_LFPlength+fsLFP+1);
      end