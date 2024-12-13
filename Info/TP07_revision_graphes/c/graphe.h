#include <stdbool.h>

typedef struct graphe {
    int *mat;
    int n;
} graphe;

graphe *creer_graphe(int n);
void detruire_graphe(graphe *g);
void ajouter_arete(graphe *g, int u, int v);
void ajouter_double_arete(graphe *g, int u, int v);
void enlever_arete(graphe *g, int u, int v);
void enlever_double_arete(graphe *g, int u, int v);
bool sont_relies(graphe *g, int u, int v);


void parcours_largeur(graphe *g);
int distance(graphe *g, int u, int v);
int *chemin(graphe *g, int u, int v);
void afficher_chemin(int *chemin);