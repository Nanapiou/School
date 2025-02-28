#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "game_of_life.h"

#define NB_ETAPES 10000
#define RATE 200000

game_of_life space_ship = {
    4, 5,
    (int *[]) {
        (int []) {0, 1, 0, 0, 1},
        (int []) {1, 0, 0, 0, 0},
        (int []) {1, 0, 0, 0, 1},
        (int []) {1, 1, 1, 1, 0}
    }
};

game_of_life planneur = {
    3, 3,
    (int *[]) {
        (int []) {1, 0, 1},
        (int []) {0, 1, 1},
        (int []) {0, 1, 0},
    }
};

game_of_life line = {
    1, 10,
    (int *[]) {
        (int []) {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}
    }
};

game_of_life galaxy = {
    9, 9,
    (int *[]) {
        (int []) {1, 1, 1, 1, 1, 1, 0, 1, 1},
        (int []) {1, 1, 1, 1, 1, 1, 0, 1, 1},
        (int []) {0, 0, 0, 0, 0, 0, 0, 1, 1},
        (int []) {1, 1, 0, 0, 0, 0, 0, 1, 1},
        (int []) {1, 1, 0, 0, 0, 0, 0, 1, 1},
        (int []) {1, 1, 0, 0, 0, 0, 0, 1, 1},
        (int []) {1, 1, 0, 0, 0, 0, 0, 0, 0},
        (int []) {1, 1, 0, 1, 1, 1, 1, 1, 1},
        (int []) {1, 1, 0, 1, 1, 1, 1, 1, 1}
    }
};

int main() {
    game_of_life b = init_board(40, 20);
    copy_sheme(&b, space_ship, 16, 6);

    for (int i = 0; i < NB_ETAPES; i++) {
        printf("----------\n");
        printf("Étape %d\n", i);
        printf("----------\n");
        print_board(b);
        next_board(&b);
        usleep(RATE);
    }
    return EXIT_SUCCESS;
}
