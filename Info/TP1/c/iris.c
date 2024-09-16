#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

typedef struct flower
{
    float mesures[4];
    int classe;
} flower;

typedef struct distanced_flower
{
    int classe;
    float distance;
} distanced_flower;

int classe_of_string(char *s)
{
    if (strcmp(s, "setosa") == 0)
        return 0;
    else if (strcmp(s, "versicolor") == 0)
        return 1;
    else
        return 2;
}

flower *read_file(char path[], int *n)
{
    FILE *f = fopen(path, "r");
    flower *flowers = malloc(sizeof(flower) * 200);

    char to_throw[100];
    fscanf(f, "%s\n", to_throw);
    float m1, m2, m3, m4;
    char c[100];

    int i = 0;
    while (fscanf(f, "%f,%f,%f,%f,%s\n", &m1, &m2, &m3, &m4, c) != EOF)
    {
        flowers[i].mesures[0] = m1;
        flowers[i].mesures[1] = m2;
        flowers[i].mesures[2] = m3;
        flowers[i].mesures[3] = m4;
        flowers[i].classe = classe_of_string(c);
        i++;
    }
    fclose(f);

    *n = i;
    return flowers;
}

void print_flowers(flower flowers[], int n)
{
    for (int i = 0; i < n; i++)
    {
        printf("%.2f, %.2f, %.2f, %.2f CLASSE: %d\n", flowers[i].mesures[0], flowers[i].mesures[1], flowers[i].mesures[2], flowers[i].mesures[3], flowers[i].classe);
    }
}

float abs_float(float f)
{
    return f < 0 ? -f : f;
}

float distance_man(float x1[4], float x2[4])
{
    float t = 0;
    for (int i = 0; i < 4; i++)
    {
        t += abs_float(x1[i] - x2[i]);
    }
    return t;
}

void shift(distanced_flower *a, int l)
{
    for (int i = l - 1; i > 0; i--)
    {
        a[i] = a[i - 1];
    }
}

void insert(distanced_flower *neighbors, int k, flower f, float distance)
{
    int i = 1;
    while (neighbors[k - i].distance > distance && i <= k)
        i++;
    if (i == 1)
        return;
    int ind = k - i + 1;
    shift(&neighbors[ind], k - ind);
    neighbors[ind].classe = f.classe;
    neighbors[ind].distance = distance;
}

int max_index(int *a, int n)
{
    int m = 0;
    for (int i = 1; i < n; i++)
    {
        if (a[i] > a[m])
            m = i;
    }
    return m;
}

// Used once per flower, I swear
void bubble_sort(distanced_flower *neighbors, int n)
{
    int swapped = 1;
    for (int i = 0; i < n && swapped; i++)
    {
        swapped = 0;
        for (int j = 1; j < n; j++)
        {
            if (neighbors[j].distance < neighbors[j - 1].distance)
            {
                swapped = 1;
                distanced_flower temp = neighbors[j];
                neighbors[j] = neighbors[j - 1];
                neighbors[j - 1] = temp;
            }
        }
    }
}

int k_plus_proches_voisins(int k, flower *flowers, int n, float mesures[4])
{
    distanced_flower *neighbors = calloc(k, sizeof(distanced_flower));
    for (int i = 0; i < k; i++)
    {
        neighbors[i].classe = flowers[i].classe;
        neighbors[i].distance = distance_man(mesures, flowers[i].mesures);
    }
    bubble_sort(neighbors, k);

    for (int i = k; i < n; i++)
    {
        insert(neighbors, k, flowers[i], distance_man(mesures, flowers[i].mesures));
    }
    int classes[3] = {0, 0, 0};
    for (int i = 0; i < k; i++)
    {
        classes[neighbors[i].classe]++;
    }
    free(neighbors);
    return max_index(classes, 3);
}

int *matrice_confusion(int k, flower *jeu_entr, int n_entr, flower *jeu_test, int n_test)
{
    int *mat = calloc(9, sizeof(int));
    for (int i = 0; i < n_test; i++)
    {
        flower f = jeu_test[i];
        mat[3 * f.classe + k_plus_proches_voisins(k, jeu_entr, n_entr, f.mesures)]++;
    }
    return mat;
}

void print_matrice(int *mat, int n)
{
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < n; j++)
        {
            printf("%3d", mat[i * n + j]);
        }
        printf("\n");
    }
}

float taux_taux_erreur_global(int *mat, int n)
{
    int tot = 0;
    for (int i = 0; i < n * n; i++)
        tot += mat[i];

    int diag = 0;
    for (int i = 0; i < n; i++)
        diag += mat[i * n + i];

    int err = tot - diag;

    return err / (float)tot;
}

int main()
{
    int n_entr, n_test;
    flower *jeu_entr = read_file("../iris_jeu_entr.csv", &n_entr);
    flower *jeu_test = read_file("../iris_jeu_test.csv", &n_test);
    int *mat = matrice_confusion(5, jeu_entr, n_entr, jeu_test, n_test);
    print_matrice(mat, 3);
    printf("Taux d'erreur: %.3f\n", taux_taux_erreur_global(mat, 3));
    return EXIT_SUCCESS;
}