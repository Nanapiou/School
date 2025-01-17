#include "graphe.h"
#include "file.h"
#include "unir_trouver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

graphe *creer_graphe(int n)
{
    graphe *g = malloc(sizeof(graphe));
    g->n = n;
    g->degres = calloc(n, sizeof(int));
    g->liste_adjacence = calloc(n, sizeof(arete *));
    return g;
}

int taille_graphe(graphe *g) {
    int t = 0;
    for (int i = 0; i < g->n; i++) {
        t += g->degres[i];
    }
    return t / 2;
}

void afficher_graphe(graphe *g)
{
    printf("%d\n", g->n);
    for (int i = 0; i < g->n; i++) {
        printf ("%d ", i);
        for (int j = 0; j < g->degres[i]; j++) {
            printf("(%d, %.1lf) ", g->liste_adjacence[i][j].t, g->liste_adjacence[i][j].p);
        }
        printf("\n");
    }
}

void detruire_graphe(graphe *g)
{
    free(g->degres);
    for (int i = 0; i < g->n; i++)
    {
        free(g->liste_adjacence[i]);
    }
    free(g->liste_adjacence);
    free(g);
}

void ajouter_arc(graphe *g, int u, int v, double p)
{
    g->liste_adjacence[u] = realloc(g->liste_adjacence[u], (g->degres[u] + 1) * sizeof(arete));
    g->liste_adjacence[u][g->degres[u]].s = u;
    g->liste_adjacence[u][g->degres[u]].t = v;
    g->liste_adjacence[u][g->degres[u]].p = p;
    g->degres[u]++;
}

void ajouter_arete(graphe *g, int u, int v, double p) {
    ajouter_arc(g, u, v, p);
    ajouter_arc(g, v, u, p);
}

void enlever_arete(graphe *g, int u, int v)
{
    fprintf(stderr, "Pas enlever arete");
    exit(1);
}

double poids_arete(graphe *g, int u, int v)
{
    for (int i = 0; i < g->degres[u]; i++)
    {
        if (g->liste_adjacence[u][i].t == v)
        {
            return g->liste_adjacence[u][i].p;
        }
    }
    return -1;
}

graphe *lire_graphe(char *nom_fichier) {
    FILE *f = fopen(nom_fichier, "r");
    if (f == NULL) {
        fprintf(stderr, "Fichier non ouvert");
        exit(1);
    }

    int n;
    fscanf(f, "%d", &n);

    graphe *g = creer_graphe(n);

    for (int s = 0; s < n; s++) {
        int o;
        fscanf(f, "\n%d", &o);
        for (int i = 0; i < o; i++) {
            int t;
            double p;
            fscanf(f, " (%d, %lf)", &t, &p);

            ajouter_arc(g, s, t, p);
        }
    }

    fclose(f);

    return g;
}


void ecrire_graphe(graphe *g, char *nom_fichier) {
    FILE *f = fopen(nom_fichier, "w");
    if (f == NULL) {
        fprintf(stderr, "Fichier non ouvert");
        exit(1);
    }

    fprintf(f, "%d\n", g->n);
    for (int i = 0; i < g->n; i++) {
        fprintf(f, "%d ", i);
        for (int j = 0; j < g->degres[i]; j++) {
            fprintf(f, "(%d, %d) ", g->liste_adjacence[i][j].t, (int) g->liste_adjacence[i][j].p);
        }
        if (i != g->n - 1) fprintf(f, "\n");
    }
}

arete* obtenir_aretes(graphe* g, int* nb_aretes) {
    int taille = taille_graphe(g);
    arete *as = calloc(taille, sizeof(arete));

    int k = 0;
    for (int i = 0; i < g->n; i++) {
        for (int j = 0; j < g->degres[i]; j++) {
            arete a = g->liste_adjacence[i][j];
            if (a.s < a.t)
                as[k++] = a;
        }
    }

    *nb_aretes = taille;
    return as;
}

void afficher_tableau_aretes(arete* aretes, int nb_aretes) {
    for (int i = 0; i < nb_aretes; i++) {
        printf("(%d, %d, %.1lf) ", aretes[i].s, aretes[i].t, aretes[i].p);
    }
    printf("\n");
}

double sommes_poids(arete* aretes, int nb_aretes) {
    double p_tot = 0;

    for (int i = 0; i < nb_aretes; i++) 
        p_tot += aretes[i].p;

    return p_tot;
}

void trier_aretes(arete *aretes, int nb_aretes) {
    if (nb_aretes == 0 || nb_aretes == 1) {
        return;
    }

    int mid = nb_aretes / 2;
    int l1 = mid, l2 = nb_aretes - mid;
    arete *a1 = aretes, *a2 = aretes + mid;
    trier_aretes(a1, l1);
    trier_aretes(a2, l2);

    arete result[nb_aretes];
    int i = 0, j = 0, k = 0;
    while (i < l1 && j < l2) {
        if (a1[i].p < a2[j].p) {
            result[k++] = a1[i++];
        } else {
            result[k++] = a2[j++];
        }
    }

    while (i < l1) {
        result[k++] = a1[i++];
    }

    while (j < l2) {
        result[k++] = a2[j++];
    }

    memcpy(aretes, result, nb_aretes * sizeof(arete));
}

arete* kruskal(graphe* g, int* nb_choisis) {
    int nb_aretes;
    arete *as = obtenir_aretes(g, &nb_aretes);

    arete *result = malloc(nb_aretes * sizeof(arete));
    int k = 0;

    trier_aretes(as, nb_aretes);

    unir_trouver ut = creer_unir_trouver(g->n);
    for (int i = 0; i < nb_aretes; i++) {
        arete a = as[i];
        int s = a.s, t = a.t;
        if (trouver(ut, s) != trouver(ut, t)) {
            unir(ut, s, t);
            result[k++] = a;
        }
    }

    *nb_choisis = k;
    return result;
}