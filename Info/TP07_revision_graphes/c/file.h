#include <stdbool.h>

typedef struct elt
{
    int val;
    struct elt *suiv;
} elt;

typedef struct file
{
    elt *tete;
    elt *queue;
} file;

file *creer_file();
void detruire_file(file *f);
void enfiler(file *f, int val);
int defiler(file *f);
bool file_vide(file *f);