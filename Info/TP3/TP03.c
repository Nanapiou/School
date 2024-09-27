#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

// #include "dicts.h"

struct AFD
{
    int Q;
    int Sigma;
    int qI;
    bool *finaux;
    int **delta;
};

typedef struct AFD afd;

void liberer_afd(afd A)
{
    free(A.finaux);
    for (int i = 0; i < A.Q; i++)
        free(A.delta[i]);
    free(A.delta);
}

afd init_afd(int Q, int Sigma, int qI)
{
    afd A;
    A.Q = Q;
    A.Sigma = Sigma;
    A.qI = qI;
    A.finaux = calloc(Q, sizeof(bool));
    A.delta = malloc(Q * sizeof(int *));
    for (int q = 0; q < Q; q++)
    {
        A.delta[q] = malloc(Sigma * sizeof(int));
        for (int a = 0; a < Sigma; a++)
        {
            A.delta[q][a] = -1;
        }
    }
    return A;
}

void ajout_transition_afd(afd A, int q, char a, int p)
{
    A.delta[q][a - 'a'] = p;
}

int delta_etoile_afd(afd A, int q, char *u)
{
    for (; *u != '\0'; u++)
    {
        char c = *u - 'a';
        // printf("%d, %d\n", c, q);
        q = A.delta[q][c];
        if (q == -1)
            return -1;
    }

    return q;
}

bool reconnu_afd(afd A, char *u)
{
    return A.finaux[delta_etoile_afd(A, A.qI, u)];
}

afd completer_afd(afd A)
{
    afd AA = init_afd(A.Q + 1, A.Sigma, A.qI);
    int puit = A.Q;
    for (int a = 0; a < A.Sigma; a++)
        ajout_transition_afd(AA, puit, a + 'a', puit);

    for (int q = 0; q < A.Q; q++)
        for (int a = 0; a < A.Sigma; a++)
            if (A.delta[q][a] == -1)
                AA.delta[q][a] = puit;
}

bool accessible_aux(afd A, bool *cherches, bool *parcourus, int q_actuel)
{
    parcourus[q_actuel] = true;
    for (int a = 0; a < A.Sigma; a++)
    {
        int q = A.delta[q_actuel][a];
        if (cherches[q])
            return true;

        if (!parcourus[q])
            if (accessible_afd(A, q))
                return true;
    }
}

bool accessible_afd(afd A, int q)
{
    bool *parcourus = calloc(A.Q, sizeof(bool));
    bool *cherches = calloc(A.Q, sizeof(bool));
    cherches[q] = true;
    bool resultat = accessible_aux(A, cherches, parcourus, A.qI);
    free(parcourus);
    free(cherches);
    return resultat;
}

bool coaccessible_afd(afd A, int q)
{
    bool *parcourus = calloc(A.Q, sizeof(bool));
    bool resultat = accessible_aux(A, A.finaux, parcourus, A.qI);
    free(parcourus);
    return resultat;
}

bool utile_afd(afd A, int q)
{
    return accessible_afd(A, q) && coaccessible_afd(A, q);
}

afd emonder_afd(afd A)
{
    bool *utiles = malloc(A.Q * sizeof(bool));
    int n_inutiles = 0;
    int *n_inutiles_avant_q = calloc(A.Q, sizeof(int));

    for (int q = 0; q < A.Q; q++)
    {
        bool utile = utile_afd(A, q);
        utiles[q] = utile;
        if (!utile)
        {
            n_inutiles++;
        }
        n_inutiles_avant_q[q] = n_inutiles;
    }
    int n_utiles = A.Q - n_inutiles;

    bool *finaux = calloc(n_utiles, sizeof(bool));
    int **delta = calloc(n_utiles, sizeof(int));
    int qI;

    for (int q = 0; q < A.Q; q++)
    {
        if (A.finaux[q])
        {
            finaux[q - n_inutiles_avant_q[q]] = true;
        }

        if (q = A.qI)
        {
            qI = q - n_inutiles_avant_q[q];
        }

        if (utiles[q])
        {
            delta[q - n_inutiles_avant_q[q]] = calloc(A.Sigma, sizeof(int));
            for (int a = 0; a < A.Sigma; a++)
            {
                int q_dest = A.delta[q][a];
                delta[q - n_inutiles_avant_q[q]][a] = q_dest - n_inutiles_avant_q[q_dest];
            }
        }
    }

    afd AA = init_afd(n_utiles, A.Sigma, qI);
    AA.finaux = finaux;
    AA.delta = delta;
    return AA;
}

