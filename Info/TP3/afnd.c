#include "afd.h"

struct AFND
{
    int Q;
    int Sigma;
    bool *initiaux;
    bool *finaux;
    liste ***delta;
};

typedef struct AFND afnd;

void liberer_afnd(afnd B)
{
    // Libère la mémoire d'un AFND.
    free(B.initiaux);
    free(B.finaux);
    for (int i = 0; i < B.Q; i++)
    {
        for (int j = 0; j < B.Sigma; j++)
        {
            liberer_liste(B.delta[i][j]);
        }
        free(B.delta[i]);
    }
    free(B.delta);
}

afnd init_afnd(int Q, int Sigma)
{
    // Initialise un AFND.
    afnd B;
    B.Q = Q;
    B.Sigma = Sigma;
    bool *finaux = malloc(Q * sizeof(*finaux));
    bool *initiaux = malloc(Q * sizeof(*initiaux));
    liste ***delta = malloc(Q * sizeof(*delta));
    for (int q = 0; q < Q; q++)
    {
        finaux[q] = false;
        initiaux[q] = false;
        liste **tab = malloc(Sigma * sizeof(*tab));
        for (int a = 0; a < Sigma; a++)
        {
            tab[a] = NULL;
        }
        delta[q] = tab;
    }
    B.finaux = finaux;
    B.initiaux = initiaux;
    B.delta = delta;
    return B;
}

void ajout_transition_afnd(afnd B, int q, char a, int p)
{
}

bool *delta_etats(afnd B, bool *X, char a)
{

    return NULL;
}

bool *delta_etoile_afnd(afnd B, bool *X, char *u)
{

    return NULL;
}

bool reconnu_afnd(afnd B, char *u)
{

    return false;
}

int etats_vers_entier(bool *X, int Q)
{

    return 0;
}

bool *entier_vers_etats(int x, int Q)
{

    return NULL;
}

afd determiniser(afnd B)
{
    afd A;

    return A;
}

dict accessibles(afnd B)
{
    dict D;

    return D;
}

afd determiniser2(afnd B)
{
    afd A;

    return A;
}

int main()
{

    return EXIT_SUCCESS;
}
