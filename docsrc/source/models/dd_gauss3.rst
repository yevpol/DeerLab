.. highlight:: python
.. _dd_gauss3:


************************
:mod:`dd_gauss3`
************************

.. autofunction:: deerlab.dd_models.dd_gauss3

Model
=========================================

:math:`P(r) = a_1\sqrt{\frac{2}{\pi}}\frac{1}{\sigma_1}\exp\left(-\frac{(r-\left<r_1\right>)^2}{\sigma_1^2}\right) + a_2\sqrt{\frac{2}{\pi}}\frac{1}{\sigma_2}\exp\left(-\frac{(r-\left<r_2\right>)^2}{\sigma_2^2}\right) + a_3\sqrt{\frac{2}{\pi}}\frac{1}{\sigma_3}\exp\left(-\frac{(r-\left<r_3\right>)^2}{\sigma_3^2}\right)`

============== ========================== ============= ============= ============= =======================================
 Variable         Symbol                   Start Value   Lower bound   Upper bound      Description
============== ========================== ============= ============= ============= =======================================
``param[0]``     :math:`\left<r_1\right>`     2.5           1.0           20         1st Gaussian mean distance (nm)
``param[1]``     :math:`\sigma_1`             0.2           0.05          2.5        1st Gaussian standard deviation (nm)
``param[2]``     :math:`a_1`                  0.3           0             1          1st Gaussian amplitude
``param[3]``     :math:`\left<r_2\right>`     3.5           1.0           20         2nd Gaussian mean distance (nm)
``param[4]``     :math:`\sigma_2`             0.2           0.05          2.5        2nd Gaussian standard deviation (nm)
``param[5]``     :math:`a_2`                  0.3           0             1          2nd Gaussian amplitude
``param[6]``     :math:`\left<r_3\right>`     5.0           1.0           20         3rd Gaussian mean distance (nm)
``param[7]``     :math:`\sigma_3`             0.2           0.05          2.5        3rd Gaussian standard deviation (nm)
``param[8]``     :math:`a_3`                  0.3           0             1          3rd Gaussian amplitude
============== ========================== ============= ============= ============= =======================================


Example using the start values:

.. image:: ../images/model_dd_gauss3.png
   :width: 650px