/*
struct AFND {
    int Q;
    int Sigma;
    bool* initiaux;
    bool* finaux;
    liste*** delta;
};

typedef struct AFND afnd;

void liberer_afnd(afnd B){
    // Libère la mémoire d'un AFND.
    free(B.initiaux);
    free(B.finaux);
    for (int i=0; i<B.Q; i++){
        for (int j=0; j<B.Sigma; j++){
            liberer_liste(B.delta[i][j]);
        }
        free(B.delta[i]);
    }
    free(B.delta);
}

afnd init_afnd(int Q, int Sigma){
    // Initialise un AFND.
    afnd B;
    B.Q = Q;
    B.Sigma = Sigma;
    bool* finaux = malloc(Q * sizeof(*finaux));
    bool* initiaux = malloc(Q * sizeof(*initiaux));
    liste*** delta = malloc(Q * sizeof(*delta));
    for (int q=0; q<Q; q++){
        finaux[q] = false;
        initiaux[q] = false;
        liste** tab = malloc(Sigma * sizeof(*tab));
        for (int a=0; a<Sigma; a++){
            tab[a] = NULL;
        }
        delta[q] = tab;
    }
    B.finaux = finaux;
    B.initiaux = initiaux;
    B.delta = delta;
    return B;
}

void ajout_transition_afnd(afnd B, int q, char a, int p){

}

bool* delta_etats(afnd B, bool* X, char a){

    return NULL;
}

bool* delta_etoile_afnd(afnd B, bool* X, char* u){

    return NULL;
}

bool reconnu_afnd(afnd B, char* u){

    return false;
}

int etats_vers_entier(bool* X, int Q){

    return 0;
}

bool* entier_vers_etats(int x, int Q){

    return NULL;
}

afd determiniser(afnd B){
    afd A;

    return A;
}

dict accessibles(afnd B){
    dict D;

    return D;
}

afd determiniser2(afnd B){
    afd A;

    return A;
}
*/

int main(void)
{
    afd A1 = init_afd(4, 2, 0);
    A1.finaux[3] = true;
    ajout_transition_afd(A1, 0, 'b', 0);
    ajout_transition_afd(A1, 0, 'a', 1);
    ajout_transition_afd(A1, 1, 'a', 2);
    ajout_transition_afd(A1, 1, 'b', 0);
    ajout_transition_afd(A1, 2, 'a', 2);
    ajout_transition_afd(A1, 2, 'b', 3);
    ajout_transition_afd(A1, 3, 'a', 1);
    ajout_transition_afd(A1, 3, 'b', 0);

    char u[] = "abbabbabaab";
    char v[] = "baababbbbba";
    char w[] = "aaabababb";

    afd A2 = init_afd(6, 2, 0);
    A2.finaux[3] = true;
    ajout_transition_afd(A2, 0, 'a', 1);

    ajout_transition_afd(A2, 1, 'a', 2);
    ajout_transition_afd(A2, 1, 'b', 2);

    ajout_transition_afd(A2, 2, 'a', 3);
    ajout_transition_afd(A2, 2, 'b', 3);

    ajout_transition_afd(A2, 3, 'a', 4);
    ajout_transition_afd(A2, 3, 'b', 4);

    ajout_transition_afd(A2, 4, 'a', 5);
    ajout_transition_afd(A2, 4, 'b', 5);

    ajout_transition_afd(A2, 5, 'a', 3);
    ajout_transition_afd(A2, 5, 'b', 3);


    afd A3 = init_afd(5, 2, 0);

    // afnd B1 = init_afnd(6, 2);
    // B1.initiaux[0] = true; B1.initiaux[3] = true;
    // B1.finaux[2] = true; B1.finaux[5] = true;
    // ajout_transition_afnd(B1, 0, 'a', 0); ajout_transition_afnd(B1, 0, 'b', 0);
    // ajout_transition_afnd(B1, 0, 'a', 1); ajout_transition_afnd(B1, 1, 'b', 2);
    // ajout_transition_afnd(B1, 3, 'b', 4); ajout_transition_afnd(B1, 4, 'a', 5);
    // ajout_transition_afnd(B1, 5, 'a', 5); ajout_transition_afnd(B1, 5, 'b', 5);

    // liberer_afnd(B1);
    liberer_afd(A1);
    liberer_afd(A2);

    return EXIT_SUCCESS;
}
