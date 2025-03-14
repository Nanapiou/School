#include "file.h"
#include <stdlib.h>
#include <assert.h>

file *creer_file()
{
    file *f = malloc(sizeof(file));
    f->tete = NULL;
    f->queue = NULL;
    return f;
}

bool file_vide(file *f)
{
    return f->tete == NULL;
}

int defiler(file *f)
{
    assert(!file_vide(f));
    int val = f->tete->val;
    elt *tmp = f->tete;
    f->tete = f->tete->suiv;
    if (f->tete == NULL)
    {
        f->queue = NULL;
    }
    free(tmp);
    return val;
}

void enfiler(file *f, int val)
{
    elt *e = malloc(sizeof(elt));
    e->val = val;
    e->suiv = NULL;
    if (f->queue != NULL)
    {
        f->queue->suiv = e;
    }
    else
    {
        f->tete = e;
    }
    f->queue = e;
}

void detruire_file(file *f)
{
    while (!file_vide(f))
    {
        defiler(f);
    }
    free(f);
}
