#include "graphe.h"
#include "file.h"
#include <stdlib.h>
#include <stdio.h>

int main()
{
    graphe *g = creer_graphe(6);
    ajouter_double_arete(g, 0, 1);
    ajouter_double_arete(g, 0, 2);
    ajouter_double_arete(g, 1, 3);
    ajouter_double_arete(g, 2, 5);
    ajouter_double_arete(g, 4, 0);
    ajouter_double_arete(g, 5, 3);
    parcours_largeur(g);
    printf("Distance entre 0 et 2: %d\n", distance(g, 0, 2));
    afficher_chemin(chemin(g, 0, 5));
    detruire_graphe(g);

    return EXIT_SUCCESS;
}