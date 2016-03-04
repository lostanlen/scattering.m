function path = fetch_firstorder(S1, gamma1)
gamma1_start = S1.ranges{1}(1,2);
path = S1.data(:, gamma1 - gamma1_start + 1);
end

