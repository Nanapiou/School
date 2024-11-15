#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct param
{
    int index;
    pthread_mutex_t *m;
} param;


void *f(void *pr) {
    param *p = (param *)pr;
    pthread_mutex_lock(p->m);
    for (int i = 0; i < 100000; i++)
        p->index++;
    pthread_mutex_unlock(p->m);
    return NULL;
}

int main() {

    pthread_mutex_t m;
    pthread_mutex_init(&m, NULL);
    param p = {0, &m};

    pthread_t t1, t2;
    pthread_create(&t1, NULL, f, &p);
    pthread_create(&t2, NULL, f, &p);
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    printf("index = %d\n", p.index);

    return EXIT_SUCCESS;
}