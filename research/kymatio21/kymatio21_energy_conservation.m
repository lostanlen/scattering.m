Q = 1;

J = 10;
N = 2^12;
Fs = 8000;


opts{1} = default_auditory(N,8000,Q);
opts{2}.time = struct();

archs = sc_setup(opts);

t = linspace(0, 1-1/N, N).';

M = J;
norms_in = zeros(M, 1);
norms_out = zeros(M, 1);

for fig_id = 1:3
    for m = 1:M

        subplot(3, 1, fig_id);
        if fig_id == 1
            signal = rand(N,1) - 0.5;
        elseif fig_id ==2
            signal = randn(N, 1);
        else
            signal = cos(2*pi * t * 2^(m));
        end

        
        [S, U, Y] = sc_propagate(signal, archs);

        norms_in(m) = norm(signal, 2);
        norms_out(m) = sc_norm(S);
    end

    bar((1:M)-1, norms_out/norms_in, 5)
    xlim([-0.5, M]);
    ylim([0, 7]);
    
    if fig_id == 1
        xlabel('Repeated trials of uniform noise');
    elseif fig_id == 2
        xlabel('Repeated trials of Gaussian noise');
    else
        xlabel('Fundamental frequency of input (log2 scale)');
    end
    ylabel('Output-to-input energy ratio');
    grid();
end
    
%%
set(gcf, 'Color', 'w');
export_fig("kymatio21_energy_conservation.png", "-m4", "-transparent");