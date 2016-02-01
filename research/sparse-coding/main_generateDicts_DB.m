disp('Generating data from all instruments')
pathUrban = '~/data/UrbanSound8K/training/';

[Y,initnLambda]=generate_DB_frompath(pathUrban);
disp('save DB')
save('../../../../data/allUrban.mat','Y','initnLambda');

%save('../../../../data/allInstrumentsDB_3secs.mat','Y','initnLambda');
%% Compute the dictionaries

k_dim_coeff = 1;%percentage of dim that we want for the atoms of the dictionary
disp(['Learn the dictionaries:'])
dicts = learn_Dictionaries(Y,1,k_dim_coeff);
save('../../../../data/Dictionary_Urban.mat',dicts);

return



% d = dir('./training/')
% P = randperm(size(d,1));
% 
% for i=1:3000
%     system(['mv ./training/' d(P(i)).name ' ./testing/.' ]);
% end 