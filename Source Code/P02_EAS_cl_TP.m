      function [clEEG,Temp] = P02_EAS_cl_TP(app,rawEEG,ECG,fsEEG,fsECG,klength)
            rawEEG = double(rawEEG); % 
            ECG = double(ECG);
            ECG(rawEEG == 0) = 0;
            [~,QRS_point,~]=P02_pan_tompkin(app,ECG,fsECG,0);%
            QRS_point = round((QRS_point + 1)*fsEEG/fsECG);% 
            if klength == 0
            klength = round(min(diff(QRS_point))/1.5);% 
            end
            Reallength = [1,length(rawEEG)];
            if QRS_point(end) + klength > length(rawEEG)
                rawEEG = [rawEEG,zeros(1,QRS_point(end) + klength - length(rawEEG))];
            end
            if QRS_point(1) - klength < 1
                rawEEG = [zeros(1,klength - QRS_point(1) + 1),rawEEG];
                Reallength = Reallength + klength - QRS_point(1) + 1;
                QRS_point = QRS_point +  klength - QRS_point(1) + 1;
            end
        
            Temp = P02_get_temp(app,rawEEG,QRS_point,klength);
            clEEG = P02_remove_temp(app,rawEEG,QRS_point,Temp,klength);
            clEEG(rawEEG == 0) = 0;
            clEEG = clEEG(Reallength(1):Reallength(2));
        end