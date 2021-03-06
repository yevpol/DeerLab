.. highlight:: python
.. _dd_shellsphere:


************************
:mod:`dd_shellsphere`
************************

.. autofunction:: deerlab.dd_models.dd_shellsphere

Model
=========================================

.. image:: ../images/model_scheme_dd_sphereshell.png
   :width: 25%

:math:`P(r) = \frac{3}{16R_1^3(R_2^3 - R_1^3)}\begin{cases} 12r^3R_1^2 - r^5  \quad \text{for} \quad 0\leq r < \min(2R_1,R_2 - R_1) \\ 8r^2(R_2^3 - R_1^3) - 3r(R_2^2 - R_1^2)^2 - 6r^3(R_2 - R_1)(R_2 + R_1) \quad \text{for} \quad R_2-R_1 \leq r < 2R_1 \\ 16r^2R_1^3 \quad \text{for} \quad 2R_1\leq r < R_2 - R_1  \\  r^5 - 6r^3(R_2^2 + R_1^2) + 8r^2(R_2^3 + R_1^3) - 3r(R_2^2 - R1_2)^2 \quad \text{for} \quad \max(R_2-R_1,2R_1) \leq r < R_1+R_2 \\ 0 \quad \text{for} \quad \text{otherwise}  \end{cases}`

with 

:math:`R_1 = R`

:math:`R_2 = R + w_1`


============== ============== ============= ============= ============= =========================
 Variable         Symbol       Start Value   Lower bound   Upper bound      Description
============== ============== ============= ============= ============= =========================
``param[0]``     :math:`R`       1.5             0.1            20         Sphere radius (nm)
``param[1]``     :math:`w`       0.5             0.1            20         Shell thickness (nm)
============== ============== ============= ============= ============= =========================


Example using start values:

.. image:: ../images/model_dd_shellsphere.png
   :width: 650px

References
=========================================

[1] D.R. Kattnig, D. Hinderberger, Journal of Magnetic Resonance, 230 (2013), 50-63.
`DOI:  10.1016/j.jmr.2013.01.007 <http://doi.org/10.1016/j.jmr.2013.01.007>`_