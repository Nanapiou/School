import numpy as np
from random import uniform

angles_100g = np.deg2rad(np.array([29.3, 28.4, 29.3, 30.8, 31.7, 33.8, 30.4, 31.8, 35.1, 31.6]))
angles_5g = np.deg2rad(np.array([32.2, 34.4, 38.4]))

delta_a100g = np.std(angles_100g, ddof=1) / np.sqrt(len(angles_100g))
delta_a5g = np.std(angles_5g, ddof=1) / np.sqrt(len(angles_5g))
moy_a100g = np.mean(angles_100g)
moy_a5g = np.mean(angles_5g)

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
    yield from (fn(*(uniform(e - delta, e + delta) for e, delta in args)) for _ in range(N))

f_100g = np.fromiter(monte_carlo(np.tan, (moy_a100g, delta_a100g)), float)
f_5g = np.fromiter(monte_carlo(np.tan, (moy_a5g, delta_a5g)), float)
print(f_100g)

moy100g = np.mean(f_100g)
moy5g = np.mean(f_5g)
sigma100g = np.std(f_100g, ddof=1)
sigma5g = np.std(f_5g, ddof=1)
delta100g = sigma100g / np.sqrt(len(f_100g))
delta5g = sigma5g / np.sqrt(len(f_5g))

print(f"f_100g = {moy100g:.3f} ± {delta100g:.3f}")
print(f"f_5g = {moy5g:.3f} ± {delta5g:.3f}")


# -----------------------------------------------------

# Pln plat double masse
d = np.array([24.1, 24.3, 24.6, 24.75, 24.9, 25.3, 25.4, 25.55]) * 1e-2
delta_d = np.std(d, ddof=1) / np.sqrt(len(d))
moy_d = np.mean(d)

moy_m = 40e-3
delta_m = 1e-3

moy_M = 50e-3
delta_M = 1e-3

moy_h = 21.3e-2
delta_h = 0.1e-2

def fd(m, M, h, D):
    return (m * h) / ((M * D) + m * (D - h))

f_d = np.fromiter(monte_carlo(fd, (moy_m, delta_m), (moy_M, delta_M), (moy_h, delta_h), (moy_d, delta_d)), float)

moy_fd = np.mean(f_d)
sigma_fd = np.std(f_d, ddof=1)

print(f"f_d = {moy_fd:.3f} ± {sigma_fd:.3f}")
