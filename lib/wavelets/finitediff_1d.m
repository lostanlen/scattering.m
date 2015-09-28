function finitediffs = finitediff_1d(~, bank_spec)
finitediffs = zeros(bank_spec.size, 1);

% First scale (first-order finite difference)
finitediffs(end, 1) = -1 / (sqrt(2) * sqrt(3));
finitediffs(1, 1) = 0;
finitediffs(2, 1) = 1 / (sqrt(2) * sqrt(3));

% Second scale (second-order finite difference)
finitediffs(end, 2) = 1 / (sqrt(6) * sqrt(3));
finitediffs(1, 2) = -2 / (sqrt(6) * sqrt(3));
finitediffs(2, 2) = 1 / (sqrt(6) * sqrt(3));
end

