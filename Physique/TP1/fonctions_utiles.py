"""
Des fonctions usuelles utiles
"""
from random import uniform
import numpy as np


def monte_carlo(fn, *args, N=5000):
    """
    Une version généralisée de monte-carlo

    Exemple d'utilisation:
        result = list(monte_carlo(lambda a, b: sin(a) * sin(b), (3, 0.5), (5, 0.3)))
    Ici, a vaudra 3 +/- 0.5 et b vaudra 5 +/- 0.3
    Un générateur de toutes les valeurs résultantes sera retourné

    :param: fn Une fonction, qui utilisera les paramètres (simulés)
    :param: *args Une suite d'argument de la forme (valeur, delta), qui seront utilisés dans le même ordre dans la fonction
    :param: N Le nombre de simulation par argument
    :return: Generator Un itérateur des résultats
    """
    yield from (fn(*(uniform(e - delta, e + delta) for e, delta in args)) for i in range(N))


def euler(f, t0, y0, tmax, h):
    """
    Une version de la méthode d'Euler pour résoudre une équation différentielle
    
    :param: f La fonction de dérivée de l'équation différentielle
    :param: t0 Le temps initial
    :param: y0 La valeur initiale
    :param: tmax Le temps maximal
    :param: h Le pas de calcul
    :return: x, y Les valeurs de temps et de la fonction
    """
    N = round((tmax - t0) / h)

    x = np.linspace(t0, tmax, N)
    y = np.empty(N)
    y[0] = y0

    for i in range(1, len(x)):
        y[i] = y[i - 1] + h * f(y[i - 1], x[i - 1])
    
    return x, y


if __name__ == "__main__":
    import numpy as np

    array = np.fromiter(
        monte_carlo(lambda x1, x2, D: ((D ** 2) - ((x2 - x1) ** 2)) / (4 * D), (18, 3), (41, 3), (60, 0.1)),
        float
    )

    print("Distance focale: %.2f +/- %.2f cm" % (np.mean(array), np.std(array)))