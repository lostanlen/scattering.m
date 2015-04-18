function [phi_ft,energy_sum] = generate_phi_ft(psi_energy_sum,bank_spec)
%%
symmetrized_energy_sum = (psi_energy_sum + psi_energy_sum(end:-1:1)) / 2;
remainder = 1 - min(symmetrized_energy_sum,1);
phi_ft = zeros(size(psi_energy_sum));
signal_dimension = length(bank_spec.size);
original_sizes = bank_spec.size;
switch signal_dimension
    case 1
        half_support_length = original_sizes/bank_spec.T;
        half_support = 2:half_support_length;
        symmetric_support = original_sizes + 1 - half_support + 1;
        sqrt_truncated_remainder = sqrt(remainder(half_support));
        phi_ft(half_support) = sqrt_truncated_remainder;
        phi_ft(symmetric_support) = sqrt_truncated_remainder;
        % We enforce energy conservation for constant signals by setting
        % the Fourier transform to exactly 1 at frequency zero.
        phi_ft(1+0) = 1;
    case 2
        error('2D phi not ready yet');
end
spin_multiplier = 1 + ~bank_spec.is_spinned;
energy_sum = psi_energy_sum;
energy_sum(half_support) = max(psi_energy_sum(half_support),spin_multiplier);
if bank_spec.is_spinned
    energy_sum(symmetric_support) = energy_sum(half_support);
end
energy_sum(1+0) = spin_multiplier;
end