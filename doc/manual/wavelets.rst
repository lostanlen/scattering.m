========
Wavelets
========

In order to build a wavelet filter bank, one starts from a single bandpass filter :math:`\psi(t)` named the *mother wavelet*.
Then, one has to contract :math:`\psi(\omega)` in the Fourier domain by scaling factors :math:`2^{\gamma}\geq1` to derive a bank of band pass filters :math:`\widehat{\psi_{\gamma}}(\omega)` for different values of :math:`\gamma`:

.. math::

	\widehat{\psi_{\gamma}}(\omega) = \hat{\psi}(2^{\gamma} \omega).

In the time domain, the above is equivalent to

.. math::

	\psi_{\gamma}(t) = 2^{-\gamma} \psi(2^{-\gamma} t).

In this section, we review three posssible shapes for the mother wavelet :math:`\psi`:
1. The Morlet wavelet `morlet_1d`
2. The Gammatone wavelet `gammatone_1d`
3. The RLC wavelet (causal with exponential decay) `RLC_1d`

The default specifications are: Morlet 


Morlet wavelet
--------------

The ubiquitous Morlet wavelet, also named Gabor wavelet, is proved to have optimal time-frequency Heisenberg uncertainty (see Mallat's wavelet tour [Mal08]_, Theorem 2.6). It is defined as the product of a Gaussian bell curve of variance :math:`\sigma` by a sine wave of frequency :math:`\xi`. 

.. math::

	\psi(t) = \exp\left( - \dfrac{t^2}{2 \sigma^2} \right) \times \exp(2\mathrm{i} \pi \xi t)+ \varepsilon(t)

The function :math:`\varepsilon(t)` is a low-frequency corrective term to ensure that the wavelet :math:`\psi(t)` has zero mean. Remarkably, the Morlet wavelet also has a Gaussian profile in the frequency domain.

.. math::

	\hat{\psi}(\omega) = \sigma \exp(- \sigma^2 \omega^2) + \hat{\varepsilon}(\omega)

Since the Gaussian bell curve is symmetric, the Morlet wavelet transform modulus not sensitive to reversal of the :math:`t` axis. Yet, our perception of time is strongly asymmetric : therefore, for second-order auditory scattering along time, one should prefer the asymmetric Gammatone wavelet (see below) instead of the Morlet wavelet. The Morlet wavelet is well suited to transforms along log-scales :math:`\gamma`.

When performing a joint time-frequency transform or spiral transform, the Morlet wavelet handle `morlet_1d` is the default for the transform along log-scales :math:`\gamma`. In many cases, it is sensible to use it for transforms along time as well. Aside from the quality factor, it does not have any specific parameter.


Gammatone wavelet
-----------------

Because of their temporal asymmetry and near-optimal uncertainty properties, Gammatone filters are widely used in auditory models. They are defined as the product of a monomial of degree :math:`N`, an exponential decay of attenuation :math:`\alpha`, and a sine wave of frequency :math:`\xi`.

We define a Gammatone wavelet by taking the first derivative of the Gammatone function, and replacing the :math:`\sin(2\pi \xi t)` by :math:`\exp(2\mathrm{i} \pi \xi t)`. By doing this, we ensure that the resulting function has zero mean and is analytic (see Venkitaraman et al. [VAS14]_). The expression of the Gammatone wavelet in the time domain is:

.. math::

	\psi(t) =
	\left((-\alpha + \mathrm{i} \xi) t^{N-1} +
	(N-1) t^{N-2}\right) \exp(-\alpha t) \times \exp(2\mathrm{i} \pi \xi t) 

In the Fourier domain:

.. math::

	\hat{\psi}(\omega) = \dfrac{\mathrm{i}\omega \times (N-1)!}{\left(\alpha + \mathrm{i} (\omega - 2 \pi \xi)\right)^N}

Observe that, by this definition, the wavelet modulus :math:`\vert\psi(t)\vert` reaches its maximum *after* :math:`t=0`. In practice, we translate the resulting function in time in order to match the peak at exactly :math:`t=0`. We also add a phase term such that the real part also reaches its maximum at exactly :math:`t=0`.

The integer :math:`N`, called ``gammatone_order`` in the specifications, is equal to :math:`4` by default. The bigger the :math:`N`, the more symmetric (hence "Morlet-like") the wavelet will be. The attenuation parameter :math:`\alpha` is automatically inferred from the required quality factor, through a tedious closed-form equation.

RLC wavelet
-----------

A RLC circuit consists of a resistor R, an inductor L and a capacitor C. In an underdamped regime, the response of this circuit is a sine wave with an exponentially decaying profile. By setting the phase shift :math:`\varphi` to zero and taking the analytic part, we derive an analytic "RLC wavelet" of attenuation :math:`\alpha` and center frequency :math:`\xi`.

.. math::

	\psi(t)=\left\{ \begin{array}{c}
			\exp(-\alpha t)\times\exp(2\mathrm{i}\xi t)\text{ if }t\geq0\\
			0 \text{ otherwise}
			\end{array}\right.
 

This wavelet is rigorously causal (it is zero for :math:`t<0`) and has a very fast decay in time, at the cost of an imprecise localization in frequency. These properties makes it adapted to wavelet transform across octaves, in the case of spiral scattering.

As much as the Gammatone wavelet is the product of a Gamma probability density function by a sine wave, the RLC wavelet is the product of a Poisson density function by a sine wave. Consequently, the RLC wavelet could alternatively be named "Poisson wavelet". The attenuation parameter :math:`\alpha` is automatically inferred from the required quality factor, through the simple equation

.. math::
	\alpha = \dfrac{\xi}{2Q}.

RLC wavelets are the default when transforming across octaves in a spiral scattering transform. Aside from the quality factor, it does not have any specific parameter.

.. [Mal08] S. Mallat, A Wavelet Tour of Signal Processing, Third Edition: The Sparse Way, 3rd ed. Academic Press, 2008, p. 832.
.. [VAS14] A. Venkitaraman, A. Adiga, and C. S. Seelamantula, “Auditory-motivated Gammatone wavelet transform,” Signal Processing, vol. 94, pp. 608–619, 2014.
