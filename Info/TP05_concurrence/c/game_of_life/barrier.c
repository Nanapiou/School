#include "barrier.h"

barrier barrier_init(int n)
{
    barrier b;
    b.n = n;
    b.count = 0;
    pthread_mutex_init(&b.mutex, NULL);
    sem_init(&b.wait, 0, 0);
    sem_init(&b.done, 0, 0);
    return b;
}

void barrier_wait(barrier *b)
{
    pthread_mutex_lock(&b->mutex);
    b->count++;
    if (b->count == b->n)
    {
        for (int i = 0; i < b->n - 1; i++)
            sem_post(&b->wait);
        for (int i = 0; i < b->n - 1; i++)
            sem_wait(&b->done);
        b->count = 0;
        pthread_mutex_unlock(&b->mutex);
    }
    else
    {
        pthread_mutex_unlock(&b->mutex);

        sem_wait(&b->wait);
        sem_post(&b->done);
    }
}

