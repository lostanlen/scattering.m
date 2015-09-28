function phi_ft= generate_phi_ft(psi_energy_sum,bank_spec)
%%
symmetrized_energy_sum = (psi_energy_sum + psi_energy_sum(end:-1:1)) / 2;
remainder = 1 - min(symmetrized_energy_sum,1);
phi_ft = zeros(size(psi_energy_sum));
signal_dimension = length(bank_spec.size);
original_sizes = bank_spec.size;
switch signal_dimension
    case 1
        half_support_length = ...
            bank_spec.phi_bw_multiplier/2 * original_sizes/bank_spec.T;
        if bank_spec.phi.is_gaussian
            denominator = half_support_length*half_support_length / log(10);
            half_size = original_sizes / 2;
            half_support = 2:half_size;
            symmetric_support = original_sizes + 1 - half_support + 1;
            omegas = half_support - 1;
            half_gaussian = exp(- omegas .* omegas / denominator);
            phi_ft(half_support) = half_gaussian;
            phi_ft(symmetric_support) = half_gaussian;
            phi_ft(half_size+1) = exp(- half_size*half_size / denominator);
        elseif bank_spec.phi.is_rectangular
            phi_ift = zeros(original_sizes, 1);
            half_ift_support = 1:((bank_spec.T-1)/2);
            phi_ift(1 + half_ift_support) = 1 / bank_spec.T;
            phi_ift(1 + end - half_ift_support) = 1  / bank_spec.T;
            phi_ift(1+0) = 1 / bank_spec.T;
            phi_ft = fft(phi_ift);
        elseif bank_spec.phi.is_by_substraction
            half_support = 2:half_support_length;
            symmetric_support = original_sizes + 1 - half_support + 1;
            sqrt_truncated_remainder = sqrt(remainder(half_support));
            phi_ft(half_support) = sqrt_truncated_remainder;
            phi_ft(symmetric_support) = sqrt_truncated_remainder;
            phi_ft(1+0) = 1;
        end
    case 2
        error('2D phi not ready yet');
end
end
