typedef struct unir_trouver
{
    int n;
    int *parent;
    int *rang;
} unir_trouver;

unir_trouver creer_unir_trouver(int n);
void detruire_unir_trouver(unir_trouver ut);
int trouver(unir_trouver ut, int x);
void unir(unir_trouver ut, int x, int y);

void afficher_unir_trouver(unir_trouver ut);