import datetime
import numpy as np
import pickle
import scipy.io
import scipy.stats
import sklearn.decomposition
import sklearn.ensemble
import sklearn.linear_model
import sklearn.metrics
import sklearn.preprocessing

np.set_printoptions(precision=2)

for modulation in ['time', 'timefrequency', 'spiral']:
    for wavelet in ['morlet', 'gammatone', 'mixed']:
        for selection in [False, True]:
            for compression in [False, True]:
                method_str = modulation + "_" + wavelet
                if selection:
                    method_str + "_selection"
                if compression:
                    method_str + "_compression"
                print method_str

                # Load
                print(datetime.datetime.now().time().strftime('%H:%M:%S') +
                    " Loading")
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
                if selection:
                    print(datetime.datetime.now().time().strftime('%H:%M:%S') +
                        " Selection")
                    energies = X_training * X_training
                    feature_energies = np.mean(X_training, axis=0)
                    feature_energies /= np.sum(feature_energies)
                    sorting_indices = np.argsort(feature_energies)
                    sorted_feature_energies = feature_energies[sorting_indices]
                    cumulative = np.cumsum(sorted_feature_energies)
                    start_feature = np.where(cumulative > 0.10)[0][0]
                    dominant_indices = sorting_indices[start_feature:]
                    X_training = X_training[:, dominant_indices]
                    X_test = X_test[:, dominant_indices]

                # Log transformation
                if compression:
                    print(
                        datetime.datetime.now().time().strftime('%H:%M:%S') +
                        " Compression")
                    X_training = np.log(1e-16 + X_training)
                    X_test = np.log(1e-16 + X_test)

                # Standardize features
                print(datetime.datetime.now().time().strftime('%H:%M:%S') +
                    " Standardization")
                scaler = sklearn.preprocessing.StandardScaler().fit(X_training)
                X_training = scaler.transform(X_training)
                X_test = scaler.transform(X_test)
                report = []
                output_file = open('mdb' + method + 'svm_y.pkl', 'wb')
                pickle.dump(report, output_file)
                output_file.close()

                # Train linear SVM
                print(datetime.datetime.now().time().strftime('%H:%M:%S') +
                    " Training")
                clf = sklearn.svm.LinearSVC(class_weight="balanced")
                clf.fit(X_training, Y_training)

                # Predict and evaluate average miss rate
                print(datetime.datetime.now().time().strftime('%H:%M:%S') +
                    " Evaluation")
                Y_training_predicted = clf.predict(X_training)
                Y_test_predicted = clf.predict(X_test)
                average_recall = sklearn.metrics.recall_score(
                    Y_test, Y_test_predicted, average="macro")
                average_miss_rate = 1.0 - average_recall
                print "Average miss rate = " + str(100 * average_miss_rate)
                print ""
                dictionary = {
                    'average_miss_rate': average_miss_rate,
                    'C': 1e3,
                    'compression': compression,
                    'method_str': method_str,
                    'selection': selection,
                    'Y_test': Y_test,
                    'Y_test_predicted': Y_test_predicted,
                    'Y_training': Y_training,
                    'Y_training_predicted': Y_training_predicted}
                output_file = open(method_str + '.pkl', 'wb')
                pickle.dump(dictionary, output_file)
                output_file.close()
