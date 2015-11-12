function [phi_ft, energy_sum] = generate_phi_ft(psi_energy_sum,bank_spec)
%%
energy_sum = (psi_energy_sum + psi_energy_sum(end:-1:1)) / 2;
remainder = 1 - min(energy_sum,1);
phi_ft = zeros(size(energy_sum));
signal_dimension = length(bank_spec.size);
original_sizes = bank_spec.size;
switch signal_dimension
    case 1
        half_support_length = ...
            bank_spec.phi_bw_multiplier/2 * original_sizes/bank_spec.T;
        if bank_spec.phi.is_gamma
            phi_ift = gamma_1d(bank_spec);
            phi_ft = fft(phi_ift);
            energy_sum = energy_sum + phi_ft .* conj(phi_ft);
        elseif bank_spec.phi.is_gaussian
            phi_ift = gaussian_1d(bank_spec);
            phi_ft = fft(phi_ift);
            energy_sum = energy_sum + phi_ft .* conj(phi_ft);
        elseif bank_spec.phi.is_rectangular
            phi_ift = rectangular_1d(bank_spec);
            phi_ft = fft(phi_ift);
            energy_sum = energy_sum + phi_ft .* conj(phi_ft);
        elseif bank_spec.phi.is_by_substraction
            half_support = 2:half_support_length;
            symmetric_support = original_sizes + 1 - half_support + 1;
            sqrt_truncated_remainder = sqrt(remainder(half_support));
            phi_ft(half_support) = sqrt_truncated_remainder;
            phi_ft(symmetric_support) = sqrt_truncated_remainder;
            phi_ft(1+0) = 1;
            energy_sum(half_support) = max(energy_sum(half_support), 1);
            energy_sum(symmetric_support) = energy_sum(half_support);
            energy_sum(1+0) = 1;
        end
        if ~bank_spec.phi.is_rectangular
            % We must ensure that phi_ft is exactly zero at the frequency pi
            % in order to yield real results for real inputs.
            % This is skipped when phi is rectangular since a rectangular
            % phi often corresponds to octave filtering, i.e. when we want
            % a complex output from a real output, and conversely we care
            % about spatial localization.
            phi_ft(1+end/2) = 0;
        end
    case 2
        error('2D phi not ready yet');
end
end
