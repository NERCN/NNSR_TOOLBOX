      function noise = Smooth_template(~,temp,set_mode)
        switch set_mode
            case "smooth"
                noise = smooth(temp(1,:),temp(2,:))';
            case "seg_smooth"
                noise = temp(2,:) - temp(2,:);
                [sorttemp1,index] = sort(temp(1,:));
                sorttemp2 = temp(2,index);
                z = sorttemp2(1)/abs(sorttemp2(1));
                l = 1;
                for i = 2:size(sorttemp2,2)
                    if sorttemp2(i)  == 0
                        continue;
                    elseif sorttemp2(i)/abs(sorttemp2(i)) == z
                        continue;
                    elseif l == i - 1
                        noise(i - 1) = sorttemp2(i - 1);
                        l = i;
                        z = -z;
                    elseif z == -1
                        N = min(30,i-l);
                        D = min(3,N-1);
                        noise(l:i - 1) = smooth(sorttemp1(l:i - 1) * 1000,sorttemp2(l:i - 1),N,'sgolay' ,D);
                        l = i;
                        z = 1;
                    elseif z == 1
                        N = min(15,i-l);
                        D = min(9,N-1);
                        noise(l:i - 1) = smooth(sorttemp1(l:i - 1)* 1000,sorttemp2(l:i - 1),N,'sgolay' ,D);
                        l = i;
                        z = -1;
                    end
                end
                if l == i
                    noise(l) = sorttemp2(l);
                elseif z == -1
                    N = min(15,i-l+1);
                    D = min(5,N-1);
                    noise(l:i) = smooth(sorttemp1(l:i),sorttemp2(l:i),N,'sgolay' ,D);
                elseif z == 1
                    N = min(30,i-l+1);
                    D = min(25,N-1);
                    noise(l:i) = smooth(sorttemp1(l:i),sorttemp2(l:i),N,'sgolay' ,D);
                end
                [~,index2] = sort(index);
                noise = noise(index2);
            otherwise
        %           disp("# ERROR TEMP PROCESSING MODE ! RESET TEMP PROCESSING MODE . ");
                return;
        end
        end