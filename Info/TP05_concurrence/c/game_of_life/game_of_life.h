#include "barrier.h"

typedef struct game_of_life
{
    int m;
    int n;
    int **board;
} game_of_life;

void print_board(game_of_life b);
game_of_life init_board(int n, int m);
void free_board(game_of_life b);
void next_board(game_of_life *b);
void next_board_barrier(game_of_life *b, barrier *barrier);
void copy_sheme(game_of_life *b, game_of_life c, int x, int y);