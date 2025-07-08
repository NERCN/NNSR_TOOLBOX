      function Temp = P02_get_temp(~,rawEEG,QRS_point,klength)
        point_num = length(QRS_point);
        avg = zeros(1,2*klength+1);
        store = zeros(point_num,2*klength+1);
        for Qplace = 1:point_num
            cutlength = QRS_point(Qplace)-klength:QRS_point(Qplace)+klength;
            store(Qplace,:) = rawEEG(1,cutlength);
        end
        for store_place = 1:2*klength+1
            store_place_all = store(:,store_place);
            avg(store_place) = mean(store_place_all(store_place_all~=0));
        end
        Temp = avg;
        end