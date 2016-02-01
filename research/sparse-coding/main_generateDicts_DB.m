%load data set and learn the dictionaries

%disp('Generating data from all instruments')
%[Y,initnLambda]=generate_allInstrumentsDb();
%disp('save DB')
%save('../../../../data/allInstrumentsDB_3secs.mat','Y','initnLambda');
load('../../../../data/allInstrumentsDB_3secs.mat');
%% Compute the dictionaries

k_dim_coeff = 3;%percentage of dim that we want for the atoms of the dictionary
disp(['Learn the dictionaries:'])
dicts = learn_Dictionaries(Y,6,k_dim_coeff);
save('../../../../data/Dictionary_overcomplete.mat','dicts');
disp('.. and saving dictionaries ')
