#include <pthread.h>
#include <stdio.h>

#define NB_THREADS 3

void *f(void *arg)
{
	int index = *(int *)arg;
	for (int i = 0; i < 10; i++)
	{
		printf("Thread %d : %d\n", index, i);
	}
	return NULL;
}

int main(void)
{
	pthread_t threads[NB_THREADS];
	printf("Before creating the threads.\n");
	int thread_indexs[NB_THREADS];
	for (int i = 0; i < NB_THREADS; i++)
	{
		thread_indexs[i] = i;
		pthread_create(&threads[i], NULL, f, thread_indexs + i);
	}
	printf("While the other threads are running.\n");
	for (int i = 0; i < NB_THREADS; i++)
	{
		pthread_join(threads[i], NULL);
	}
	printf("After the other threads have stopped running.\n");
	return 0;
}
