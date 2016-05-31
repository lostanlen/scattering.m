import datetime
import numpy as np
import pickle
import scipy.io
import scipy.stats
import sklearn.decomposition
import sklearn.ensemble
import sklearn.metrics
import sklearn.preprocessing

np.set_printoptions(precision=2)

method = 'joint'

# Load
print("Loading")
mat = scipy.io.loadmat("mdb" + method + ".mat")
data = mat["mdb" + method + "_data"]

X_training = data["X_training"][0][0]
X_validation = data["X_validation"][0][0]
X_test = data["X_test"][0][0]

Y_training = np.ravel(data["Y_training"][0][0])
Y_validation = np.ravel(data["Y_validation"][0][0])
Y_test = np.ravel(data["Y_test"][0][0])

X_training = np.concatenate((X_training, X_validation))
Y_training = np.concatenate((Y_training, Y_validation))

# Discard features with less than 10% of the energy
print("Selection")
energies = X_training * X_training
feature_energies = np.mean(X_training, axis=0)
feature_energies /= np.sum(feature_energies)
sorting_indices = np.argsort(feature_energies)
sorted_feature_energies = feature_energies[sorting_indices]
cumulative = np.cumsum(sorted_feature_energies)
start_feature = np.where(cumulative > 0.10)[0][0]
dominant_indices = sorting_indices[start_feature:]

X_training = X_training[:, dominant_indices]
X_validation = X_validation[:, dominant_indices]
X_test = X_test[:, dominant_indices]


# Box-Cox power transformation. Lambda is estimated by maximum likelihood
print("Compression")
lambdas = []
for feature_id in range(len(dominant_indices)):
    X_training[:, feature_id], lambda_ =\
        scipy.stats.boxcox(X_training[:, feature_id])
    X_validation[:, feature_id] =\
        scipy.stats.boxcox(X_validation[:, feature_id], lambda_)
    X_test[:, feature_id] =\
        scipy.stats.boxcox(X_test[:, feature_id], lambda_)
    lambdas.append(lambda_)


# Standardize features
print("Standardization")
scaler = sklearn.preprocessing.StandardScaler().fit(X_training)
X_training = scaler.transform(X_training)
X_test = scaler.transform(X_test)

report = []
output_file = open('mdb' + method + 'svm_y.pkl', 'wb')
pickle.dump(report, output_file)
output_file.close()

for C in [1e3]:
    for gamma in [0.5]:
        print(C, gamma)
        print("Training")
        print datetime.datetime.now().time()
        clf = sklearn.svm.LinearSVC(C=C, class_weight="balanced")
        clf.fit(X_training, Y_training)
        print("Evaluation")
        Y_training_predicted = clf.predict(X_training)
        Y_test_predicted = clf.predict(X_test)
        dictionary = {'C': C,
            'Y_test': Y_test,
            'Y_test_predicted': Y_test_predicted,
            'Y_training': Y_training,
            'Y_training_predicted': Y_training_predicted}
        Y_training = dictionary["Y_training"]
        Y_training_predicted = dictionary["Y_training_predicted"]
        Y_test = dictionary["Y_test"]
        Y_test_predicted = dictionary["Y_test_predicted"]
        print(sklearn.metrics.classification_report(Y_training, Y_training_predicted))
        print(sklearn.metrics.classification_report(Y_test, Y_test_predicted))
