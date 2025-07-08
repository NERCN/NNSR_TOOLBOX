  function plv = P02_F2b_PLV(~, phase_sig1, phase_sig2 )
        [~, b] = size(phase_sig1);
        e = exp(1i*(phase_sig1 - phase_sig2));
        plv = abs(sum(e,2)) / b;
  end