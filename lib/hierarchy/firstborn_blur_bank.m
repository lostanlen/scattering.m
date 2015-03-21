function bank = firstborn_blur_bank(bank)
critical_log2_sampling = 1 - log2(bank.spec.T);
log2_oversampling = bank.behavior.S.log2_oversampling;
bank.log2_resamplings = critical_log2_sampling + log2_oversampling;
bank.phi = bank.phi{1};
end