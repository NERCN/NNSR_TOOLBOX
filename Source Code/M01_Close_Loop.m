function [CMDS,judg] = M01_Close_Loop(~,data_input,betapower,therehold)

   % judg = max(data_input);
   judg = betapower;
   if judg >= therehold
       CMDS = 1;
   elseif judg < therehold
       CMDS = 0;
   end
    
end