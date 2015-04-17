============
Introduction
============

Originated in 2010 by Stéphane Mallat as "Recursive Interferometry" [Mal10]_, the scattering representation aims at providing robust mid-level features for signal-based machine learning.

It relies on the idea that an ideal representation for classification should verify the three following criteria:

1. **Invariance** to translation: if the signal gets globally translated, the representation should not change.
2. **Stability** to small elastic deformations: if the signal get deformed, the representation should be deformed in a proportional way.
3. **Discriminability**: signals in different classes should be represented differently.

Below is an informal review of the capacities of different signal descriptors in terms of these criteria.

+----------------------------+-----------+--------+----------------+
|                            | Invariant | Stable | Discriminative |
+============================+===========+========+================+
| the signal itself          |           |        | ★ ★ ★          |
+----------------------------+-----------+--------+----------------+
| moving average             | ★ ★       | ★ ★ ★  |                |
+----------------------------+-----------+--------+----------------+
| Fourier transform modulus  | ★ ★ ★     |        | ★              |
+----------------------------+-----------+--------+----------------+
| wavelet transform modulus  |           | ★      | ★ ★ ★          |
+----------------------------+-----------+--------+----------------+
| constant-Q transform, MFCC | ★         | ★ ★ ★  | ★              |
+----------------------------+-----------+--------+----------------+
| scattering transform       | ★ ★       | ★ ★ ★  | ★ ★            |
+----------------------------+-----------+--------+----------------+

Invariance and stability can easily be achieved by averaging the signal over time, at the cost of a poor discriminability.
Conversely, the modulus of the wavelet transform (called *scalogram*) is stable and discriminative, yet not invariant to translation.
The classical constant-Q transform is equivalent to averaging the scalogram over uniform windows : that is a gain in invariance, yet a loss in discriminability.
The rationale behing the scattering transform is to compensate for this averaging by recovering the fast variations in the scalogram as well. This is handled by means of another wavelet transform, so as to guarantee a good property of stability.

.. [Mal10] Mallat, S. Recursive interferometric representations. in European Signal Processing Conference 716–720 (2010).
