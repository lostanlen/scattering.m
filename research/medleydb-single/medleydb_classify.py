import datetime
import numpy as np
import pickle
import scipy.io
import sklearn.decomposition
import sklearn.ensemble
import sklearn.metrics
import sklearn.preprocessing

np.set_printoptions(precision=2)

method = 'plain'

# Load
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

# Discard features with less than 1% of the variance
# Without it, performance drops from 81% to 65%
# variances = np.var(X_training, axis=0)
# variances /= np.sum(variances)
# negative_variances = - variances
# sorting_indices = np.argsort(negative_variances)
# sorted_variances = variances[sorting_indices]
# cumulative_variances = np.cumsum(sorted_variances)
#
# n_features = np.where(cumulative_variances > 0.99)[0][0]
# dominant_indices = sorting_indices[:n_features]
#
# X_training = X_training[:, dominant_indices]
# X_validation = X_validation[:, dominant_indices]
# X_test = X_test[:, dominant_indices]

# Logarithmic transformation
# Without it, performance drops from 81% to 69%
medians = np.median(X_training, axis=0)[np.newaxis, :]
log1p_denominators = 1e-2 * medians
X_training = np.log1p(X_training / log1p_denominators)
X_test = np.log1p(X_test / log1p_denominators)

# Standardize features
# With it, performance goes from 81% to 82%
scaler = sklearn.preprocessing.StandardScaler().fit(X_training)
X_training = scaler.transform(X_training)
X_validation = scaler.transform(X_validation)
X_test = scaler.transform(X_test)

Cs = [1e2]
report = []
output_file = open('mdb' + method + 'svm_y.pkl', 'wb')
pickle.dump(report, output_file)
output_file.close()

for C in Cs:
    print(C)
    print datetime.datetime.now().time()
    clf = sklearn.svm.LinearSVC(C=C, class_weight="balanced")
    clf.fit(X_training, Y_training)
    Y_training_predicted = clf.predict(X_training)
    Y_test_predicted = clf.predict(X_test)
    dictionary = {'C': C,
        'Y_test': Y_test,
        'Y_test_predicted': Y_test_predicted,
        'Y_training': Y_training,
        'Y_training_predicted': Y_training_predicted}
    output_file = open('mdb' +  method +  '_svm_y.pkl', 'wb')
    report.append(dictionary)
    pickle.dump(report, output_file)
    output_file.close()

i = 0
dictionary = report
Y_training = dictionary[i]["Y_training"]
Y_training_predicted = dictionary[i]["Y_training_predicted"]
Y_test = dictionary[i]["Y_test"]
Y_test_predicted = dictionary[i]["Y_test_predicted"]
print(dictionary[i]["C"])
print(sklearn.metrics.classification_report(Y_training, Y_training_predicted))
print(sklearn.metrics.classification_report(Y_test, Y_test_predicted))
