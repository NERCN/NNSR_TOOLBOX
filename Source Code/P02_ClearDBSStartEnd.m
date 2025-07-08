function x = P02_ClearDBSStartEnd(~,x)
   x(1:10) = 0;
   x(end-10:end) = 0;
end