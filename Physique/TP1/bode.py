"""
Created on Thu Sep  5 10:57:13 2024

@author: sonia
"""

import numpy as np
import matplotlib.pylab as plt
import scipy.optimize as si
from fonctions_utiles import monte_carlo

f0 = 100
Q = 10
H0 = 1


def PB1(f):
    return H0/(1+1j*f/f0)

def PH1(f):
    return H0*1j*f/f0/(1+1j*f/f0)

def PB2(f):
    return H0/(1+1j*f/f0/Q-(f/f0)**2)

def PBa2(f):
    return H0/(1+1j*f/f0/Q-(f/f0)**2)*1j*f/f0/Q

def PH2(f):
    return -H0/(1+1j*f/f0/Q-(f/f0)**2)*(f/f0)**2

def trace(filtre):
    logf0 = np.floor(np.log10(f0))
    f = np.logspace(logf0-4, logf0+4, 1000)

    fig, axs = plt.subplots(2)
    fig.suptitle('Diagramme de Bode du filtre')
    axs[0].semilogx(f, 20*np.log10(np.abs(filtre(f))))
    axs[0].set(xlabel=r'f', ylabel=r'$GdB$')
    axs[1].semilogx(f, np.angle(filtre(f), deg=True), label=r'$\phi"')
    axs[1].set(xlabel=r'f', ylabel=r'$\varphi$')
    axs[0].grid(True, which="both")
    axs[1].grid(which='both', axis='both')
    plt.show()


trace(PB2)


# %% partie expérimentale

valeurs_f = np.array([0.01, 0.03, 0.07, 0.1, 0.3, 0.7, 1, 2, 3, 7, 10, 30, 70])
valeurs_ue = np.array([7.200,] * len(valeurs_f))
valeurs_us = [7.185, 7.191, 7.183, 7.178, 7.056, 6.528, 5.996, 4.2997, 3.203, 1.501, 1.0619, 0.3487, 0.1359]
# valeurs_us = np.abs(PB1(valeurs_f))+.01*(2*np.random.rand()-1)
G = valeurs_us/valeurs_ue
GdB = 20*np.log10(valeurs_us/valeurs_ue)


def modeleGdB(f, H1, f1):
    return 20*np.log10(np.abs(H1/(1+1j*f/f1)))


coefficients, covar = si.curve_fit(modeleGdB, valeurs_f, GdB)


def modeleG(f, H1, f1):
    return (np.abs(H1/(1+1j*f/f1)))


coefficients2, covar = si.curve_fit(modeleG, valeurs_f, G)

plt.figure(2)
plt.semilogx(valeurs_f, GdB, 'o', label='exp')
plt.semilogx(valeurs_f, modeleGdB(
    valeurs_f, coefficients[0], coefficients[1]), '-', color='b', label='th avec GdB')
plt.semilogx(valeurs_f, 20*np.log10(modeleG(valeurs_f,
             coefficients2[0], coefficients2[1])), '-', color='k', label='th2 avec G')
plt.xlabel(r'$f$')
plt.xlabel(r'$GdB$')
plt.grid(which='both')
plt.savefig('result.png')
