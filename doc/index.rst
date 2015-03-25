.. Scattering.m documentation master file, created by
   sphinx-quickstart on Sat Mar  7 14:24:24 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

%%%%%%%%%%%%%%
 Scattering.m
%%%%%%%%%%%%%%

Filter bank specifications
--------------------------

Length of the input signal (compulsory)
+++++++++++++++++++++++++++++++++++++++
Before running ``sc_setup``, it is compulsory so fill the ``size`` field with

::

	opts{1}.time.size = length(signal);

It must be a power of 2, which leads to optimally fast Fourier Transforms.
If you have ``K`` signals of the same size ``N``, consider stacking them into a ``KxN`` matrix. This wil automatically vectorize the computation and avoid high-level loop overhead.

Under development is a more general architecture that automates padding to the next power of 2, and adapts to all sizes.


Amount of invariance to translation
+++++++++++++++++++++++++++++++++++
The integer ``T`` is the amount of invariance to translation that you require. It must also be a power of 2.

A typical value for second-order scattering of audio is ``T=8192``, that is 370 ms at a sample rate of 22 kHz. A smaller ``T`` will not integrate full musical notes or full phonemes ; on the contrary, a bigger ``T`` will blur different notes/phonemes together.

The number of octaves in the filter bank is equal to ``J = log2(T)``.
By default, ``T`` is set equal to ``size`` which means that the corresponding scattering representation ``S`` will be fully translation-invariant.

Quality factor
++++++++++++++
The quality factor ``max_Q`` of a band-pass filter is defined as the ratio of its center frequency by its bandwidth. Consequently, for a given center frequency, increasing the quality factor will decrease the bandwidth proportionnally, hence yielding a "sharper" band-pass filter in the frequency domain. This increase in frequency sharpness comes at the cost of increasing the support of the filter in the time domain, which may prevent the representation to distinguish consecutive events.

All the wavelets in a filter bank share the same quality factor: this is why we refer to it as a constant-Q filter bank. Note that this toolbox also allows variable-Q filter banks in order to cope with time support limitations (see section below). This is why the quality factor is ``max_Q``.

Typical values for the first order in audio range from 4 to 16.
Typical values for the second order along time are 1 or 2. 
In the context of multivariable scattering, the value 1 is strongly recommended for any derived variable.

A quality factor of 1, corresponding to the so-called 'dyadic' filter bank, is the default.


Maximum scale
+++++++++++++
Note that a potential drawback of the constant-Q filterbank is that the time support of the filters is unbounded at the low frequencies. In audio, it is undesirable that acoustic events more than 100 ms apart fall between the same first-order time bin. To address this issue, this toolbox provides a bound ``max_scale`` that restricts the time support, at the cost of decreasing locally the quality factor.

For instance, for ``max_Q = 12`` and a sample rate of 22 kHz, setting ``max_scale = 2048`` (about 93 ms) will provide constant-Q filters for frequencies above Q/max_scale (about 130 Hz) and constant-bandwidth filters below that limit.
Setting ``max_scale = Inf`` will remove the upper bound on the time support and will guarantee that the quality factor is indeed constant throughout the whole frequency range.

By default, ``max_scale`` is set to ``size``, which means that the time support is only limited by the size of the whole signal.


Number of filters per octave
++++++++++++++++++++++++++++
The integer ``nFilters_per_octave`` specified the rational quantization of the ``gamma`` log-scale variable. In order to cover the whole frequency axis, it is compulsory to have

::

	nFilters_per_octave > max_Q

The number of filters in the filter bank is equal to ``nFilters_per_octave * log2(T)``. Henceforth, note that the computational complexity of the computation is linear in the number of filters per octave of each filter bank.



Wavelet specifications
----------------------

Morlet wavelet
++++++++++++++

