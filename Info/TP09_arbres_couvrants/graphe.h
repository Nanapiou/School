#include <stdbool.h>

typedef struct arete {
    int s;
    int t;
    double p;
} arete;

typedef struct graphe {
    int n;
    int* degres;
    arete** liste_adjacence;
} graphe;

graphe *creer_graphe(int n);
int taille_graphe(graphe *g);
void afficher_graphe(graphe *g);
void detruire_graphe(graphe *g);
void ajouter_arete(graphe *g, int u, int v, double p);
void ajouter_arc(graphe *g, int u, int v, double p);
void enlever_arete(graphe *g, int u, int v);
double poids_arete(graphe *g, int u, int v);

graphe *lire_graphe(char *nom_fichier);
void ecrire_graphe(graphe *g, char *nom_fichier);

arete* obtenir_aretes(graphe *g, int* nb_aretes);
void afficher_tableau_aretes(arete* aretes, int nb_aretes);
double sommes_poids(arete* aretes, int nb_aretes);
void trier_aretes(arete* aretes, int nb_aretes);

arete* kruskal(graphe* g, int* nb_choisis);


// void parcours_largeur(graphe *g);
// int distance(graphe *g, int u, int v);
// int *chemin(graphe *g, int u, int v);
// void afficher_chemin(int *chemin);