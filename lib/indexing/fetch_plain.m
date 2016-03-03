function path =  fetch_plain(S2, gamma1, gamma2)
gamma2_start = S2.ranges{1+1}(1,1);
gamma2_index = gamma2 - gamma2_start + 1;
gamma1_start = S2.ranges{1+0}{gamma2_index}(1,2);
gamma1_index = gamma1 - gamma1_start + 1;
path = S2.data{gamma2_index}(:, gamma1_index);
end