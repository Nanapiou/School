#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

int max(int a, int b) {
    return a > b ? a : b;
}

int somme(int *a, int n) {
    int s = 0;
    for (int i = 0; i < n; i++)
        s += a[i];
    return s;
}

typedef struct param
{
    int *a;
    int i;
    int j;
    int s;
} param;


void *somme_partielle(void *param) {
    struct param *p = (struct param *)param;
    for (int i = p->i; i < p->j; i++)
        p->s += p->a[i];
    return NULL;
}

int somme_concur(int *a, int n, int n_fils) {
    int s = 0;
    pthread_t fils[n_fils];
    param p[n_fils];
    for (int i = 0; i < n_fils; i++) {
        p[i].a = a;
        p[i].i = i * n / n_fils;
        p[i].j = max((i + 1) * n / n_fils, n);
        p[i].s = 0;
        pthread_create(&fils[i], NULL, somme_partielle, &p[i]);
    }

    for (int i = 0; i < n_fils; i++) {
        pthread_join(fils[i], NULL);
        s += p[i].s;
    }

    return s;
}

int main() {
    int n = 2000000;
    int a[n];
    for (int i = 0; i < n; i++)
        a[i] = 1;

    // printf("Somme séquentielle: %d\n", somme(a, n));
    printf("Somme concurrente: %d\n", somme_concur(a, n, 4));
    return 0;
}