The ubiquitous Morlet wavelet, also named Gabor wavelet, is proved to have optimal time-frequency Heisenberg uncertainty (see Mallat's wavelet tour, Theorem 2.6). It is defined as the product of a Gaussian bell curve of variance :math:`\sigma` by a sine wave of frequency :math:`\xi`. 

.. math::

	\psi(t) = \exp\left( - \dfrac{t^2}{2 \sigma^2} \right) \times \exp(2\mathrm{i} \pi \xi t)+ \varepsilon(t)

The function :math:`\varepsilon(t)` is a low-frequency corrective term to ensure that the wavelet :math:`\psi(t)` has zero mean. Remarkably, the Morlet wavelet also has a Gaussian profile in the frequency domain.

.. math::

	\hat{\psi}(\omega) = \sigma \exp(- \sigma^2 \omega^2) + \hat{\varepsilon}(\omega)

Since the Gaussian bell curve is symmetric, the Morlet wavelet transform modulus not sensitive to reversal of the :math:`t` axis. Yet, our perception of time is strongly asymmetric : therefore, for second-order auditory scattering along time, one should prefer the asymmetric Gammatone wavelet (see below) instead of the Morlet wavelet. The Morlet wavelet is well suited to transforms along log-scales :math:`\gamma`.

Gammatone wavelet
+++++++++++++++++

Because of their temporal asymmetry and near-optimal uncertainty properties, Gammatone filters are widely used in auditory models. They are defined as the product of a monomial of degree :math:`N`, an exponential decay of attenuation :math:`\alpha`, and a sine wave of frequency :math:`\xi`.

We define a Gammatone wavelet by taking the first derivative of the Gammatone function, and replacing the :math:`\sin(2\pi \xi t)` by :math:`\exp(2\mathrm{i} \pi \xi t)`. By doing this, we ensure that the resulting function has zero mean and is analytic (see Venkitaraman et al. 2013). The expression of the Gammatone wavelet in the time domain is:

.. math::

	\psi(t) =
	\left((-\alpha + \mathrm{i} \xi) t^{N-1} +
	(N-1) t^{N-2}\right) \exp(-\alpha t) \times \exp(2\mathrm{i} \pi \xi t) 


In the Fourier domain:

.. math::

	\hat{\psi}(\omega) = \dfrac{\mathrm{i}\omega \times (N-1)!}{\left(\alpha + \mathrm{i} (\omega - 2 \pi \xi)\right)^N}


The way to derive the attenuations :math:`\alpha` from the required quality factors is documented inside the code.

Observe that, by this definition, the wavelet modulus :math:`\vert\psi(t)\vert` reaches its maximum *after* :math:`t=0`. In practice, we translate the resulting function in time in order to match the peak at exactly :math:`t=0`. We also add a phase term such that the real part also reaches its maximum at exactly :math:`t=0`.

RLC wavelet
+++++++++++

A RLC circuit consists of a resistor R, an inductor L and a capacitor C. In an underdamped regime, the response of this circuit is a sine wave with an exponentially decaying profile. By setting the phase shift :math:`\varphi` to zero and taking the analytic part, we derive an analytic "RLC wavelet" of attenuation :math:`\alpha` and center frequency :math:`\xi`.

.. math::

	\psi(t)=\left\{ \begin{array}{c}
			\exp(-\alpha t)\times\exp(2\mathrm{i}\xi t)\text{ if }t\geq0\\
			0 \text{ otherwise}
			\end{array}\right.
 

This wavelet is rigorously causal (it is zero for :math:`t<0`) and has a very fast decay in time, at the cost of an imprecise localization in frequency. These properties makes it adapted to wavelet transform across octaves, in the case of spiral scattering.

As much as the Gammatone wavelet is the product of a Gamma probability density function by a sine wave, the RLC wavelet is the product of a Poisson density function by a sine wave. Consequently, the RLC wavelet could alternatively be named "Poisson wavelet".

.. * :ref: 'manual'
.. * :ref: 'devdocs'


.. toctree:
..   :maxdepth: 1

.. Planned outline for user's doc
.. toctree:
..  :maxdepth: 1
.. manual/introduction
.. manual/audio
.. manual/display
.. manual/extraction
.. manual/reconstruction

.. Planned outline for developer's doc
.. toctree:
..  :maxdepth: 1
..   devdocs/overview
..   devdocs/variables
..   devdocs/
