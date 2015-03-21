function bank = sibling_blur_bank(bank,sibling)
sibling_log2_samplings = [sibling.metas.log2_sampling];
log2_oversampling = bank.behavior.S.log2_oversampling;
critical_log2_resamplings = 1 - bank.spec.J - sibling_log2_samplings;
bank.log2_resamplings = log2_oversampling + critical_log2_resamplings;
bank.phi = bank.phi{1};
bank.sibling.subscript = sibling.subscripts;
end