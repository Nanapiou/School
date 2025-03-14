#include "unir_trouver.h"
#include <stdio.h>
#include <stdlib.h>

unir_trouver creer_unir_trouver(int n) {
    unir_trouver ut;
    ut.n = n;
    ut.parent = malloc(n * sizeof(int));
    for (int i = 0; i < n; i++)
        ut.parent[i] = i;
    ut.rang = calloc(n, sizeof(int));
    return ut;
}


void detruire_unir_trouver(unir_trouver ut) {
    free(ut.parent);
    free(ut.rang);
}


int trouver(unir_trouver ut, int x) {
    if (ut.parent[x] == x)
        return x;

    int p = trouver(ut, ut.parent[x]);
    ut.parent[x] = p; // Compression de chemin
    return p;
}

void unir(unir_trouver ut, int x, int y) {
    int p1 = trouver(ut, x), p2 = trouver(ut, y);

    if (ut.rang[p1] < ut.rang[p2]) {
        ut.parent[p1] = p2;
    } else if (ut.rang[p2] < ut.rang[p1]) {
        ut.parent[p2] = p1;
    } else {
        ut.parent[p1] = p2;
        ut.rang[p2]++;
    }
}

void afficher_tableau(int *t, int n) {
    for (int i = 0; i < n; i++)
        printf("%2d ", t[i]);
    printf("\n");
}

void afficher_unir_trouver(unir_trouver ut) {
    printf("Parents: ");
    afficher_tableau(ut.parent, ut.n);
    printf("Rangs:   ");
    afficher_tableau(ut.rang, ut.n);
}