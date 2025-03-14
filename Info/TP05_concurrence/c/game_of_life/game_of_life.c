#include "game_of_life.h"
#include "barrier.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define NB_THREADS 4

void print_board(game_of_life b)
{
    for (int i = 0; i < b.m; i++)
    {
        for (int j = 0; j < b.n; j++)
            printf(b.board[i][j] ? "■ " : "□ ");
        printf("\n");
    }
}

game_of_life init_board(int n, int m)
{
    srand(time(NULL));
    game_of_life b;
    b.m = m;
    b.n = n;
    b.board = malloc(m * sizeof(int *));
    for (int i = 0; i < m; i++)
    {
        b.board[i] = malloc(n * sizeof(int));
        for (int j = 0; j < n; j++)
            // b.board[i][j] = rand() % 2;
            b.board[i][j] = 0;
    }
    return b;
}

void free_board(game_of_life b)
{
    for (int i = 0; i < b.m; i++)
        free(b.board[i]);
    free(b.board);
}

void next_board(game_of_life *b)
{
    int **new_board = malloc(b->m * sizeof(int *));
    for (int i = 0; i < b->m; i++)
    {
        new_board[i] = malloc(b->n * sizeof(int));
        for (int j = 0; j < b->n; j++)
        {
            int neighbors = 0;
            for (int k = -1; k <= 1; k++)
                for (int l = -1; l <= 1; l++)
                {
                    if (k == 0 && l == 0)
                        continue;

                    int x = i + k;
                    int y = j + l;
                    if (x < 0) x = b->m - 1;
                    else if (x >= b->m) x = 0;
                    if (y < 0) y = b->n - 1;
                    else if (y >= b->n) y = 0;
                    
                    neighbors += b->board[x][y];
                }
            
            if (b->board[i][j])
                new_board[i][j] = neighbors == 2 || neighbors == 3;
            else
                new_board[i][j] = neighbors == 3;
        }
    }
    free_board(*b);
    b->board = new_board;
}

typedef struct
{
    game_of_life *b;
    game_of_life *to_change;
    int start; // The start line
    int end; // The end line
} thread_args;

void sub_next_board(void *args)
{
    thread_args *a = args;
    next_board_range(a->b, a->start, a->end);
}

// With barriers
void next_board_barrier(game_of_life *b, barrier *bar)
{
    
}

void copy_sheme(game_of_life *b, game_of_life c, int x, int y)
{
    for (int i = 0; i < c.m; i++)
        for (int j = 0; j < c.n; j++)
            b->board[(i + y) % b->m][(j + x) % b->n] = c.board[i][j];
}