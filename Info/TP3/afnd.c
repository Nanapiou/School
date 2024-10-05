#include "afd.h"

typedef struct AFND
{
    int Q;
    int Sigma;
    bool *initiaux;
    bool *finaux;
    list ***delta;
} afnd;

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
    list ***delta = malloc(Q * sizeof(*delta));
    for (int q = 0; q < Q; q++)
    {
        finaux[q] = false;
        initiaux[q] = false;
        list **tab = malloc(Sigma * sizeof(*tab));
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

void afficher_afnd(afnd B)
{
    printf("Q: %d\nSigma: %d\n", B.Q, B.Sigma);
    printf("Initiaux: ");
    for (int q = 0; q < B.Q; q++)
        if (B.initiaux[q])
            printf("%d ", q);
    printf("\nFinaux: ");
    for (int q = 0; q < B.Q; q++)
        if (B.finaux[q])
            printf("%d ", q);

    printf("\nDelta:\n");
    for (int q = 0; q < B.Q; q++)
        for (int a = 0; a < B.Sigma; a++)
            for (list *l = B.delta[q][a]; l != NULL; l = l->next)
                printf("%d -- %c --> %d\n", q, 'a' + a, l->val);
}

void ajout_transition_afnd(afnd B, int q, char a, int p)
{
    B.delta[q][a - 'a'] = cons(p, B.delta[q][a - 'a']);
}

bool *delta_etats(afnd B, bool *X, char a)
{
    bool *result = calloc(B.Q, sizeof(bool));
    for (int q = 0; q < B.Q; q++)
        if (X[q])
            for (list *l = B.delta[q][a - 'a']; l != NULL; l = l->next)
                result[l->val] = true;

    return result;
}

bool *delta_etoile_afnd(afnd B, bool *X, char *u)
{
    assert (*u != '\0');
    bool *X_prime = delta_etats(B, X, *u);
    bool *X_prime_prime;
    u++;
    for(; *u != '\0'; u++) {
        X_prime_prime = delta_etats(B, X, *u);
        free(X_prime);
        X_prime = X_prime_prime;
    }
    return X_prime;
}

bool reconnu_afnd(afnd B, char *u)
{
    bool *X = delta_etoile_afnd(B, B.initiaux, u);
    for (int q = 0; q < B.Q; q++)
        if (X[q] && B.finaux[q]) {
            free(X);
            return true;
        }
    free(X);
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

// afd determiniser(afnd B)
// {
//     afd A;

//     return A;
// }

// dict accessibles(afnd B)
// {
//     dict D;

//     return D;
// }

// afd determiniser2(afnd B)
// {
//     afd A;

//     return A;
// }

int main()
{
    afnd B1 = init_afnd(6, 2);
    B1.initiaux[0] = true;
    B1.initiaux[3] = true;
    B1.finaux[2] = true;
    B1.finaux[5] = true;
    ajout_transition_afnd(B1, 0, 'a', 0);
    ajout_transition_afnd(B1, 0, 'b', 0);
    ajout_transition_afnd(B1, 0, 'a', 1);
    ajout_transition_afnd(B1, 1, 'b', 2);
    ajout_transition_afnd(B1, 3, 'b', 4);
    ajout_transition_afnd(B1, 4, 'a', 5);
    ajout_transition_afnd(B1, 5, 'a', 5);
    ajout_transition_afnd(B1, 5, 'b', 5);

    afnd B2 = init_afnd(4, 2);
    B2.initiaux[0] = true;
    B2.finaux[3] = true;
    ajout_transition_afnd(B2, 0, 'a', 0);
    ajout_transition_afnd(B2, 0, 'b', 0);
    ajout_transition_afnd(B2, 0, 'a', 1);
    ajout_transition_afnd(B2, 1, 'a', 2);
    ajout_transition_afnd(B2, 1, 'b', 2);
    ajout_transition_afnd(B2, 2, 'a', 3);
    ajout_transition_afnd(B2, 2, 'b', 3);

    printf("%d\n", reconnu_afnd(B2, "aaa"));

    liberer_afnd(B1);
    liberer_afnd(B2);

    return EXIT_SUCCESS;
}
