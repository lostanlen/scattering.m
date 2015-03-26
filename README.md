# Scattering.m
### a MATLAB toolbox for signal scattering

Scattering representations are based on nonlinear transforms which are invariant to translation and stable to deformations, yet remaining highly discriminative.

## Usage

Suppose you have a ``signal`` sampled at rate ``Fs``. Choose a quality factor (number of frequency bins per octave) ``Q`` and run ``default_auditory`` to get started with a time-frequency representation called scalogram, that is, wavelet transform modulus.

```matlab
Q = 8; % typical values for quality factor in audio are 8, 12 or 16
opts{1} = default_auditory(length(signal),Fs,Q);

```

A scattering architecture adds a second layer of wavelet transform on top of the scalogram. This toolbox provides the ability to perform scattering along time (a.k.a. amplitude modulation spectrum), but also joint time-frequency scattering (introduced by Joakim Andén) and spiral scattering (introduced by Vincent Lostanlen).

```matlab
% This line provides default options for scattering along time
opts{2}.time = struct();
% Uncomment this line to enable joint time-frequency scattering
% opts{2}.gamma = struct(); % gamma is the log-frequency variable
% Uncomment this line to enable spiral scattering
% opts{3}.j = struct(); % j is the octave variable
```

Run ``sc_setup`` to build the scattering architectures, which consist of filter banks and a nonlinearity (complex modulus by default). Then run ``sc_propagate`` to compute the scattering coefficients.

```matlab
archs = sc_setup(opts);
S = sc_propagate(signal,archs);
```

If you want to change the default behavior, add specific fields to the empty structures in ``opts``. See the documentation for available parameters.

## Install

First, acquire the source code by cloning the git repository:

```shell
git clone git://github.com/lostanlen/scattering.m.git
```

Now, start MATLAB and add the toolbox to your local path:

```matlab
addpath(genpath('path/to/scattering.m/lib'))
```

and start calling ``sc_setup`` and ``sc_propagate`` on your signals.

## Documentation
Documentation can be browsed on [Read The Docs](http://scatteringm.readthedocs.org/en/latest).


## License and contact
All files in the Scattering.m toolbox are licensed under the GNU GPL v3, of which you can find a copy [here](https://github.com/lostanlen/scattering.m/blob/master/LICENSE.md).
The toolbox is ran by Vincent Lostanlen, a PhD student in the team of Stéphane Mallat at École normale supérieure in Paris. Ideas for academic collaboration are welcome.
