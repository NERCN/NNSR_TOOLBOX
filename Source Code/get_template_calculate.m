      function temp = get_template_calculate(~,LFP1, fdf)
        N = length(LFP1);
        temp = zeros(2,N);
        temp(2,:) = LFP1(:);
        n = 1:N;
        temp(1,:) = n*fdf - floor(n * fdf);
        end
