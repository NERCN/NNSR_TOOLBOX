      function temp = P02_Template_timerelocate(~,tempraw, fdf , locsleft , finalnode, methodtime)
        % disp("# Start template time relocated  ...");tic;
        mu = fdf * 1e-4; 
        temp = tempraw;
        N = length(tempraw(1,:));
        % smoothtemp = smooth(temp(1,:),temp(2,:),N,'rloess');
        smoothtemp = smooth(tempraw(1,:),tempraw(2,:),N/10,'sgolay',2);
        % smoothtemp = smooth(temp(1,:),temp(2,:),N/10);
        % reftemp = fit(temp(1,:)',smoothtemp,'pchipinterp');
        reftemp = fit(tempraw(1,:)',smoothtemp,'smoothingspline');
        switch methodtime
            case "Traverse"
                for ii = 3:finalnode
                    seg = locsleft(ii - 1) - locsleft(2) + 1:locsleft(ii) - locsleft(2);
                    delta = - 0.05*fdf:mu: 0.05*fdf;
                    error = zeros(1,length(delta));
                    for kk = 1:length(delta)
                        error(kk) = mean((reftemp(temp(1,seg) + delta(kk))'-temp(2,seg)).^2);
                    end
                    [~,index] = min(error);
                    temp(1,seg) = temp(1,seg) + delta(index);
                    fprintf(['# For seg ',num2str(ii),' delta is ',num2str(delta(index)),'\n']);
                end
            case "solve"
                for ii = 3:finalnode
                    seg = locsleft(ii - 1) - locsleft(2) + 1:locsleft(ii) - locsleft(2);
                    % fx = differentiate(FO, X) % 求微分
                    % slove function:
                    % sum(reftemp(x+segx)*diffreftemp(x+segx))-sum(segy*diffreftemp(x+segx))
                    % syms x;
                    fun = @(x) sum((reftemp(x+temp(1,seg))'-temp(2,seg)).*differentiate(reftemp,x+temp(1,seg))');
                    % error = fzero(fun,[-0.1*fdf, 0.1*fdf]);
                    error = fzero(fun,1e-9);
                    temp(1,seg) = temp(1,seg) + error;
                    % fprintf(['# For seg ',num2str(ii),' delta is ',num2str(error,10),'\n']);
                end
            case "solvewithy-wrong"
                for ii = 3:finalnode
                    seg = locsleft(ii - 1) - locsleft(2) + 1:locsleft(ii) - locsleft(2);
                    % fx = differentiate(FO, X) % 求微分
                    % slove function:
                    % sum(reftemp(x+segx)*diffreftemp(x+segx))-sum(segy*diffreftemp(x+segx))
                    Nn = length(seg);
                    %                     syms x;
                    fun = @(x) sum((reftemp(x+temp(1,seg))'-temp(2,seg)).* ...
                        differentiate(reftemp,x+temp(1,seg))') / sum(differentiate(reftemp,x+temp(1,seg))) ...
                        - sum((reftemp(x+temp(1,seg))'-temp(2,seg))) / Nn;
                    errorx = fzero(fun,0);
                    temp(1,seg) = temp(1,seg) + errorx;
                    errory = sum((reftemp(errorx+temp(1,seg))'-temp(2,seg))) / Nn;
                    temp(2,seg) = temp(2,seg) + errory;
                    fprintf(['# For seg ',num2str(ii),' delta x is ',num2str(errorx,10),'\n']);
                    fprintf(['# For seg ',num2str(ii),' delta y is ',num2str(errory,10),'\n']);
                end
            case "solvewithy"
                for ii = 3:finalnode
                    seg = locsleft(ii - 1) - locsleft(2) + 1:locsleft(ii) - locsleft(2);
                    %                     syms x;
                    %f(xi+lamda)-->reftemp(x+temp(1,seg))';
                    %f'(xi+lamda)->differentiate(reftemp,x+temp(1,seg))';
                    %yi----------->temp(2,seg);
                    %sum(f(xi+l)*f'(xi+l))*sum(yi^2)-sum(f(xi+l)*yi)*sum(f'(xi+l)*yi)=0;
                    %fun = @(x) sum((reftemp(x+temp(1,seg))'-temp(2,seg)).*differentiate(reftemp,x+temp(1,seg))');
                    fun = @(x) sum(reftemp(x+temp(1,seg))'.*...
                        differentiate(reftemp,x+temp(1,seg))')*...
                        sum(temp(2,seg).^2)-...
                        sum(reftemp(x+temp(1,seg))'.*temp(2,seg))*...
                        sum(differentiate(reftemp,x+temp(1,seg))'.*temp(2,seg));
                    errorx = fzero(fun,1e-10);
                    temp(1,seg) = temp(1,seg) + errorx;
                    errork = sum((reftemp(temp(1,seg))'.*temp(2,seg))) ...
                        /sum(temp(2,seg).^2);
                    temp(2,seg) = temp(2,seg) * errork;
                    fprintf(['# For seg ',num2str(ii),' delta x is ',num2str(errorx,10),'\n']);
                    fprintf(['# For seg ',num2str(ii),' delta y is ',num2str(errork,10),'\n']);
                end
        end
                    %         fprintf("# Time relocated succeed ! With time ");toc;
      end