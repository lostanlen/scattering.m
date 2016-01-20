dataset_path = '~/datasets/medleydb-single-instruments';

%%
training_path = [dataset_path, '/', 'training'];
class_dirs = dir(training_path);
class_names = {class_dirs.name};