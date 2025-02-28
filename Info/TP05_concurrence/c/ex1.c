#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

#define P 3
#define NN 1000000
#define N 6

void *f(void *arg) {
    int index = * (int*)arg;
    printf("Le fil %d a démarré\n", index);

    for (int i = 1; i <= P * NN; i++) {
        if (i % NN == 0) {
            printf("Le fil %d a atteint %d.\n", index, i);
        }
    }

    return NULL;
}

int main() {
    printf("Avant\n");

    pthread_t fils[N];
    int ints_from_1_to_n[N];
    for (int i = 0; i < N; i++) {
        ints_from_1_to_n[i] = i;
    }

    for (int i = 0; i < N; i++) {
        pthread_create(&fils[i], NULL, f, &ints_from_1_to_n[i]);
    }

    printf("Pendant\n");

    for (int i = 0; i < N; i++) {
        pthread_join(fils[i], NULL);
    }

    printf("Après\n");

    return 0;
}