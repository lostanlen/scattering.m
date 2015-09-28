function [psis,phi,littlewood_paley_sum] = display_bank(bank,fieldname)
%% Default argument management
if nargin<2
    fieldname = 'psis';
end

%%
original_sizes = bank.spec.size;
if length(original_sizes)>1
    error('Multi-dimensional bank display not ready yet');
end
nGammas = length(bank.metas);
nThetas = bank.spec.nThetas;
nLambdas = nGammas * nThetas;
psis = zeros([original_sizes,nLambdas]);
bank_spec = bank.spec;
support_index = 1;
for gamma = 1:nGammas
    for theta = 1:nThetas
        psi = bank.(fieldname){support_index}(gamma,theta);
        lambda = (theta-1)*nGammas + gamma;
        psis(:,lambda) = untrim_ft(psi,bank_spec);
    end
end
if strcmp(fieldname,'dual_psis')
    phi = untrim_ft(bank.dual_phi{support_index},bank_spec);
else
    phi = untrim_ft(bank.phi{support_index},bank_spec);
end
psi_energies = psis .* conj(psis);
phi_energy = phi .* conj(phi);
littlewood_paley_sum = sum(sum(psi_energies,3),2)+phi_energy;
%%
if ~bank_spec.is_spinned
    littlewood_paley_sum(2:end) = ...
        0.5 * (littlewood_paley_sum(2:end) + littlewood_paley_sum(end:-1:2));
end
sqrt_littlewood_paley_sum = sqrt(littlewood_paley_sum);

%% Display
if nargout==0
    amplitudes = sqrt([psi_energies,phi_energy]);
    ColorSet = zeros(nLambdas,3);
    ColorSet(:,1) = logspace(-1,0,nLambdas).';
    ColorSet(:,3) = logspace(0,-1,nLambdas).';
    is_held = false;
    for lambda = 1:nLambdas
        if is_held
            set(gca,'ColorOrder',ColorSet);
            hold on;
        end
        plot(abs(psis(:,lambda)),'LineWidth',1);
        is_held = true;
    end
    plot(abs(phi),'Color','k','LineWidth',2.5);
    plot([amplitudes,sqrt_littlewood_paley_sum]);
    hold off;
end
end
