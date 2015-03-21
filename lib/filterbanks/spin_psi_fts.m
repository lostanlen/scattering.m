function spinned_psi_fts = spin_psi_fts(raw_psi_fts,signal_dimension)
%% Sizing
raw_sizes = size(raw_psi_fts);

%% Spinning
switch signal_dimension
    case 1
        %% 1D case: spinning is merely a right-to-left copy and conjugation
        spinned_psi_fts = zeros([raw_sizes,2]);
        spinned_psi_fts(:,:,1) = raw_psi_fts;
        spinned_psi_fts(1,:,2) = conj(raw_psi_fts(1,:,1));
        spinned_psi_fts(2:end,:,2) = conj(raw_psi_fts(end:-1:2,:,1));
    case 2
        %% 2D case: spinning is a central Hermitian symmetry.
        % We half-turn 2D frequencies whose both components are nonzero.
        nOrientations = size(raw_psi_fts,4);
        spinned_psi_fts = zeros([raw_sizes(1:3),2*nOrientations]);
        spinned_psi_fts(:,:,1:nOrientations) = raw_psi_fts;
        for orientation_index = 1:nOrientations
            theta = orientation_index;
            theta_symmetric = orientation_index + nOrientations;
            spinned_psi_fts(1,:,:,theta_symmetric) = ...
                conj(raw_psi_fts(1,:,:,theta));
            spinned_psi_fts(:,1,:,theta_symmetric) = ...
                conj(raw_psi_fts(:,1,:,theta));
            spinned_psi_fts(2:end,2:end,:,theta_symmetric) = ...
                conj(rot90(raw_psi_fts(2:end,2:end,:,theta),2));
        end
    otherwise
        error('filter spinning only available for 1D and 2D');
end
end
