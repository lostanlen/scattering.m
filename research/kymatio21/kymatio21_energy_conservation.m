Q = 1;

N = 2^12;
Fs = 8000;


opts{1} = default_auditory(N,8000,Q);
opts{2}.time = struct();

archs = sc_setup(opts);

%%
archbis = archs;
archbis{1}.invariants{1}.behavior.S.log2_oversampling = inf;
archbis{1}.banks{1}.behavior.S.log2_oversampling = inf;
archbis{1}.banks{1}.behavior.U.log2_oversampling = inf;
archbis{2}.banks{1}.behavior.S.log2_oversampling = inf;
archbis{2}.banks{1}.behavior.U.log2_oversampling = inf;

signal = zeros(N, 1);
signal(1) = 1;

[S, U, Y] = sc_propagate(signal, archbis);

plot(Y{1}{1}.data)
psi1 = [Y{1}{2}.data{:}];
phi1 = S{1}.data;
scatteringm_filterbank_Q1_J8_N4096 = cat(2, psi1, phi1);

%%
t = linspace(0, 1-1/N, N).';

M = archs{1}.banks{1}.spec.J;
norms_in = zeros(M, 1);
norms_out = zeros(M, 1);

n_signals = 5;
Smat = cell(5, M);

for fig_id = 1:n_signals
    for m = 1:M

        if fig_id == 1
            signal = rand(N,1) - 0.5;
        elseif fig_id == 2
            signal = randn(N, 1);
        elseif fig_id == 3
            signal = cos(2*pi * t * 2^(m));
        elseif fig_id == 4
            signal = zeros(N, 1);
            signal(1, :) = 1;
        elseif fig_id == 5
            signal = cos(2*pi * (20480.^t - 1) * .01);
        end

        
        [S, U, Y] = sc_propagate(signal, archs);

        norms_in(m) = norm(signal, 2);
        norms_out(m) = sc_norm(S);
        
        Smat{fig_id, m} = sc_format(S, 1, 1:3);
    end
%     subplot(3, 1, fig_id);
%     
%     bar((1:M)-1, norms_out/norms_in, 5)
%     xlim([-0.5, M]);
%     ylim([0, 7]);
%     
%     if fig_id == 1
%         xlabel('Repeated trials of uniform noise');
%     elseif fig_id == 2
%         xlabel('Repeated trials of Gaussian noise');
%     else
%         xlabel('Fundamental frequency of input (log2 scale)');
%     end
%     ylabel('Output-to-input energy ratio');
%     grid();
end
    
%Smat = reshape(cat(3, Smat{:}), [37, 32, 3, 10])
%%
set(gcf, 'Color', 'w');
export_fig("kymatio21_energy_conservation.png", "-m4", "-transparent");