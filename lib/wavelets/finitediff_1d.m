function finitediffs = finitediff_1d(~, bank_spec)
finitediffs = zeros(bank_spec.size, 1);

% First scale (first-order finite difference)
finitediffs(end, 1) = -1;
finitediffs(1, 1) = 0;
finitediffs(2, 1) = 1;

% Second scale (second-order finite difference)
finitediffs(end, 2) = 1;
finitediffs(1, 2) = -2;
finitediffs(2, 2) = 1;
end

