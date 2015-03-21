function difference_to_requirement = test_bank_cutoff(bank,toleration)
if nargin<2
    toleration = 1; % in dB
end
%%
psis = display_bank(bank);
difference = abs(psis(:,1))-abs(psis(:,2));
zero_crossing = (difference<0) & (circshift(difference,-1)>0);
actual_cutoff = abs(psis(zero_crossing,1));
actual_cutoff_in_dB = - 20 * log10(actual_cutoff);
required_cutoff_in_dB = bank.spec.cutoff_in_dB;
difference_to_requirement = actual_cutoff_in_dB - required_cutoff_in_dB;
%%
if nargout==0
    assert(abs(difference_to_requirement)<toleration);
end
end
