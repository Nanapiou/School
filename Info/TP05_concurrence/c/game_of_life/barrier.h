#include <pthread.h>
#include <semaphore.h>

// A barrier for n threads
// count: number of threads that have reached the barrier
// wait: semaphore to wait for all threads to reach the barrier
// done: semaphore to signal that all threads have reached the barrier
typedef struct barrier
{
    int n;
    int count;
    pthread_mutex_t mutex;
    sem_t wait;
    sem_t done;
} barrier;

barrier barrier_init(int n);
void barrier_wait(barrier *b);