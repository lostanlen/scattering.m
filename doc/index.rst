.. Scattering.m documentation master file, created by
   sphinx-quickstart on Sat Mar  7 14:24:24 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

%%%%%%%%%%%%%%
 Scattering.m
%%%%%%%%%%%%%%


A minimal script to run the toolbox is the following:

.. doctest::

    opts{1}.time.size = size(signal,1);
    archs = setup(opts);
    [S,U,Y] = propagate(signal,archs);

The only compulsory field in ``opts`` is ``size``, the number of samples in ``signal`.


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
