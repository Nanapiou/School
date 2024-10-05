#include "dicts.h"

typedef struct AFD
{
    int Q;
    int Sigma;
    int qI;
    bool *finaux;
    int **delta;
} afd;