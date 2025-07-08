      function C = minabs(~,A,B)
        M = size(A,2);
        N = size(B,2);
        if M ~= N
            disp("ERROR INPUT!");
        end
        C = A - A;
        for i = 1:M
            if abs(A(i)) < abs(B(i))
                C(i) = A(i);
            else 
                C(i) = B(i);
            end
        end
        end