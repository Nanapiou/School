#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

typedef struct List
{
    int val;
    struct List *next;
} list;

typedef struct List_key
{
    int key;
    int val;
    struct List_key *next;
} list_key;

typedef struct Dict
{
    int capacity;
    int size;
    list_key **data;
} dict;

void liberer_liste(list *lst);

list *cons(int x, list *lst);

void list_free(list_key *lst);

list_key *constr(int k, int v, list_key *lst);

void dict_free(dict D);

dict create(void);

int size(dict D);

int hash(dict D, int k);

bool member_list(list_key *lst, int k);

bool member(dict D, int k);

int get(dict D, int k);

void resize(dict *D, int capa);

void add(dict *D, int k, int v);

void del(dict *D, int k);

list *key_list(dict D);
