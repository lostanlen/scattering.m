function [ren_S, S] = sc_propagate_renorm(signal, archs)
nLayers = length(archs) - 1;

%% Layer 1 scattering
U0 = initialize_U(signal, archs{1}.banks{1});
Y1 = U_to_Y(U0, archs{1}.banks);
U1 = Y_to_U(Y1{end},archs{1}.nonlinearity);
S0 = Y_to_S(Y1, archs{1});
S0 = unchunk_layer(S0);

switch nLayers
    case 1
        % Layer 1 averaging
        Y2{1+0} = initialize_Y(U1, archs{1}.banks);
        S1 = Y_to_S(Y2, archs{1});
    case 2
        % Layer 2 scattering
        Y2 = U_to_Y(U1, archs{2}.banks);
        % Layer 1 averaging
        S1 = Y_to_S(Y2, archs{2});
end

%% Layer 1 unchunking
if iscell(S1) % summed invariant
    S1 = unchunk_layer(S1{1});
else % blurred invariant
    S1 = unchunk_layer(S1);
end

%% Layer 1 renormalization
Uabs0 = initialize_U(abs(signal),archs{1}.banks{1});
Yabs1{1+0} = initialize_Y(Uabs0, archs{1}.banks);
Sabs0 =  Y_to_S(Yabs1, archs{1});
Sabs0 = unchunk_layer(Sabs0);

ren_S1 = S1;
if iscell(S1.data) % summed invariant
    nNodes = numel(S1.data);
    for node_index = 1:nNodes
        ren_S1.data{node_index} = bsxfun(@rdivide, ...
            S1.data{node_index}, eps() + max(Sabs0.data, 0));
    end
else
    ren_S1.data = bsxfun(@rdivide, ren_S1.data, eps() + max(Sabs0.data, 0));
end

%%
if nLayers == 1
    ren_S = {Sabs0, ren_S1};
    S = {S0, S1};
elseif nLayers == 2
    %% Layer 2 modulus and averaging
    U2 = Y_to_U(Y2{end}, archs{2}.nonlinearity);
    Y3{1+0} = initialize_Y(U2, archs{1}.banks);
    S2 = Y_to_S(Y3, archs{2});
    S2 = unchunk_layer(S2);
    %% Layer 2 renormalization
    ren_S2 = S2;
    % gamma1 has subscript 2 in S1 after unchunking
    gamma1_in_S1_subscript = 2;
    % gamma1 has subscript 2 in S2 after unchunking
    gamma1_in_S2_subscript = 2;
    nSubscripts = size(S1.ranges{1}, 2);
    subsref_structure = substruct('()', replicate_colon(nSubscripts));
    for gamma2_index = 1:length(S2.data)
        node_S2 = S2.data{gamma2_index};
        gamma1_range = S2.ranges{1}{gamma2_index}(:, gamma1_in_S2_subscript);
        range_length = gamma1_range(end) - gamma1_range(1) + 1;
        subsref_structure.subs{gamma1_in_S1_subscript} = 1:range_length;
        node_S1 = subsref(S1.data, subsref_structure);
        ren_S2.data{gamma2_index} = bsxfun(@rdivide, ...
            node_S2, (eps() + max(node_S1, 0)));
    end
    ren_S = {Sabs0, ren_S1, ren_S2};
    S = {S0, S1, S2};
end
end

