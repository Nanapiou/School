#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "graphe.h"
#include "unir_trouver.h"

int main() {
    graphe *g = lire_graphe("le_graphe.txt");

    afficher_graphe(g);

    ecrire_graphe(g, "sortie.txt");

    int nb_aretes;
    arete *as = obtenir_aretes(g, &nb_aretes);
    trier_aretes(as, nb_aretes);
    afficher_tableau_aretes(as, nb_aretes);
    printf("Poids: %.1lf\n", sommes_poids(as, nb_aretes));

    int nb;
    arete *brov = boruvska(g, &nb);

    trier_aretes(brov, nb);
    afficher_tableau_aretes(brov, nb);



    arete *krus = kruskal(g, &nb);
    afficher_tableau_aretes(krus, nb);

    return EXIT_SUCCESS;
}