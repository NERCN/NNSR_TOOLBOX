    function clEEG =  P01_remove_temp(~,rawEEG,QRS_point,Temp,klength)
        clEEG = rawEEG;
        point_num = length(QRS_point);
    
        % Remove temporary signal around each QRS point
        for Qplace = 1:point_num
            cutlength = QRS_point(Qplace) - klength : QRS_point(Qplace) + klength;
            clEEG(1, cutlength) = rawEEG(1, cutlength) - Temp;
        end
    end