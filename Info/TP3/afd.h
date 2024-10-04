#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include "dicts.h"

typedef struct AFD
{
    int Q;
    int Sigma;
    int qI;
    bool *finaux;
    int **delta;
} afd;