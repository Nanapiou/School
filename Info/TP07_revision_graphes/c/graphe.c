#include "graphe.h"
#include "file.h"
#include <stdio.h>
#include <stdlib.h>

graphe *creer_graphe(int n)
{
    graphe *g = malloc(sizeof(graphe));
    g->n = n;
    g->mat = calloc(n * n, sizeof(int));
    return g;
}

void afficher_graphe(graphe *g)
{
    for (int i = 0; i < g->n; i++)
    {
        for (int j = 0; j < g->n; j++)
        {
            printf("%d ", g->mat[i * g->n + j]);
        }
        printf("\n");
    }
}

void detruire_graphe(graphe *g)
{
    free(g->mat);
    free(g);
}

void ajouter_double_arete(graphe *g, int u, int v)
{
    g->mat[u * g->n + v] = 1;
    g->mat[v * g->n + u] = 1;
}

void ajouter_arete(graphe *g, int u, int v)
{
    g->mat[u * g->n + v] = 1;
}

void enlever_double_arete(graphe *g, int u, int v)
{
    g->mat[u * g->n + v] = 0;
    g->mat[v * g->n + u] = 0;
}

void enlever_arete(graphe *g, int u, int v)
{
    g->mat[u * g->n + v] = 0;
}

bool sont_relies(graphe *g, int u, int v)
{
    return g->mat[u * g->n + v] == 1;
}

int premier_non_vu(bool *vu, int n)
{
    for (int i = 0; i < n; i++)
    {
        if (!vu[i])
        {
            return i;
        }
    }
    return -1;
}

void parcours_largeur(graphe *g)
{
    afficher_graphe(g);
    file *f = creer_file();
    bool *vu = calloc(g->n, sizeof(bool));
    int s = 0;
    do
    {
        enfiler(f, s);
        vu[s] = true;
        while (!file_vide(f))
        {
            int u = defiler(f);
            printf("%d\n", u);
            for (int v = 0; v < g->n; v++)
            {
                if (sont_relies(g, u, v) && !vu[v])
                {
                    enfiler(f, v);
                    vu[v] = true;
                }
            }
        }
        s = premier_non_vu(vu, g->n);
    } while (s != -1);
    detruire_file(f);
    free(vu);
}

int distance(graphe *g, int u, int v)
{
    file *f = creer_file();
    bool *vu = calloc(g->n, sizeof(bool));
    int *dist = calloc(g->n, sizeof(int));
    enfiler(f, u);
    vu[u] = true;
    dist[u] = 0;
    while (!file_vide(f))
    {
        int x = defiler(f);
        for (int y = 0; y < g->n; y++)
        {
            if (sont_relies(g, x, y) && !vu[y])
            {
                enfiler(f, y);
                vu[y] = true;
                dist[y] = dist[x] + 1;
            }
        }
    }
    int res = dist[v];
    free(dist);
    free(vu);
    detruire_file(f);
    return res ? res : -1;
}

void afficher_chemin(int *chem)
{
    printf("%d", chem[1]);
    for (int i = 2; i <= chem[0]; i++)
    {
        printf(" <- %d ", chem[i]);
    }
    printf("\n");
}

int *chemin(graphe *g, int u, int v)
{
    bool *vu = calloc(g->n, sizeof(bool));
    int *preds = calloc(g->n, sizeof(int));
    for (int i = 0; i < g->n; i++)
        preds[i] = -1;

    file *f = creer_file();
    enfiler(f, u);
    vu[u] = true;
    while (!file_vide(f))
    {
        int x = defiler(f);
        for (int y = 0; y < g->n; y++)
        {
            if (sont_relies(g, x, y) && !vu[y])
            {
                enfiler(f, y);
                vu[y] = true;
                preds[y] = x;
            }
        }
    }
    int *chem = calloc(g->n + 1, sizeof(int)); // chem[0] est la longueur du chemin
    if (vu[v])
    {
        int i = 1;
        for (int x = v; x != u; x = preds[x])
        {
            chem[i++] = x;
        }
        chem[i] = u;
        chem[0] = i;
    }
    free(preds);
    free(vu);
    detruire_file(f);
    return chem;
}